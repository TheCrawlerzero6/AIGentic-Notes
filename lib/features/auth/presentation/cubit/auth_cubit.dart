import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mi_agenda/features/auth/domain/usecases/register_usercase.dart';
import 'package:mi_agenda/core/domain/repositories/task_repository.dart';

import '../../domain/entities/user.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/restore_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase login;
  final RegisterUsecase register;
  final RestoreSession restoreSession;
  final LogoutUsecase logout;
  final ITaskRepository taskRepository;
  AuthCubit({
    required this.login,
    required this.register,
    required this.restoreSession,
    required this.logout,
    required this.taskRepository,
  }) : super(AuthInitial());

  User? get currentUser {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).user;
    }
    return null;
  }

  int get completedTasks {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).completedTasks;
    }
    return 0;
  }

  int get pendingTasks {
    if (state is AuthAuthenticated) {
      return (state as AuthAuthenticated).pendingTasks;
    }
    return 0;
  }

  Future<void> checkSession() async {
    emit(AuthLoading());

    final user = await restoreSession();
    if (user != null) {
      final tasks = await taskRepository.listAllTasks();
      int completedTasks = tasks.where((task) => task.isCompleted).length;
      int pendingTasks = tasks.where((task) => !task.isCompleted).length;

      emit(AuthAuthenticated(user, completedTasks, pendingTasks));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String username, String password) async {
    emit(AuthLoading());
    try {
      final user = await login(username, password); // login del datasource

      if (user != null) {
        final tasks = await taskRepository.listAllTasks();
        int completedTasks = tasks.where((task) => task.isCompleted).length;
        int pendingTasks = tasks.where((task) => !task.isCompleted).length;

        emit(AuthAuthenticated(user, completedTasks, pendingTasks));
      } else {
        emit(const AuthError('Credenciales inválidas'));
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signUp(String username, String password) async {
    emit(AuthLoading());

    try {
      final user = await register(username, password);

      if (user == null) {
        emit(AuthError("Ocurrió un error registrando al usuario"));
        emit(AuthUnauthenticated());
      } else {
        final tasks = await taskRepository.listAllTasks();
        int completedTasks = tasks.where((task) => task.isCompleted).length;
        int pendingTasks = tasks.where((task) => !task.isCompleted).length;

        emit(AuthAuthenticated(user, completedTasks, pendingTasks));
      }
    } on Exception catch (e) {
      emit(AuthError(e.toString()));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signOut() async {
    await logout();
    emit(AuthUnauthenticated());
  }
}
