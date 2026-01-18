import '../entities/distribution_result.dart';

class DistributionExecutionResult {
  final int tasksCreated;
  final int projectsCreated;
  final DistributionResult distribution;

  DistributionExecutionResult({
    required this.tasksCreated,
    required this.projectsCreated,
    required this.distribution,
  });
}
