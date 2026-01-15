import 'package:flutter/foundation.dart';
import '/core/datasources/base_local_datasource.dart';
import '../models/user_model.dart';
import '../../../../core/constants.dart';

class UserLocalDatasource extends BaseLocalDataSource<UserModel> {
  UserLocalDatasource({required super.db})
    : super(tableName: Constants.tableUsers);

  Future<UserModel?> getUserByUsername(String username) async {
    final record = await db.getRecord(
      tableName: tableName,
      whereClause: "username = ?",
      whereArgs: [username],
    );
    if (record != null) {
      return UserModel.fromMap(record);
    }

    return null;
  }

  Future<UserModel?> getUserById(int id) async {
    final record = await db.getRecord(tableName: tableName, id: id);
    if (record != null) {
      return UserModel.fromMap(record);
    }

    return null;
  }

  @override
  Future<int> delete(int id) async {
    final deletedId = await db.deleteRegistry(tableName: tableName, id: id);
    return deletedId;
  }

  @override
  Future<List<UserModel>> getAll() async {
    final records = await db.getAllRecords(tableName: tableName);
    return records.map((map) => UserModel.fromMap(map)).toList();
  }

  @override
  Future<int> insert(UserModel data) async {
    try {
      final id = await db.insertRegistry(
        tableName: tableName,
        entity: data.toMap(),
      );
      debugPrint('Usuario creado con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error al insertar usuario: $e');
      rethrow;
    }
  }

  @override
  Future<int> update(UserModel data) async {
    try {
      if (data.id == null || data.id! < 1) {
        throw Exception(
          "Este usuario no tiene un id registrado, porque aún no ha sido creado",
        );
      }

      final id = await db.updateRegistry(
        tableName: tableName,
        id: data.id!,
        entity: data.toMap(),
      );
      debugPrint('Usuario actualizado con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error al actualizar usuario: $e');
      rethrow;
    }
  }
}
