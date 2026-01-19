import 'package:flutter/foundation.dart';
import '../../../../core/data/datasources/base_local_datasource.dart';
import '../../../../core/data/models/task_model.dart';
import '../../../../core/constants.dart';

class TaskLocalDatasource extends BaseLocalDataSource<TaskModel> {
  TaskLocalDatasource({required super.db})
    : super(tableName: Constants.tableTasks);

  /// Obtiene todas las tareas de un usuario con la REGLA DE 48 HORAS
  /// - Muestra TODAS las pendientes (isCompleted = 0)
  /// - Muestra completadas (isCompleted = 1) SOLO si completedAt > hace 2 días
  /// Marca una tarea como completada o pendiente (toggle)
  Future<int> toggleTaskComplete(int taskId, bool completed) async {
    try {
      await db.updateRegistry(
        tableName: tableName,
        id: taskId,
        entity: {
          'isCompleted': completed,
          'completedAt': completed ? DateTime.now().toIso8601String() : null,
        },
      );
      debugPrint(
        'Tarea $taskId marcada como ${completed ? "completada" : "pendiente"}',
      );
      return taskId;
    } catch (e) {
      debugPrint('Error al toggle tarea: $e');
      rethrow;
    }
  }

  Future<int> cleanOldCompletedTasks(int userId) async {
    try {
      final database = await db.database;
      int count = await database.delete(
        tableName,
        where:
            '''
          AND isCompleted = 1
          AND datetime(completedAt) <= datetime('now', '-${Constants.visibilityDays} days')
        ''',
        whereArgs: [],
      );
      debugPrint('Tareas antiguas eliminadas: $count');
      return count;
    } catch (e) {
      debugPrint('Error al limpiar tareas: $e');
      rethrow;
    }
  }

  @override
  Future<int> delete(int id) async {
    final deletedId = await db.deleteRegistry(tableName: tableName, id: id);
    return deletedId;
  }

  @override
  Future<List<TaskModel>> getAll() async {
    final records = await db.getAllRecords(tableName: tableName);
    return records.map((map) => TaskModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getAllByProjectId(int projectId) async {
    final records = await db.getAllRecords(
      tableName: tableName,
      whereClause: "projectId = ?",
      whereArgs: [projectId],
    );
    return records.map((map) => TaskModel.fromMap(map)).toList();
  }

  @override
  Future<int> insert(TaskModel data) async {
    try {
      final id = await db.insertRegistry(
        tableName: tableName,
        entity: data.toMap(),
      );
      debugPrint('Usuario creado con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error al insertar tarea: $e');
      rethrow;
    }
  }

  @override
  Future<int> update(TaskModel data) async {
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

  @override
  Future<TaskModel> getDetail(int id) async {
    final record = await db.getRecord(tableName: tableName, id: id);
    if (record != null) {
      return TaskModel.fromMap(record);
    }
    throw Exception("Task not found.");
  }

  /// OPTIMIZACIÓN: Inserta múltiples tareas en batch y retorna List<Task> con IDs
  Future<List<TaskModel>> insertBatch(List<TaskModel> tasks) async {
    if (tasks.isEmpty) return [];

    final database = await db.database;
    final List<TaskModel> createdTasks = [];

    await database.transaction((txn) async {
      for (var task in tasks) {
        final id = await txn.insert(tableName, task.toMap());
        createdTasks.add(task.copyWith(
          id: id,
          createdAt: task.createdAt,
          updatedAt: task.updatedAt,
        ));
      }
    });

    debugPrint('Batch insert: ${createdTasks.length} tareas creadas');
    return createdTasks;
  }

  /// OPTIMIZACIÓN: Actualiza notificationId de múltiples tareas en 1 transacción
  Future<void> batchUpdateNotificationIds(Map<int, int> taskIdToNotificationId) async {
    if (taskIdToNotificationId.isEmpty) return;

    final database = await db.database;
    
    await database.transaction((txn) async {
      for (var entry in taskIdToNotificationId.entries) {
        await txn.update(
          tableName,
          {'notificationId': entry.value},
          where: 'id = ?',
          whereArgs: [entry.key],
        );
      }
    });

    debugPrint('Batch update: ${taskIdToNotificationId.length} notificationIds actualizados');
  }
}
