import '../../domain/dtos/task_dtos.dart';

import '../entities/task.dart';

abstract class ITaskRepository {
  
  Future<List<Task>> listAllTasks();
  Future<List<Task>> listTasks(int projectId);
  Future<Task?> getTaskDetail(int id);

  Future<int> createTask(CreateTaskDto data);
  Future<int> createTasksBatch(List<CreateTaskDto> tasks);
  Future<int> updateTask(int id, UpdateTaskDto data);
  Future<int> deleteTask(int id);

  Future<int> toggleTaskComplete(int id);
  Future<int> deleteMassiveOldTasks(int id);
}
