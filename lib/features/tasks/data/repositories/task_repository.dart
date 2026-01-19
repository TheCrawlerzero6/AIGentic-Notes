import 'package:mi_agenda/core/data/models/task_model.dart';
import 'package:mi_agenda/core/domain/dtos/task_dtos.dart';
import 'package:mi_agenda/core/domain/entities/task.dart';
import 'package:mi_agenda/core/domain/repositories/task_repository.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants.dart';
import '../../../../core/data/services/notification_service.dart';
import '../datasources/task_local_datasource.dart';

class TaskRepository extends ITaskRepository {
  final TaskLocalDatasource dataSource;
  final NotificationService notificationService;

  TaskRepository({required this.dataSource, required this.notificationService});

  @override
  Future<int> createTask(CreateTaskDto data) async {
    return await dataSource.insert(
      TaskModel(
        title: data.title,
        description: data.description,
        dueDate: data.dueDate,
        isCompleted: data.isCompleted,
        notificationId: data.notificationId,
        sourceType: data.sourceType,
        priority: data.priority,
        projectId: data.projectId,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      ),
    );
  }

  @override
  Future<List<Task>> createTasksBatch(List<CreateTaskDto> tasks) async {
    if (tasks.isEmpty) return [];

    final taskModels = tasks
        .map(
          (data) => TaskModel(
            title: data.title,
            description: data.description,
            dueDate: data.dueDate,
            isCompleted: data.isCompleted,
            notificationId: data.notificationId,
            sourceType: data.sourceType,
            priority: data.priority,
            projectId: data.projectId,
            createdAt: data.createdAt,
            updatedAt: data.updatedAt,
          ),
        )
        .toList();

    // OPTIMIZACIÓN: Usa insertBatch que retorna List<Task> con IDs
    final createdTasks = await dataSource.insertBatch(taskModels);
    return createdTasks;
  }

  @override
  Future<void> batchUpdateNotificationIds(
    Map<int, int> taskIdToNotificationId,
  ) async {
    await dataSource.batchUpdateNotificationIds(taskIdToNotificationId);
  }

  @override
  Future<int> deleteMassiveOldTasks(int id) {
    // TODO: implement deleteMassiveOldTasks
    throw UnimplementedError();
  }

  @override
  Future<int> deleteTask(int id) async {
    return await dataSource.delete(id);
  }

  @override
  Future<DetailedTaskDto?> getTaskDetail(int id) async {
    final task = await dataSource.getDetail(id);
    dynamic notificationResult;
    if (task.notificationId != null) {
      try {
        final dbService = await dataSource.db.database;
        final notificationsList = await dbService.query(
          Constants.tableNotifications,
          where: "id = ?",
          whereArgs: [task.notificationId],
        );
        final notificationRegistry = notificationsList.firstOrNull;
        if (notificationRegistry == null) {
          throw Exception("Task with $id has invalid notificationId");
        }
        notificationResult = Notification(
          id: notificationRegistry["id"] as int,
          notificationId: notificationRegistry["notificationId"] as int,
          notificationDate: DateTime.parse(
            notificationRegistry["notificationDate"] as String,
          ),
        );
      } catch (error) {}
    }
    return DetailedTaskDto(
      id: task.id!,
      title: task.title,
      isCompleted: task.isCompleted,
      sourceType: task.sourceType,
      description: task.description,
      dueDate: task.dueDate,
      completedAt: task.completedAt,

      notificationId: task.notificationId,
      notification: notificationResult,
      priority: task.priority,
      projectId: task.projectId,
      createdAt: task.createdAt,
      updatedAt: task.updatedAt,
    );
  }

  @override
  Future<List<Task>> listTasks(int projectId) async {
    return await dataSource.getAllByProjectId(projectId);
  }

  @override
  Future<List<Task>> listAllTasks() async {
    return await dataSource.getAll();
  }

  
  @override
  Future<dynamic> getDatabase() async {
    return await dataSource.db.database;
  }

  @override
  Future<int> toggleTaskComplete(int id) async {
    final currentTask = await dataSource.getDetail(id);
    final willBeCompleted = !currentTask.isCompleted;
    return await dataSource.toggleTaskComplete(id, willBeCompleted);
  }

  @override
  Future<int> updateTask(int id, UpdateTaskDto data) async {
    final currentTask = await dataSource.getDetail(id);

    return await dataSource.update(
      TaskModel(
        id: id,
        title: data.title ?? currentTask.title,
        description: data.description ?? currentTask.description,
        dueDate: data.dueDate ?? currentTask.dueDate,
        isCompleted: data.isCompleted ?? currentTask.isCompleted,
        sourceType: data.sourceType ?? currentTask.sourceType,
        priority: data.priority ?? currentTask.priority,
        projectId: data.projectId ?? currentTask.projectId,
        createdAt: data.createdAt ?? currentTask.createdAt,
        updatedAt: data.updatedAt,
      ),
    );
  }

  @override
  Future<int> deleteProjectAndTasks(int projectId) async {
    final database = await dataSource.db.database;
    await database.rawDelete('DELETE FROM tasks WHERE projectId = ?', [
      projectId,
    ]);
    final deletedProject = await database.rawDelete(
      'DELETE FROM projects WHERE id = ?',
      [projectId],
    );
    return deletedProject;
  }

  @override
  Future<int> scheduleNotification(int id, DateTime notifDate) async {
    final currentTask = await dataSource.getDetail(id);
    final dbService = await dataSource.db.database;
    final due = currentTask.dueDate!;

    final formattedDate = DateFormat('dd/MM/yyyy').format(due);
    final formattedTime = DateFormat('HH:mm').format(due);

    final body = 'Esta tarea vence el $formattedDate a las $formattedTime';
    final notificationId = await notificationService.scheduleNotification(
      title: currentTask.title,
      body: body,
      scheduledDate: notifDate,
    );
    final insertedNotificationId = await dbService
        .insert(Constants.tableNotifications, {
          "notificationId": notificationId,
          "notificationDate": notifDate.toIso8601String(),
          "updatedAt": DateTime.now().toIso8601String(),
          "createdAt": DateTime.now().toIso8601String(),
        });
    return await updateTask(
      id,
      UpdateTaskDto(
        id: id,
        notificationId: insertedNotificationId,
        updatedAt: DateTime.now(),
      ),
    );
  }
}
