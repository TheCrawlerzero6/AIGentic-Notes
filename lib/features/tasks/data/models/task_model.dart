import '../../domain/entities/task.dart';

class TaskModel extends Task {
  TaskModel({
    required super.id,

    required super.title,
    required super.description,
    required super.dueDate,
    required super.isCompleted,
    super.completedAt,
    super.notificationId,
    required super.sourceType,
    required super.priority,

    required super.projectId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: DateTime.parse(map['dueDate']),
      isCompleted: map['isCompleted'] as bool,
      completedAt: map['completedAt'] != null
          ? DateTime.parse(map['completedAt'])
          : null,
      notificationId: map['notificationId'] as int?,
      sourceType: map['sourceType'] as String,
      priority: map['priority'] as int,
      projectId: map['projectId'] as int,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: DateTime.parse(map['updatedAt']),
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'isCompleted': isCompleted,
      'completedAt': completedAt,
      'notificationId': notificationId,
      'sourceType': sourceType,
      'priority': priority,
      'projectId': projectId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory TaskModel.fromJson(Map<String, dynamic> json, int userId) {
    return TaskModel(
      id: json['id'] as int,
      isCompleted: json['isCompleted'] as bool,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: DateTime.parse(json['dueDate']),
      priority: json['priority'] as int? ?? 2,
      sourceType: json['sourceType'] as String? ?? 'manual',

      projectId: json['projectId'] as int,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'sourceType': sourceType,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  TaskModel copyWith({
    int? id,

    String? title,
    String? description,
    DateTime? dueDate,
    bool? isCompleted,
    DateTime? completedAt,
    int? notificationId,
    String? sourceType,
    int? priority,

    int? projectId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return TaskModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notificationId: notificationId ?? this.notificationId,
      sourceType: sourceType ?? this.sourceType,
      priority: priority ?? this.priority,

      projectId: projectId ?? this.projectId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }


  bool get isOverdue {
    if (isCompleted) return false;
    final dueDateTime = dueDate;
    return dueDateTime.isBefore(DateTime.now());
  }

  int get priorityColor {
    switch (priority) {
      case 3:
        return 0xFFF44336; // Rojo (alta)
      case 2:
        return 0xFFFF9800; // Naranja (media)
      case 1:
      default:
        return 0xFF4CAF50; // Verde (baja)
    }
  }

  @override
  String toString() {
    return 'TaskModel(id: $id, title: $title, dueDate: $dueDate, isCompleted: $isCompleted)';
  }
}
