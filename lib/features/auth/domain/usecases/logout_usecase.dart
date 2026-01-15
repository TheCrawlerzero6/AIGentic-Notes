import '../repositories/auth_repository.dart';

class LogoutUsecase {
  final IAuthRepository repository;

  LogoutUsecase(this.repository);

  Future<void> call() async {
    return await repository.logout();
  }
}
