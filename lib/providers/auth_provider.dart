import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../data/local/database_helper.dart';
import '../data/models/user_model.dart';

/// Provider de autenticación de usuarios
///
/// Gestiona el estado de autenticación, login, registro y sesión activa.
class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;

  /// Usuario actualmente autenticado
  UserModel? get currentUser => _currentUser;

  /// Verifica si hay un usuario logueado
  bool get isAuthenticated => _currentUser != null;

  /// Hashea una contraseña usando SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Registra un nuevo usuario
  /// 
  /// Returns: true si el registro fue exitoso, false si el usuario ya existe
  Future<bool> register(String username, String password) async {
    try {
      final db = DatabaseHelper.instance;
      
      // Verificar si el usuario ya existe
      final existing = await db.getUserByUsername(username);
      if (existing != null) {
        return false;
      }

      // Crear nuevo usuario
      final hashedPassword = _hashPassword(password);
      final newUser = UserModel(
        username: username,
        passwordHash: hashedPassword,
        createdAt: DateTime.now(),
      );

      final userId = await db.insertUser(newUser);
      
      // Autenticar automáticamente después del registro
      _currentUser = newUser.copyWith(id: userId);
      notifyListeners();
      
      return true;
    } catch (e) {
      debugPrint('Error al registrar usuario: $e');
      rethrow;
    }
  }

  /// Inicia sesión con username y contraseña
  /// 
  /// Returns: true si las credenciales son correctas, false en caso contrario
  Future<bool> login(String username, String password) async {
    try {
      final db = DatabaseHelper.instance;
      final user = await db.getUserByUsername(username);

      if (user == null) {
        return false;
      }

      final hashedPassword = _hashPassword(password);
      if (user.passwordHash != hashedPassword) {
        return false;
      }

      _currentUser = user;
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al iniciar sesión: $e');
      rethrow;
    }
  }

  /// Cierra sesión del usuario actual
  Future<void> logout() async {
    _currentUser = null;
    notifyListeners();
  }

  /// Verifica si hay una sesión activa (para SplashScreen futuro)
  Future<bool> checkSession() async {
    // Por ahora no hay persistencia de sesión
    // En el futuro se puede usar SharedPreferences para guardar el userId
    return false;
  }
}
