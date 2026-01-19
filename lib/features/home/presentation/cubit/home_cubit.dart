import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/repositories/i_ai_service.dart';
import '../../../../core/domain/dtos/project_dtos.dart';
import '../../../../core/domain/repositories/project_repository.dart';
import '../../domain/usecases/process_ai_audio.dart';
import '../../domain/usecases/process_ai_image.dart';
import '../../domain/usecases/process_ai_distribution.dart';
import '../../../../core/constants.dart';
import '../../../../core/data/services/notification_service.dart';
import '../../../../core/domain/entities/task.dart';
import '../../../../core/domain/repositories/task_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final IProjectRepository repository;
  final ITaskRepository taskRepository;
  final AuthCubit authCubit;
  final ProcessAiImageUseCase processImageUseCase;
  final ProcessAiAudioUseCase processAudioUseCase;
  final ProcessAiDistributionUseCase processDistributionUseCase;
  final NotificationService notificationService;

  HomeCubit({
    required this.repository,
    required this.taskRepository,
    required this.authCubit,
    required this.processImageUseCase,
    required this.processAudioUseCase,
    required this.processDistributionUseCase,
    required this.notificationService,
  }) : super(HomeInitial());

  User? get currentUser {
    final state = authCubit.state;
    if (state is AuthAuthenticated) {
      return state.user;
    }
    return null;
  }

  Future<void> createProject(String title) async {
    emit(HomeLoading());

    try {
      final user = authCubit.currentUser;

      if (user == null) {
        emit(HomeError(message: 'Usuario no autenticado'));
        return;
      }

      final project = CreateProjectDto(
        title: title,
        description: "",
        icon: 'add',
        themeColor: '0xFAFAFA',
        userId: user.id!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await repository.createProject(project);

      await listProjects();
    } catch (e) {
      emit(HomeError(message: e.toString()));
      rethrow;
    }
  }

  Future<void> listProjects() async {
    emit(HomeLoading());
    try {
      final projects = await repository.listProjects();

      emit(HomeSuccess(projects: projects));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  /// OPTIMIZACIÓN: Programa notificaciones en paralelo y actualiza IDs en batch
  Future<void> _scheduleNotificationsForTasks(List<Task> tasks) async {
    debugPrint('[DIAGNÓSTICO] _scheduleNotificationsForTasks llamado con ${tasks.length} tareas');
    
    if (tasks.isEmpty) {
      debugPrint('[DIAGNÓSTICO] Lista de tareas vacía, abortando programación de notificaciones');
      return;
    }

    final now = DateTime.now();
    debugPrint('[DIAGNÓSTICO] Fecha actual: $now');
    
    for (var i = 0; i < tasks.length; i++) {
      final task = tasks[i];
      debugPrint('[DIAGNÓSTICO] Tarea $i: id=${task.id}, title=${task.title}, dueDate=${task.dueDate}');
    }
    
    final Map<int, int> taskIdToNotificationId = {};

    // OPTIMIZACIÓN 1: Programar notificaciones en paralelo usando Future.wait
    final notificationFutures = <Future<void>>[];
    
    for (final task in tasks) {
      // Convertir ambas fechas a local para comparación correcta
      final taskDueDate = task.dueDate?.toLocal();
      final isValidForScheduling = taskDueDate != null && taskDueDate.isAfter(now);
      
      debugPrint('[DIAGNÓSTICO] Tarea ${task.id}: dueDate local=$taskDueDate, isAfter=$isValidForScheduling');
      
      if (isValidForScheduling) {
        final future = notificationService.scheduleNotification(
          title: 'Recordatorio: ${task.title}',
          body: task.description?.isNotEmpty == true ? task.description! : 'Tarea pendiente',
          scheduledDate: taskDueDate!,
          payload: 'task_reminder',
        ).then((notificationId) {
          taskIdToNotificationId[task.id!] = notificationId;
          debugPrint('[DIAGNÓSTICO] Notificación programada exitosamente para tarea ${task.id}: notificationId=$notificationId');
        }).catchError((e) {
          debugPrint('[ERROR] Error programando notificación para tarea ${task.id}: $e');
        });
        
        notificationFutures.add(future);
      }
    }

    // Esperar a que todas las notificaciones se programen en paralelo
    await Future.wait(notificationFutures);

    // OPTIMIZACIÓN 2: Actualizar todos los notificationId en 1 transacción
    if (taskIdToNotificationId.isNotEmpty) {
      try {
        debugPrint('[DIAGNÓSTICO] Iniciando batch update de ${taskIdToNotificationId.length} notificationIds');
        await taskRepository.batchUpdateNotificationIds(taskIdToNotificationId);
        debugPrint('[DIAGNÓSTICO] Batch update completado: ${taskIdToNotificationId.length} notificaciones programadas y guardadas');
      } catch (e) {
        debugPrint('[ERROR] Error actualizando notificationIds: $e');
      }
    } else {
      debugPrint('[DIAGNÓSTICO] No hay notificationIds para actualizar');
    }
  }

  Future<void> processWithAI(Uint8List bytes, ContentType contentType) async {
    try {
      final user = authCubit.currentUser;
      if (user == null) {
        debugPrint('Usuario no autenticado');
        return;
      }

      // Emitir estado de procesamiento para mostrar indicador visual
      emit(HomeProcessingAI(contentType: contentType.name));

      // Obtener el primer proyecto del usuario (o crear uno por defecto)
      var projects = await repository.listProjects();

      if (Constants.INTELLIGENT_DISTRIBUTION &&
          contentType != ContentType.file) {
        final result = await processDistributionUseCase(
          bytes: bytes,
          contentType: contentType,
          userId: user.id!,
          existingProjects: projects,
        );

        debugPrint(
          'Distribución completada: ${result.tasksCreated} tareas, ${result.projectsCreated} proyectos nuevos',
        );
        debugPrint('[DIAGNÓSTICO] HomeCubit: result.createdTasks.length = ${result.createdTasks.length}');

        // NUEVA: Programar notificaciones para las tareas creadas
        await _scheduleNotificationsForTasks(result.createdTasks);

        final updatedProjects = await repository.listProjects();
        emit(HomeSuccess(projects: updatedProjects));
        return;
      }

      int projectId;
      if (projects.isNotEmpty) {
        projectId = projects.first.id;
      } else {
        final now = DateTime.now();
        await repository.createProject(
          CreateProjectDto(
            title: 'Inbox',
            description: '',
            icon: 'add',
            themeColor: '0xFAFAFA',
            userId: user.id!,
            createdAt: now,
            updatedAt: now,
          ),
        );
        projects = await repository.listProjects();
        if (projects.isEmpty) {
          debugPrint('No fue posible crear un proyecto por defecto');
          return;
        }
        projectId = projects.first.id;
      }
      debugPrint('Procesando ${contentType.name} en proyecto $projectId');

      List<Task> createdTasks;
      if (contentType == ContentType.image) {
        createdTasks = await processImageUseCase(
          imageBytes: bytes,
          projectId: projectId,
        );
      } else if (contentType == ContentType.audio) {
        createdTasks = await processAudioUseCase(
          audioBytes: bytes,
          projectId: projectId,
        );
      } else {
        debugPrint('Tipo de contenido no soportado: ${contentType.name}');
        return;
      }

      debugPrint('Se crearon ${createdTasks.length} tareas');
      debugPrint('[DIAGNÓSTICO] HomeCubit: createdTasks.length = ${createdTasks.length}');

      // NUEVA: Programar notificaciones para las tareas creadas
      await _scheduleNotificationsForTasks(createdTasks);

      // Recargar proyectos para actualizar UI sin pasar por HomeLoading
      final updatedProjects = await repository.listProjects();
      emit(HomeSuccess(projects: updatedProjects));
    } catch (e) {
      debugPrint('Error procesando con IA: $e');
      // Emitir estado de error si es necesario
      if (state is HomeSuccess) {
        emit(HomeError(message: 'Error al procesar: $e'));
      }
    }
  }
}
