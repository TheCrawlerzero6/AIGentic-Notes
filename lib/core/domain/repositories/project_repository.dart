import '../../data/models/task_model.dart';
import '../dtos/project_dtos.dart';

abstract class IProjectRepository {
  Future<List<DetailedProjectDto>> listProjects();
  Future<DetailedProjectDto?> getProjectDetail(int id);
  Future<List<TaskModel>> getTasksByProjectId(int projectId);
  Future<int> createProject(CreateProjectDto data);
  Future<int> updateProject(int id, UpdateProjectDto data);
  Future<int> deleteProject(int id);
}
