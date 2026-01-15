import 'package:flutter/foundation.dart';
import '../../../../core/datasources/base_local_datasource.dart';
import '../models/project_model.dart';
import '../../../../core/constants.dart';

class ProjectLocalDatasource extends BaseLocalDataSource<ProjectModel> {
  ProjectLocalDatasource({required super.db})
    : super(tableName: Constants.tableTasks);

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
      debugPrint('Error al insertar usuario: $e');
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
}
