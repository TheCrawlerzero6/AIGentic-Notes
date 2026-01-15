import 'package:mi_agenda/features/tasks/domain/entities/task.dart';

import '../../domain/repositories/task_repository.dart';
import '../datasources/task_local_datasource.dart';

class TaskRepository extends ITaskRepository {
  final TaskLocalDatasource dataSource;

  TaskRepository({required this.dataSource});

  @override
  Future<int> createTask(Task data) {
    // TODO: implement createTask
    throw UnimplementedError();
  }

  @override
  Future<int> deleteMassiveOldTasks(int id) {
    // TODO: implement deleteMassiveOldTasks
    throw UnimplementedError();
  }

  @override
  Future<int> deleteTask(int id) {
    // TODO: implement deleteTask
    throw UnimplementedError();
  }

  @override
  Future<Task?> getTaskDetail(int id) {
    // TODO: implement getTaskDetail
    throw UnimplementedError();
  }

  @override
  Future<List<Task>> listTasks() {
    // TODO: implement listTasks
    throw UnimplementedError();
  }

  @override
  Future<int> toggleTaskComplete(int id) {
    // TODO: implement toggleTaskComplete
    throw UnimplementedError();
  }

  @override
  Future<int> updateTask(int id, Task data) {
    // TODO: implement updateTask
    throw UnimplementedError();
  }
}
