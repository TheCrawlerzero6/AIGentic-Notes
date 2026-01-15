import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mi_agenda/features/auth/domain/usecases/register_usercase.dart';

import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/restore_session.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUsecase login;
  final RegisterUsecase register;
  final RestoreSession restoreSession;
  final LogoutUsecase logout;

  AuthCubit({
    required this.login,
    required this.register,
    required this.restoreSession,
    required this.logout,
  }) : super(AuthInitial());

  Future<void> checkSession() async {
    emit(AuthLoading());

    final user = await restoreSession();
    if (user != null) {
      emit(AuthAuthenticated(user));
    } else {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> signIn(String username, String password) async {
    emit(AuthLoading());
    try {
      print("LOGGING IN");
      final user = await login(username, password); // login del datasource
      if (user != null) {
        emit(AuthAuthenticated(user));
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
        emit(AuthAuthenticated(user));
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
