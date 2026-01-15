import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class RegisterUsecase {
  final IAuthRepository repository;

  RegisterUsecase(this.repository);

  Future<User?> call(String username, String password) async {
    return await repository.register(username, password);
  }
}
