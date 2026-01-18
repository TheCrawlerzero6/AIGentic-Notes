import 'package:mi_agenda/features/tasks/data/models/project_model.dart';

import '../datasources/project_local_datasource.dart';
import '../../domain/dtos/project_dtos.dart';
import '../../domain/repositories/project_repository.dart';
import '../datasources/task_local_datasource.dart';

class ProjectRepository extends IProjectRepository {
  final ProjectLocalDatasource dataSource;
  final TaskLocalDatasource tasksDataSource;

  ProjectRepository({required this.dataSource, required this.tasksDataSource});

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
  Future<DetailedProjectDto?> getProjectDetail(int id) async {
    final project = await dataSource.getDetail(id);

    final tasks = await tasksDataSource.getAllByProjectId(project.id!);
    final result = DetailedProjectDto(
      id: project.id!,
      title: project.title,
      description: project.description,
      icon: project.icon,
      themeColor: project.themeColor,
      tasks: tasks,
      userId: project.userId,
      createdAt: project.createdAt,
      updatedAt: project.updatedAt,
    );
    return result;
  }

  @override
  Future<List<DetailedProjectDto>> listProjects() async {
    final projects = await dataSource.getAll();
    List<DetailedProjectDto> resultsList = [];

    for (final project in projects) {
      final tasks = await tasksDataSource.getAllByProjectId(project.id!);
      final result = DetailedProjectDto(
        id: project.id!,
        title: project.title,
        icon: project.icon,
        description: project.description,
        themeColor: project.themeColor,
        tasks: tasks,
        userId: project.userId,
        createdAt: project.createdAt,
        updatedAt: project.updatedAt,
      );
      resultsList.add(result);
    }
    return resultsList;
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
