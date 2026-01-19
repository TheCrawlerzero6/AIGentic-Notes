import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/core/domain/dtos/project_dtos.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/domain/dtos/task_dtos.dart';
import '../../../../core/domain/repositories/project_repository.dart';
import '../../../../core/domain/repositories/task_repository.dart';
import '../../../../core/data/services/notification_service.dart';
import 'task_state.dart';

class TaskCubit extends Cubit<TaskState> {
  final ITaskRepository repository;
  final IProjectRepository projectRepository;
  final AuthCubit authCubit;
  final NotificationService notificationService;
  final int projectId;
  
  TaskCubit({
    required this.repository,
    required this.projectRepository,
    required this.authCubit,
    required this.notificationService,
    required this.projectId,
  }) : super(TaskInitial());

  DetailedProjectDto? get selectedProject {
    if (state is TaskSuccess) {
      return (state as TaskSuccess).selectedProject;
    }
    return null;
  }

  Future<void> createTask(String title, DateTime dueDate) async {
    emit(TaskLoading());

    try {
      final user = authCubit.currentUser;

      if (user == null) {
        emit(TaskError(message: 'Usuario no autenticado'));
        return;
      }

      int? notificationId;
      if (dueDate.isAfter(DateTime.now())) {
        try {
          notificationId = await notificationService.scheduleNotification(
            title: 'Recordatorio: $title',
            body: 'Tarea pendiente',
            scheduledDate: dueDate,
            payload: 'task_reminder',
          );
        } catch (e) {
          debugPrint('Error al programar notificacion: $e');
        }
      }

      final task = CreateTaskDto(
        title: title,
        description: null,
        dueDate: dueDate,
        isCompleted: false,
        notificationId: notificationId,
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

  Future<void> deleteProject(VoidCallback onDeleted) async {
    if (state is TaskSuccess) {
      final projectId = (state as TaskSuccess).selectedProject.id;
      await repository.deleteProjectAndTasks(projectId);
      onDeleted();
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

  Future<void> toggleTask(int id) async {
    emit(TaskLoading());
    try {
      final currentTask = await repository.getTaskDetail(id);
      if (currentTask == null) {
        throw Exception('Tarea no encontrada');
      }

      final willBeCompleted = !currentTask.isCompleted;

      if (willBeCompleted && currentTask.notificationId != null) {
        try {
          await notificationService.cancelNotification(currentTask.notificationId!);
        } catch (e) {
          debugPrint('Error al cancelar notificacion: $e');
        }
      } else if (!willBeCompleted && currentTask.dueDate != null && currentTask.dueDate!.isAfter(DateTime.now())) {
        try {
          final newNotificationId = await notificationService.scheduleNotification(
            title: 'Recordatorio: ${currentTask.title}',
            body: currentTask.description ?? 'Tarea pendiente',
            scheduledDate: currentTask.dueDate!,
            payload: 'task_reminder',
          );
          
          await repository.updateTask(id, UpdateTaskDto(
            id: id,
            notificationId: newNotificationId,
            updatedAt: DateTime.now(),
          ));
        } catch (e) {
          debugPrint('Error al reprogramar notificacion: $e');
        }
      }

      await repository.toggleTaskComplete(id);
      final tasks = await repository.listTasks(projectId);
      final project = await projectRepository.getProjectDetail(projectId);
      if (project == null) {
        throw Exception('Proyecto no encontrado');
      }
      emit(TaskSuccess(tasks: tasks, selectedProject: project));
    } catch (e) {
      emit(TaskError(message: e.toString()));
    }
  }
}
