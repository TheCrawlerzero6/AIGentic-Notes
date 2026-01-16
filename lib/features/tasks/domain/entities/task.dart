import '../../../../core/entities/base.dart';

abstract class Task extends Entity {
  final String title;
  final String? description;
  final DateTime? dueDate; // ISO8601
  final bool isCompleted; // 0 = pendiente, 1 = completada
  final DateTime? completedAt; // ISO8601, null si no está completada
  final int? notificationId; // ID para gestionar notificaciones
  final String sourceType; // 'manual', 'voice', 'image', 'file'
  final int priority; // 1 = baja, 2 = media, 3 = alta

  final int projectId;

  Task({
    super.id,
    required this.title,
    this.description,
    this.dueDate,
    required this.isCompleted,
    this.completedAt,
    this.notificationId,
    required this.sourceType,
    required this.priority,

    required this.projectId,
    required super.createdAt,
    required super.updatedAt,
  });

  @override
  Map<String, dynamic> toMap();

  @override
  Map<String, dynamic> toJson();

  @override
  Task copyWith({
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
  });
}
