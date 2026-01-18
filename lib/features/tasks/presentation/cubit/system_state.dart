import '../../../../core/domain/entities/task.dart';

abstract class SystemState {
  SystemState();
}

class SystemInitial extends SystemState {
  SystemInitial();
}

class SystemLoading extends SystemState {
  SystemLoading();
}

class SystemSuccess extends SystemState {
  final List<Task> tasks;
  SystemSuccess({required this.tasks});
}

class SystemError extends SystemState {
  final String message;
  SystemError({required this.message});
}
