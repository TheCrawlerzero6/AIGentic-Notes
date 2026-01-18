
import '../../domain/dtos/project_dtos.dart';
import '../../domain/entities/task.dart';

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

class TaskProcessingAI extends TaskState {
  final String message;
  TaskProcessingAI({required this.message});
}

class TaskAiSuccess extends TaskState {
  final int tasksCreated;
  final String message;
  TaskAiSuccess({required this.tasksCreated, required this.message});
}
