import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/system_state.dart';
import 'package:flutter/foundation.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../../core/domain/repositories/project_repository.dart';
import '../../../../core/domain/repositories/task_repository.dart';
import '../../../../core/domain/dtos/task_dtos.dart';
import '../../../../core/data/services/notification_service.dart';

class SystemCubit extends Cubit<SystemState> {
  final ITaskRepository repository;
  final IProjectRepository projectRepository;
  final AuthCubit authCubit;
  final NotificationService notificationService;

  SystemCubit({
    required this.repository,
    required this.projectRepository,
    required this.authCubit,
    required this.notificationService,
  }) : super(SystemInitial());

  // Future<void> createTask(String title, DateTime dueDate) async {
  //   emit(SystemLoading());

  //   try {
  //     final user = authCubit.currentUser;

  //     if (user == null) {
  //       emit(SystemError(message: 'Usuario no autenticado'));
  //       return;
  //     }

  //     final task = CreateTaskDto(
  //       title: title,
  //       description: null,
  //       dueDate: dueDate,
  //       isCompleted: false,
  //       sourceType: 'manual',
  //       priority: 2,
  //       projectId: projectId,
  //       createdAt: DateTime.now(),
  //       updatedAt: DateTime.now(),
  //     );

  //     await repository.createTask(task);

  //     await listTasks();
  //   } catch (e) {
  //     emit(SystemError(message: e.toString()));
  //     rethrow;
  //   }
  // }

  Future<void> listTasks() async {
    emit(SystemLoading());
    try {
      final tasks = await repository.listAllTasks();
      emit(SystemSuccess(tasks: tasks));
    } catch (e) {
      emit(SystemError(message: e.toString()));
    }
  }

  Future<void> toggleTask(int id) async {
    emit(SystemLoading());
    try {
      final currentTask = await repository.getTaskDetail(id);
      if (currentTask == null) {
        throw Exception('Tarea no encontrada');
      }

      final willBeCompleted = !currentTask.isCompleted;

      if (willBeCompleted && currentTask.notificationId != null) {
        try {
          await notificationService.cancelNotification(
            currentTask.notificationId!,
          );
        } catch (e) {
          debugPrint('Error al cancelar notificacion: $e');
        }
      } else if (!willBeCompleted &&
          currentTask.dueDate != null &&
          currentTask.dueDate!.isAfter(DateTime.now())) {
        try {
          final newNotificationId = await notificationService
              .scheduleNotification(
                title: 'Recordatorio: ${currentTask.title}',
                body: currentTask.description ?? 'Tarea pendiente',
                scheduledDate: currentTask.dueDate!,
                payload: 'task_reminder',
              );

          await repository.updateTask(
            id,
            UpdateTaskDto(
              id: id,
              notificationId: newNotificationId,
              updatedAt: DateTime.now(),
            ),
          );
        } catch (e) {
          debugPrint('Error al reprogramar notificacion: $e');
        }
      }

      await repository.toggleTaskComplete(id);
      final tasks = await repository.listAllTasks();
      emit(SystemSuccess(tasks: tasks));
    } catch (e) {
      emit(SystemError(message: e.toString()));
    }
  }
}
