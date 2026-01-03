import 'package:flutter/foundation.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/local/database_helper.dart';
import '../data/models/user_model.dart';

/// Provider de autenticación de usuarios
///
/// Gestiona el estado de autenticación, login, registro y sesión activa.
/// PERSISTENCIA: Guarda sesión en SharedPreferences hasta logout manual.
class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  static const _prefKeyUserId = 'userId';

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
      
      // Guardar sesión
      await _saveSession(userId);
      
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
      
      // Guardar sesión en SharedPreferences
      await _saveSession(user.id!);
      
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
    
    // Limpiar SharedPreferences
    await _clearSession();
    
    notifyListeners();
  }

  /// Verifica si hay una sesión activa guardada
  /// Restaura la sesión si existe un userId válido
  Future<bool> checkSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_prefKeyUserId);
      
      if (userId == null) {
        return false;
      }
      
      // Restaurar usuario desde DB
      final db = DatabaseHelper.instance;
      final user = await db.getUserById(userId);
      
      if (user != null) {
        _currentUser = user;
        // NO llamar a notifyListeners() aquí para evitar loop infinito
        return true;
      }
      
      // Si el usuario no existe en DB, limpiar sesión
      await _clearSession();
      return false;
    } catch (e) {
      debugPrint('Error al verificar sesión: $e');
      return false;
    }
  }
  
  // ========== MÉTODOS PRIVADOS ==========
  
  /// Guarda el userId en SharedPreferences
  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyUserId, userId);
    debugPrint('Sesión guardada para userId: $userId');
  }
  
  /// Limpia la sesión de SharedPreferences
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKeyUserId);
    debugPrint('Sesión limpiada');
  }
}
