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
  TaskSuccess({required this.tasks});
}

class TaskError extends TaskState {
  final String message;
  TaskError({required this.message});
}
