import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RestoreSession {
  final IAuthRepository repository;

  RestoreSession(this.repository);

  Future<User?> call() async {
    return await repository.restoreSession();
  }
}
