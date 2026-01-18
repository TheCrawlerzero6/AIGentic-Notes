import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/system_state.dart';

import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../domain/repositories/project_repository.dart';
import '../../domain/repositories/task_repository.dart';

class SystemCubit extends Cubit<SystemState> {
  final ITaskRepository repository;
  final IProjectRepository projectRepository;
  final AuthCubit authCubit;
  SystemCubit({
    required this.repository,
    required this.projectRepository,
    required this.authCubit,
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
      await repository.toggleTaskComplete(id);
      final tasks = await repository.listAllTasks();
      emit(SystemSuccess(tasks: tasks));
    } catch (e) {
      emit(SystemError(message: e.toString()));
    }
  }
}
