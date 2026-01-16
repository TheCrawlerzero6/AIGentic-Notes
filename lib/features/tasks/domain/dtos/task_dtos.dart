class CreateTaskDto {
  final String title;
  final String? description;
  final DateTime dueDate;
  final bool isCompleted;
  final DateTime? completedAt;
  final int? notificationId;
  final String sourceType;
  final int priority;

  final int projectId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreateTaskDto({
    required this.title,
    this.description,

    required this.dueDate,
    required this.isCompleted,
    this.completedAt,
    this.notificationId,
    required this.sourceType,
    required this.priority,
    required this.projectId,
    required this.createdAt,
    required this.updatedAt,
  });
}

class UpdateTaskDto {
  final int id;
  final String? title;
  final String? description;
  final DateTime? dueDate;
  final bool? isCompleted;
  final DateTime? completedAt;
  final int? notificationId;
  final String? sourceType;
  final int? priority;

  final int? projectId;
  final DateTime? createdAt;
  final DateTime updatedAt;

  UpdateTaskDto({
    required this.id,
    this.title,
    this.description,
    this.dueDate,
    this.isCompleted,
    this.completedAt,
    this.notificationId,
    this.sourceType,
    this.priority,
    this.projectId,
    this.createdAt,
    required this.updatedAt,
  });
}
