import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/dtos/task_dtos.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/task_repository.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final ITaskRepository repository;
  final IProjectRepository projectRepository;
  final AuthCubit authCubit;
  final int projectId;
  TaskCubit({
    required this.repository,
    required this.projectRepository,
    required this.authCubit,
    required this.projectId,
  }) : super(TaskInitial());

  Project? get currentUser {
    if (state is TaskSuccess) {
      return (state as TaskSuccess).selectedProject;
    }
    return null;
  }

  Future<void> createTask(
    String title,
    String description,
    DateTime dueDate,
    int priority,
    int projectId,
  ) async {
    emit(TaskLoading());

    try {
      final user = authCubit.currentUser;

      if (user == null) {
        emit(TaskError(message: 'Usuario no autenticado'));
        return;
      }

      final task = CreateTaskDto(
        title: title,
        description: description,
        dueDate: dueDate,
        isCompleted: false,
        sourceType: 'manual',
        priority: 2,
        projectId: projectId,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createTask(task);

      await listTasks();
    } catch (e) {
      emit(TaskError(message: e.toString()));
      rethrow;
    }
  }

  Future<void> listTasks() async {
    emit(TaskLoading());
    try {
      final tasks = await repository.listTasks(projectId);
      final project = await projectRepository.getProjectDetail(projectId);
      if (project == null) {
        throw Exception("Project with id $projectId not found");
      }
      emit(TaskSuccess(tasks: tasks, selectedProject: project));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
}
