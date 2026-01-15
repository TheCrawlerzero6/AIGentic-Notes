import '../entities/task.dart';

abstract class ITaskRepository {
  Future<List<Task>> listTasks();
  Future<Task?> getTaskDetail(int id);
  
  Future<int> createTask(Task data);
  Future<int> updateTask(int id, Task data);
  Future<int> deleteTask(int id);

  Future<int> toggleTaskComplete(int id);
  Future<int> deleteMassiveOldTasks(int id);
}
