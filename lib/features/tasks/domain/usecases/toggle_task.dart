import '../../../../core/domain/repositories/task_repository.dart';

class ToggleTask {
  final ITaskRepository repository;

  ToggleTask(this.repository);

  Future<int> call(int id) {
    return repository.toggleTaskComplete(id);
  }
}
