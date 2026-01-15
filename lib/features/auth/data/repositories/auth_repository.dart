import 'package:mi_agenda/features/auth/domain/entities/user.dart';

import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';

class AuthRepository extends IAuthRepository {
  final AuthLocalDatasource datasource;

  AuthRepository({required this.datasource});

  @override
  Future<User?> login(String username, String password) async {
    return await datasource.login(username, password);
  }

  @override
  Future<void> logout() async {
    return await datasource.clearSession();
  }

  @override
  Future<User?> restoreSession() async {
    return await datasource.getSessionUser();
  }

  @override
  Future<User?> register(String username, String password) async {
    return await datasource.register(username, password);
  }
}
