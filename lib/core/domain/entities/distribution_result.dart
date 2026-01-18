import '../../../../core/domain/dtos/distribution_dtos.dart';

class DistributionResult {
  final List<ProjectDistribution> existingProjectDistributions;
  final List<NewProjectDistribution> newProjectDistributions;
  final int totalTasksProcessed;
  final int projectsUsed;
  final int newProjectsCreated;

  DistributionResult({
    required this.existingProjectDistributions,
    required this.newProjectDistributions,
    required this.totalTasksProcessed,
    required this.projectsUsed,
    required this.newProjectsCreated,
  });

  int get totalProjects => projectsUsed + newProjectsCreated;
}
