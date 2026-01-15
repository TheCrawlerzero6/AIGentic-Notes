import '../dtos/user_dtos.dart';

import '../entities/user.dart';

abstract class IUserRepository {
  Future<List<User>> listUsers();
  Future<User?> getUserDetail(int id);
  Future<int> createUser(CreateUserDto data);
  Future<int> updateUser(UpdateUserDto data);
  Future<int> deleteUser(int id);
}
