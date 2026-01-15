import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../constants.dart';

class SqliteService {
  static final SqliteService instance = SqliteService._internal();

  factory SqliteService() => instance;
  SqliteService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Inicializa la base de datos
  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, Constants.dbName);
 
    return await openDatabase(
      path,
      version: Constants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Crea las tablas al crear la base de datos
  Future<void> _onCreate(Database db, int version) async {
    // Tabla users
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${Constants.tableUsers} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${Constants.tableProjects} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        icon TEXT,
        themeColor TEXT,
        userId INTEGER NOT NULL,
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        FOREIGN KEY (userId) REFERENCES ${Constants.tableUsers} (id) ON DELETE CASCADE
      )
    ''');

    // Tabla tasks
    await db.execute('''
      CREATE TABLE IF NOT EXISTS ${Constants.tableTasks} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT,
        dueDate TEXT NOT NULL,
        isCompleted INTEGER NOT NULL DEFAULT 0,
        completedAt TEXT,
        notificationId INTEGER,
        sourceType TEXT NOT NULL,
        priority INTEGER NOT NULL DEFAULT 2,  
        createdAt TEXT NOT NULL,
        updatedAt TEXT NOT NULL,
        projectId INTEGER NOT NULL,
        FOREIGN KEY (projectId) REFERENCES ${Constants.tableProjects} (id) ON DELETE CASCADE
      )
    ''');

    debugPrint('Base de datos creada con éxito');
  }

  /// Actualiza la base de datos en versiones futuras
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    debugPrint('Actualizando BD de versión $oldVersion a $newVersion');
  }

  Future<List<Map<String, dynamic>>> getAllRecords({
    required String tableName,
    String? whereClause,
    List<Object?>? whereArgs,
    String? groupBy,
    String? having,
    int? limit,
    int? offset,
  }) async {
    final db = await database;

    return await db.query(
      tableName,
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: "id DESC",
      groupBy: groupBy,
      having: having,
      limit: limit,
      offset: offset,
    );
  }

  Future<Map<String, dynamic>?> getRecord({
    required String tableName,
    int? id,
    String? whereClause,
    List<Object?>? whereArgs,
  }) async {
    final db = await database;

    final result = await db.query(
      tableName,
      where: whereClause ?? "id = ?",
      whereArgs: whereArgs ?? [id],
      limit: 1,
    );

    return result.firstOrNull;
  }

  Future<int> insertRegistry({
    required String tableName,
    required Map<String, Object?> entity,
  }) async {
    final db = await database;
    try {
      final id = await db.insert(
        tableName,
        entity,
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      debugPrint('Registro creado con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error al insertar Registro: $e');
      rethrow;
    }
  }

  Future<int> updateRegistry({
    required String tableName,
    required int id,
    required Map<String, Object?> entity,
  }) async {
    final db = await database;
    try {
      final updatedId = await db.update(
        tableName,
        entity,
        where: 'id = ?',
        whereArgs: [id],
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
      debugPrint('Registro actualizado con ID: $updatedId');
      return updatedId;
    } catch (e) {
      debugPrint('Error al actualizar Registro: $e');
      rethrow;
    }
  }

  Future<int> deleteRegistry({
    required String tableName,
    required int id,
  }) async {
    final db = await database;
    try {
      final deletedId = await db.delete(
        tableName,
        where: 'id = ?',
        whereArgs: [id],
      );
      debugPrint('Registro eliminado con ID: $deletedId');
      return deletedId;
    } catch (e) {
      debugPrint('Error al eliminar Registro: $e');
      rethrow;
    }
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
    debugPrint('Base de datos cerrada');
  }

  /// Elimina toda la base de datos (solo para testing)
  Future<void> deleteDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, Constants.dbName);
    await databaseFactory.deleteDatabase(path);
    _database = null;
    debugPrint('Base de datos eliminada');
  }
}
