import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants.dart';
import '../../../../core/services/sqlite_service.dart';
import '../models/user_model.dart';

class AuthLocalDatasource {
  final SqliteService db;
  final SharedPreferences prefs;
  static const _prefKeyUserId = 'userId';

  AuthLocalDatasource({required this.db, required this.prefs});
  Future<UserModel?> register(String username, String password) async {
    try {
      final userMap = await db.getRecord(
        tableName: Constants.tableUsers,
        whereClause: "username = ?",
        whereArgs: [username],
      );

      if (userMap != null) {
        throw Exception("User with username $username already exists");
      }
      final hashedPassword = _hashPassword(password);

      final user = new UserModel(
        username: username,
        passwordHash: hashedPassword,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      final createdId = await db.insertRegistry(
        tableName: Constants.tableUsers,
        entity: user.toMap(),
      );
      await _saveSession(createdId);

      return user;
    } catch (e) {
      debugPrint('Error al registrar: $e');
      rethrow;
    }
  }

  Future<UserModel?> login(String username, String password) async {
    try {
      final userMap = await db.getRecord(
        tableName: Constants.tableUsers,
        whereClause: "username = ?",
        whereArgs: [username],
      );

      if (userMap == null) {
        throw Exception("User with username $username not registered");
      }
      final user = UserModel.fromMap(userMap);
      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        throw Exception("Incorrect password");
      }

      await _saveSession(user.id!);

      return user;
    } catch (e) {
      debugPrint('Error al iniciar sesión: $e');
      rethrow;
    }
  }

  Future<UserModel?> getSessionUser() async {
    try {
      final userId = prefs.getInt(_prefKeyUserId);
      if (userId == null) {
        return null;
      }

      final user = await db.getRecord(
        tableName: Constants.tableUsers,
        id: userId,
      );

      if (user != null) {
        return UserModel.fromMap(user);
      }

      await clearSession();
      return null;
    } catch (e) {
      debugPrint('Error al verificar sesión: $e');
      return null;
    }
  }

  Future<void> clearSession() async {
    await prefs.remove('userId');
  }

  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> _saveSession(int userId) async {
    await prefs.setInt(_prefKeyUserId, userId);
    debugPrint('Sesión guardada para userId: $userId');
  }
}
