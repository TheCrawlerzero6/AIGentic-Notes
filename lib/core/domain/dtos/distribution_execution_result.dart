import '../entities/distribution_result.dart';
import '../entities/task.dart';

class DistributionExecutionResult {
  final int tasksCreated;
  final int projectsCreated;
  final DistributionResult distribution;
  final List<Task> createdTasks;

  DistributionExecutionResult({
    required this.tasksCreated,
    required this.projectsCreated,
    required this.distribution,
    required this.createdTasks,
  });
}
