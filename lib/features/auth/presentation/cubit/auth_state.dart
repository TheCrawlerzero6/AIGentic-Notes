import '../../domain/entities/user.dart';

sealed class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthAuthenticated extends AuthState {
  final User user;
  final int completedTasks;

  final int pendingTasks;
  const AuthAuthenticated(this.user, this.completedTasks, this.pendingTasks);
}

class AuthUnauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
}
