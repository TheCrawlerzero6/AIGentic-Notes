
import '../../../../core/domain/dtos/project_dtos.dart';
import '../../../../core/domain/entities/task.dart';

abstract class TaskState {
  TaskState();
}

class TaskInitial extends TaskState {
  TaskInitial();
}

class TaskLoading extends TaskState {
  TaskLoading();
}

class TaskSuccess extends TaskState {
  final List<Task> tasks;
  final DetailedProjectDto selectedProject;
  TaskSuccess({required this.tasks, required this.selectedProject});
}

class TaskError extends TaskState {
  final String message;
  TaskError({required this.message});
}
