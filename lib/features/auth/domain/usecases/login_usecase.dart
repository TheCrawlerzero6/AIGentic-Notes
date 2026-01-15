import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class LoginUsecase {
  final IAuthRepository repository;

  LoginUsecase(this.repository);

  Future<User?> call(String username, String password) async {
    return await repository.login(username, password);
  }
}
