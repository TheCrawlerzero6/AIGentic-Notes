import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/detail_state.dart';

import '../../domain/dtos/task_dtos.dart';
import '../../domain/entities/task.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/task_repository.dart';

class DetailCubit extends Cubit<DetailState> {
  final ITaskRepository repository;
  final IProjectRepository projectRepository;
  final int taskId;
  DetailCubit({
    required this.repository,
    required this.projectRepository,
    required this.taskId,
  }) : super(DetailInitial());

  Task? get selectedTask {
    if (state is DetailSuccess) {
      return (state as DetailSuccess).selectedTask;
    }
    return null;
  }

  Future<void> updateTask(UpdateTaskDto data) async {
    emit(DetailLoading());

    try {
      if (selectedTask == null) {
        emit(DetailError(message: 'Task con id $taskId no encontrado'));
        return;
      }

      final task = data;

      await repository.updateTask(task.id, task);

      await getTaskDetail();
    } catch (e) {
      emit(DetailError(message: e.toString()));
      rethrow;
    }
  }

  Future<void> deleteTask() async {
    emit(DetailLoading());

    try {
      final task = await repository.getTaskDetail(taskId);
      if (task == null) {
        throw Exception("Task with id $taskId not found");
      }
      await repository.deleteTask(task.id!);
    } catch (e) {
      emit(DetailError(message: e.toString()));
      rethrow;
    }
  }

  void startEdit() {
    if (state is DetailSuccess) {
      emit(
        DetailEdit(
          selectedTask: (state as DetailSuccess).selectedTask,
          selectedProject: (state as DetailSuccess).selectedProject,
        ),
      );
    }
  }

  Future<void> getTaskDetail() async {
    emit(DetailLoading());
    try {
      final task = await repository.getTaskDetail(taskId);
      if (task == null) {
        throw Exception("Task with id $taskId not found");
      }
      final project = await projectRepository.getProjectDetail(task.projectId);
      if (project == null) {
        throw Exception("Project with id ${task.projectId} not found");
      }
      emit(DetailSuccess(selectedTask: task, selectedProject: project));
    } catch (e) {
      emit(DetailError(message: e.toString()));
    }
  }
}
