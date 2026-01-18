import 'package:mi_agenda/features/tasks/data/models/task_model.dart';
import 'package:mi_agenda/features/tasks/domain/dtos/task_dtos.dart';
import 'package:mi_agenda/features/tasks/domain/entities/task.dart';

import '../../domain/repositories/task_repository.dart';
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
        sourceType: data.sourceType,
        priority: data.priority,
        projectId: data.projectId,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      ),
    );
  }

  @override
  Future<int> createTasksBatch(List<CreateTaskDto> tasks) async {
    if (tasks.isEmpty) return 0;

    final database = await dataSource.db.database;
    int insertedCount = 0;

    await database.transaction((txn) async {
      for (var data in tasks) {
        final taskModel = TaskModel(
          title: data.title,
          description: data.description,
          dueDate: data.dueDate,
          isCompleted: data.isCompleted,
          sourceType: data.sourceType,
          priority: data.priority,
          projectId: data.projectId,
          createdAt: data.createdAt,
          updatedAt: data.updatedAt,
        );

        await txn.insert('tasks', taskModel.toMap());
        insertedCount++;
      }
    });

    return insertedCount;
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
  Future<Task?> getTaskDetail(int id) async {
    return await dataSource.getDetail(id);
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

    return await dataSource.toggleTaskComplete(id, !currentTask.isCompleted);
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
}
