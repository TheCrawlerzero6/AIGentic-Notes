import 'package:mi_agenda/features/tasks/domain/dtos/task_dtos.dart';
import 'package:mi_agenda/features/tasks/domain/entities/project.dart';

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
  final Project selectedProject;
  TaskSuccess({required this.tasks, required this.selectedProject});
}

class TaskError extends TaskState {
  final String message;
  TaskError({required this.message});
}
