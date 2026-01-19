import 'package:flutter/foundation.dart';
import 'package:mi_agenda/core/data/models/task_model.dart';
import 'package:mi_agenda/core/domain/dtos/task_dtos.dart';
import 'package:mi_agenda/core/domain/entities/task.dart';
import 'package:mi_agenda/core/domain/repositories/task_repository.dart';
import 'package:intl/intl.dart';

import '../datasources/task_local_datasource.dart';

class TaskRepository extends ITaskRepository {
  final TaskLocalDatasource dataSource;

  TaskRepository({required this.dataSource});

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

    final taskModels = tasks.map((data) => TaskModel(
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
    )).toList();

    // OPTIMIZACIÓN: Usa insertBatch que retorna List<Task> con IDs
    final createdTasks = await dataSource.insertBatch(taskModels);
    return createdTasks;
  }

  @override
  Future<void> batchUpdateNotificationIds(Map<int, int> taskIdToNotificationId) async {
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
    return DetailedTaskDto(
      id: task.id!,
      title: task.title,
      description: task.description,
      dueDate: task.dueDate,
      isCompleted: task.isCompleted,
      completedAt: task.completedAt,
      notificationId: task.notificationId,
      sourceType: task.sourceType,
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
    await database.rawDelete(
      'DELETE FROM tasks WHERE projectId = ?',
      [projectId],
    );
    final deletedProject = await database.rawDelete(
      'DELETE FROM projects WHERE id = ?',
      [projectId],
    );
    return deletedProject;
  }

  @override
  Future<int> scheduleNotification(int id, DateTime notifDate) async {
    final currentTask = await dataSource.getDetail(id);
    
    if (currentTask.dueDate == null) {
      throw Exception('La tarea no tiene fecha de vencimiento');
    }

    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    await dataSource.update(
      TaskModel(
        id: id,
        title: currentTask.title,
        description: currentTask.description,
        dueDate: currentTask.dueDate,
        isCompleted: currentTask.isCompleted,
        notificationId: notificationId,
        sourceType: currentTask.sourceType,
        priority: currentTask.priority,
        projectId: currentTask.projectId,
        createdAt: currentTask.createdAt,
        updatedAt: DateTime.now(),
      ),
    );

    debugPrint('NotificationId $notificationId guardado en BD');
    return notificationId;
  }
}
