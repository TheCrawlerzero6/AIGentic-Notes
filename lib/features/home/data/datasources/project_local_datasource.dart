import 'package:flutter/foundation.dart';
import 'package:mi_agenda/core/data/models/task_model.dart';
import '../../../../core/data/datasources/base_local_datasource.dart';
import '../../../../core/data/models/project_model.dart';
import '../../../../core/constants.dart';

class ProjectLocalDatasource extends BaseLocalDataSource<ProjectModel> {
  ProjectLocalDatasource({required super.db})
    : super(tableName: Constants.tableProjects);

  @override
  Future<int> delete(int id) async {
    final deletedId = await db.deleteRegistry(tableName: tableName, id: id);
    return deletedId;
  }

  @override
  Future<List<ProjectModel>> getAll() async {
    final records = await db.getAllRecords(tableName: tableName);
    return records.map((map) => ProjectModel.fromMap(map)).toList();
  }

  Future<List<TaskModel>> getTasksByProjectId(int projectId) async {
    final records = await db.getAllRecords(
      tableName: Constants.tableTasks,
      whereClause: "projectId = ?",
      whereArgs: [projectId],
    );
    return records.map((map) => TaskModel.fromMap(map)).toList();
  }

  @override
  Future<int> insert(ProjectModel data) async {
    try {
      final id = await db.insertRegistry(
        tableName: tableName,
        entity: data.toMap(),
      );
      debugPrint('Usuario creado con ID: $id');
      return id;
    } catch (e) {
      debugPrint('Error al insertar proyecto: $e');
      rethrow;
    }
  }

  @override
  Future<int> update(ProjectModel data) async {
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
  Future<ProjectModel> getDetail(int id) async {
    final record = await db.getRecord(tableName: tableName, id: id);
    if (record != null) {
      return ProjectModel.fromMap(record);
    }
    throw Exception("Project not found.");
  }
}
