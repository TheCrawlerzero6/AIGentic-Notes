import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/dtos/project_dtos.dart';
import '../../domain/repositories/project_repository.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final IProjectRepository repository;

  HomeCubit({required this.repository}) : super(HomeInitial());
  Future<void> createDefaultTask() async {
    // final user = authRepository.currentUser;
    // if (user == null) return;

    emit(HomeLoading());

    final project = CreateProjectDto(
      title: 'Nueva tarea',
      description: '',
      icon: 'add',
      themeColor: '0xFAFAFA',
      userId: 1,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    await repository.createProject(project);

    await listProjects(); // recarga la vista
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
