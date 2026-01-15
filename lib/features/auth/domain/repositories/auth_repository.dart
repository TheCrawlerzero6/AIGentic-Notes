import '../entities/user.dart';

abstract class IAuthRepository {
  Future<User?> login(String username, String password);
  
  Future<User?> register(String username, String password);
  Future<void> logout();
  Future<User?> restoreSession();
}
