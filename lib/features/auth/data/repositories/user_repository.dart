import 'package:mi_agenda/features/auth/domain/dtos/user_dtos.dart';
import 'package:mi_agenda/features/auth/domain/entities/user.dart';

import '../../domain/repositories/user_repository.dart';
import '../datasources/user_local_datasource.dart';
import '../models/user_model.dart';

class UserRepository extends IUserRepository {
  final UserLocalDatasource datasource;

  UserRepository({required this.datasource});

  @override
  Future<int> createUser(CreateUserDto data) async {
    return await datasource.insert(
      UserModel(
        username: data.username,
        passwordHash: data.passwordHash,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<int> deleteUser(int id) async {
    return await datasource.delete(id);
  }

  @override
  Future<User?> getUserDetail(int id) async {
    return await datasource.getUserById(id);
  }

  @override
  Future<List<User>> listUsers() async {
    return await datasource.getAll();
  }

  @override
  Future<int> updateUser(UpdateUserDto data) async {
    final currentUser = await datasource.getUserById(data.id);
    if (currentUser != null) {
      return await datasource.update(UserModel(
        id: data.id,
        username: data.username ?? currentUser.username, 
        passwordHash: data.passwordHash ?? currentUser.passwordHash, 
        createdAt: currentUser.createdAt, 
        updatedAt: DateTime.now()));
    } else {
      throw Exception("User with id ${data.id} not found");
    }
  }
}
