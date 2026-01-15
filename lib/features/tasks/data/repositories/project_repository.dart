import 'package:mi_agenda/features/tasks/data/models/project_model.dart';

import '../datasources/project_local_datasource.dart';
import '../../domain/dtos/project_dtos.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepository extends IProjectRepository {
  final ProjectLocalDatasource dataSource;

  ProjectRepository({required this.dataSource});

  @override
  Future<int> createProject(CreateProjectDto data) async {
    return await dataSource.insert(
      ProjectModel(
        title: data.title,
        description: data.description,
        icon: data.icon,
        themeColor: data.themeColor,
        userId: data.userId,
        createdAt: data.createdAt,
        updatedAt: data.updatedAt,
      ),
    );
  }

  @override
  Future<int> deleteProject(int id) async {
    return await dataSource.delete(id);
  }

  @override
  Future<Project?> getProjectDetail(int id) async {
    return await dataSource.getDetail(id);
  }

  @override
  Future<List<Project>> listProjects() async {
    return await dataSource.getAll();
  }

  @override
  Future<int> updateProject(int id, UpdateProjectDto data) async {
    final currentProject = await dataSource.getDetail(id);
    return await dataSource.update(
      ProjectModel(
        title: data.title ?? currentProject.title,
        description: data.description ?? currentProject.description,
        icon: data.icon ?? currentProject.icon,
        themeColor: data.themeColor ?? currentProject.themeColor,
        userId: data.userId ?? currentProject.userId,
        createdAt: data.createdAt ?? currentProject.createdAt,
        updatedAt: data.updatedAt,
      ),
    );
  }
}
