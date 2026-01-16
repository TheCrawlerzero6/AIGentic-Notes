import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/dtos/project_dtos.dart';
import '../../domain/repositories/project_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final IProjectRepository repository;
  final AuthCubit authCubit;

  HomeCubit({required this.repository, required this.authCubit})
    : super(HomeInitial());
  Future<void> createTask(
    String title,
    String description,
    DateTime dueDate,
    int priority,
  ) async {
    emit(HomeLoading());

    try {
      final user = authCubit.currentUser;

      if (user == null) {
        emit(HomeError(message: 'Usuario no autenticado'));
        return;
      }

      final project = CreateProjectDto(
        title: title,
        description: description,
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
}
