import '../datasources/project_local_datasource.dart';
import '../../domain/dtos/project_dtos.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';

class ProjectRepository extends IProjectRepository {
  final ProjectLocalDatasource dataSource;

  ProjectRepository({required this.dataSource});

  @override
  Future<int> createProject(CreateProjectDto data) {
    // TODO: implement createProject
    throw UnimplementedError();
  }

  @override
  Future<int> deleteProject(int id) {
    // TODO: implement deleteProject
    throw UnimplementedError();
  }

  @override
  Future<Project?> getProjectDetail(int id) {
    // TODO: implement getProjectDetail
    throw UnimplementedError();
  }

  @override
  Future<List<Project>> listProjects() {
    // TODO: implement listProjects
    throw UnimplementedError();
  }

  @override
  Future<int> updateProject(int id, UpdateProjectDto data) {
    // TODO: implement updateProject
    throw UnimplementedError();
  }
}
