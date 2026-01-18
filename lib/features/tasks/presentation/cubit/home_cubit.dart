import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import '../../domain/repositories/i_ai_service.dart';
import '../../domain/dtos/project_dtos.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/usecases/process_ai_audio.dart';
import '../../domain/usecases/process_ai_image.dart';
import '../../domain/usecases/process_ai_distribution.dart';
import '../../../../core/constants.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final IProjectRepository repository;
  final AuthCubit authCubit;
  final ProcessAiImageUseCase processImageUseCase;
  final ProcessAiAudioUseCase processAudioUseCase;
  final ProcessAiDistributionUseCase processDistributionUseCase;

  HomeCubit({
    required this.repository,
    required this.authCubit,
    required this.processImageUseCase,
    required this.processAudioUseCase,
    required this.processDistributionUseCase,
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

  Future<void> processWithAI(Uint8List bytes, ContentType contentType) async {
    try {
      final user = authCubit.currentUser;
      if (user == null) {
        debugPrint('Usuario no autenticado');
        return;
      }

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
        await listProjects();
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

      int tasksCreated;
      if (contentType == ContentType.image) {
        tasksCreated = await processImageUseCase(
          imageBytes: bytes,
          projectId: projectId,
        );
      } else if (contentType == ContentType.audio) {
        tasksCreated = await processAudioUseCase(
          audioBytes: bytes,
          projectId: projectId,
        );
      } else {
        debugPrint('Tipo de contenido no soportado: ${contentType.name}');
        return;
      }

      debugPrint('Se crearon $tasksCreated tareas');

      // Recargar proyectos para actualizar UI
      await listProjects();
    } catch (e) {
      debugPrint('Error procesando con IA: $e');
      // Emitir estado de error si es necesario
      if (state is HomeSuccess) {
        emit(HomeError(message: 'Error al procesar: $e'));
      }
    }
  }
}
