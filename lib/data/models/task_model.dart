/// Modelo de Tarea para la tabla 'tasks' de SQLite
class TaskModel {
  final int? id;
  final int userId;
  final String title;
  final String description;
  final String dueDate; // ISO8601
  final int isCompleted; // 0 = pendiente, 1 = completada
  final String? completedAt; // ISO8601, null si no está completada
  final int? notificationId; // ID para gestionar notificaciones
  final String sourceType; // 'manual', 'voice', 'image', 'file'
  final int priority; // 1 = baja, 2 = media, 3 = alta

  TaskModel({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.dueDate,
    this.isCompleted = 0,
    this.completedAt,
    this.notificationId,
    required this.sourceType,
    required this.priority,
  });

  /// Crea un TaskModel desde un Map (de SQLite)
  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'] as int?,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      dueDate: map['due_date'] as String,
      isCompleted: map['is_completed'] as int,
      completedAt: map['completed_at'] as String?,
      notificationId: map['notification_id'] as int?,
      sourceType: map['source_type'] as String,
      priority: map['priority'] as int,
    );
  }

  /// Convierte el TaskModel a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate,
      'is_completed': isCompleted,
      'completed_at': completedAt,
      'notification_id': notificationId,
      'source_type': sourceType,
      'priority': priority,
    };
  }

  /// Crea un TaskModel desde JSON (de Firebase AI)
  factory TaskModel.fromJson(Map<String, dynamic> json, int userId) {
    return TaskModel(
      userId: userId,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      dueDate: json['dueDate'] as String,
      priority: json['priority'] as int? ?? 2,
      sourceType: json['sourceType'] as String? ?? 'manual',
    );
  }

  /// Convierte el TaskModel a JSON
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'priority': priority,
      'sourceType': sourceType,
    };
  }

  /// Crea una copia del TaskModel con campos actualizados
  TaskModel copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? dueDate,
    int? isCompleted,
    String? completedAt,
    int? notificationId,
    String? sourceType,
    int? priority,
  }) {
    return TaskModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted,
      completedAt: completedAt ?? this.completedAt,
      notificationId: notificationId ?? this.notificationId,
      sourceType: sourceType ?? this.sourceType,
      priority: priority ?? this.priority,
    );
  }

  /// Verifica si la tarea está vencida
  bool get isOverdue {
    if (isCompleted == 1) return false;
    final dueDateTime = DateTime.parse(dueDate);
    return dueDateTime.isBefore(DateTime.now());
  }

  /// Obtiene el color según la prioridad
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
