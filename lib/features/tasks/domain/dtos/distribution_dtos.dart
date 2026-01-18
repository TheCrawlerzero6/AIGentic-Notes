import '../entities/task.dart';

class ProjectDistribution {
  final int projectId;
  final List<Task> tasks;

  ProjectDistribution({
    required this.projectId,
    required this.tasks,
  });
}

class NewProjectDistribution {
  final String title;
  final String? suggestedDescription;
  final String? suggestedIcon;
  final List<Task> tasks;

  NewProjectDistribution({
    required this.title,
    this.suggestedDescription,
    this.suggestedIcon,
    required this.tasks,
  });
}
