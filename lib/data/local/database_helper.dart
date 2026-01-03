import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_model.dart';
import '../models/task_model.dart';
import '../../core/constants/app_constants.dart';

/// Helper para gestionar la base de datos SQLite
/// Implementa el patrón Singleton
class DatabaseHelper {
  // Singleton
  static final DatabaseHelper instance = DatabaseHelper._internal();
  factory DatabaseHelper() => instance;
  DatabaseHelper._internal();

  static Database? _database;

  /// Obtiene la instancia de la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, AppConstants.dbName);

    return await openDatabase(
      path,
      version: AppConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas al crear la base de datos
  Future<void> _onCreate(Database db, int version) async {
    // Tabla users
    await db.execute('''
      CREATE TABLE ${AppConstants.tableUsers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    // Tabla tasks
    await db.execute('''
      CREATE TABLE ${AppConstants.tableTasks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        description TEXT,
        due_date TEXT NOT NULL,
        is_completed INTEGER NOT NULL DEFAULT 0,
        completed_at TEXT,
        notification_id INTEGER,
        source_type TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 2,
        FOREIGN KEY (user_id) REFERENCES ${AppConstants.tableUsers} (id) ON DELETE CASCADE
      )
    ''');

    debugPrint('Base de datos creada con éxito');
  }

  /// Actualiza la base de datos en versiones futuras
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Actualizando BD de versión $oldVersion a $newVersion');
  }

  /// Inserta un nuevo usuario
  Future<int> insertUser(UserModel user) async {
    final db = await database;
    try {
      final id = await db.insert(
        AppConstants.tableUsers,
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      debugPrint('Usuario creado con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error al insertar usuario: $e');
      rethrow;
    }
  }

  /// Obtiene un usuario por username
  Future<UserModel?> getUserByUsername(String username) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableUsers,
      where: 'username = ?',
      whereArgs: [username],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  /// Obtiene un usuario por ID
  Future<UserModel?> getUserById(int id) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableUsers,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;
    return UserModel.fromMap(result.first);
  }

  /// Obtiene todos los usuarios (para debug)
  Future<List<UserModel>> getAllUsers() async {
    final db = await database;
    final result = await db.query(AppConstants.tableUsers);
    return result.map((map) => UserModel.fromMap(map)).toList();
  }

  /// Inserta una nueva tarea
  Future<int> insertTask(TaskModel task) async {
    final db = await database;
    try {
      final id = await db.insert(
        AppConstants.tableTasks,
        task.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      debugPrint('Tarea creada con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error al insertar tarea: $e');
      rethrow;
    }
  }

  /// Obtiene todas las tareas de un usuario con la REGLA DE 48 HORAS
  /// - Muestra TODAS las pendientes (is_completed = 0)
  /// - Muestra completadas (is_completed = 1) SOLO si completed_at > hace 2 días
  Future<List<TaskModel>> getAllTasks(int userId) async {
    final db = await database;

    // Query crítica: Regla de visibilidad de 48 horas
    final result = await db.rawQuery('''
      SELECT * FROM ${AppConstants.tableTasks}
      WHERE user_id = ?
        AND (
          is_completed = 0
          OR (is_completed = 1 AND datetime(completed_at) > datetime('now', '-${AppConstants.visibilityDays} days'))
        )
      ORDER BY due_date ASC
    ''', [userId]);

    return result.map((map) => TaskModel.fromMap(map)).toList();
  }

  /// Obtiene una tarea por su ID
  Future<TaskModel?> getTaskById(int id) async {
    final db = await database;
    final result = await db.query(
      AppConstants.tableTasks,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return TaskModel.fromMap(result.first);
  }

  /// Actualiza una tarea existente
  Future<int> updateTask(TaskModel task) async {
    final db = await database;
    try {
      final count = await db.update(
        AppConstants.tableTasks,
        task.toMap(),
        where: 'id = ?',
        whereArgs: [task.id],
      );
      debugPrint('Tarea actualizada: ${task.id}');
      return count;
    } catch (e) {
      debugPrint('Error al actualizar tarea: $e');
      rethrow;
    }
  }

  /// Marca una tarea como completada o pendiente (toggle)
  Future<void> toggleTaskComplete(int taskId, bool completed) async {
    final db = await database;
    try {
      await db.update(
        AppConstants.tableTasks,
        {
          'is_completed': completed ? 1 : 0,
          'completed_at': completed ? DateTime.now().toIso8601String() : null,
        },
        where: 'id = ?',
        whereArgs: [taskId],
      );
      debugPrint('Tarea $taskId marcada como ${completed ? "completada" : "pendiente"}');
    } catch (e) {
      debugPrint('Error al toggle tarea: $e');
      rethrow;
    }
  }

  /// Elimina una tarea
  Future<int> deleteTask(int id) async {
    final db = await database;
    try {
      final count = await db.delete(
        AppConstants.tableTasks,
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('Tarea eliminada: $id');
      return count;
    } catch (e) {
      debugPrint('Error al eliminar tarea: $e');
      rethrow;
    }
  }

  /// Elimina todas las tareas completadas antiguas (limpieza manual)
  Future<int> cleanOldCompletedTasks(int userId) async {
    final db = await database;
    try {
      final count = await db.rawDelete('''
        DELETE FROM ${AppConstants.tableTasks}
        WHERE user_id = ?
          AND is_completed = 1
          AND datetime(completed_at) <= datetime('now', '-${AppConstants.visibilityDays} days')
      ''', [userId]);
      debugPrint('Tareas antiguas eliminadas: $count');
      return count;
    } catch (e) {
      debugPrint('Error al limpiar tareas: $e');
      rethrow;
    }
  }

  /// Cierra la base de datos
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    debugPrint('Base de datos cerrada');
  }

  /// Elimina toda la base de datos (solo para testing)
  Future<void> deleteDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, AppConstants.dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    debugPrint('Base de datos eliminada');
  }
}
