import '../../domain/entities/project.dart';

class ProjectModel extends Project {
  ProjectModel({
    super.id,
    required super.title,
    super.description,
    required super.icon,
    required super.themeColor,
    required super.userId,
    required super.createdAt,
    required super.updatedAt,
  });

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String,
      themeColor: map['themeColor'] as String,

      userId: map['userId'] as int,
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
      'icon': icon,
      'themeColor': themeColor,

      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json, int userId) {
    return ProjectModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: json['icon'] as String? ?? '',
      themeColor: json['themeColor'] as String? ?? '',

      userId: json['userId'] as int,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'icon': icon,
      'themeColor': themeColor,
      'userId': userId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  @override
  ProjectModel copyWith({
    int? id,

    String? title,
    String? description,
    String? icon,
    String? themeColor,

    int? userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      icon: icon ?? this.icon,
      themeColor: themeColor ?? this.themeColor,

      userId: userId ?? this.userId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  @override
  String toString() {
    return 'ProjectModel(id: $id, title: $title)';
  }
}
