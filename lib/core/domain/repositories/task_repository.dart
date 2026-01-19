import '../dtos/task_dtos.dart';

import '../entities/task.dart';

abstract class ITaskRepository {
  Future<List<Task>> listAllTasks();
  Future<List<Task>> listTasks(int projectId);
  Future<DetailedTaskDto?> getTaskDetail(int id);

  Future<int> createTask(CreateTaskDto data);
  Future<List<Task>> createTasksBatch(List<CreateTaskDto> tasks);
  Future<void> batchUpdateNotificationIds(Map<int, int> taskIdToNotificationId);
  Future<int> updateTask(int id, UpdateTaskDto data);
  Future<int> deleteTask(int id);
  Future<dynamic> getDatabase();

  Future<int> toggleTaskComplete(int id);
  Future<int> deleteProjectAndTasks(int projectId);
  Future<int> deleteMassiveOldTasks(int id);
  Future<int> scheduleNotification(int id, DateTime notifDate);
}
