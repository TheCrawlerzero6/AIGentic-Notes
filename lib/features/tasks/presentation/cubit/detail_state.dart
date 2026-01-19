import 'package:mi_agenda/core/domain/dtos/task_dtos.dart';

import '../../../../core/domain/dtos/project_dtos.dart';

abstract class DetailState {
  DetailState();
}

class DetailInitial extends DetailState {
  DetailInitial();
}

class DetailLoading extends DetailState {
  DetailLoading();
}

class DetailSuccess extends DetailState {
  final DetailedTaskDto selectedTask;
  final DetailedProjectDto selectedProject;
  DetailSuccess({required this.selectedTask, required this.selectedProject});
}

class DetailEdit extends DetailSuccess {
  DetailEdit({required super.selectedTask, required super.selectedProject});
}

class DetailError extends DetailState {
  final String message;
  DetailError({required this.message});
}
