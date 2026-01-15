import '../dtos/project_dtos.dart';
import '../entities/project.dart';

abstract class IProjectRepository  {
  Future<List<Project>> listProjects();
  Future<Project?> getProjectDetail(int id);
  Future<int> createProject(CreateProjectDto data);
  Future<int> updateProject(int id, UpdateProjectDto data);
  Future<int> deleteProject(int id);
}
