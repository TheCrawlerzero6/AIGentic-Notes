import '../../../../core/entities/base.dart';

abstract class Project extends Entity {
  final String title;
  final String? description;
  final String icon;
  final String themeColor;

  final int userId;

  Project({
    super.id,
    required this.title,
    this.description,
    required this.icon,
    required this.themeColor,
    required this.userId,
    required super.createdAt,
    required super.updatedAt,
  });

  @override
  Map<String, dynamic> toMap();

  @override
  Map<String, dynamic> toJson();

  @override
  Project copyWith({
    int? id,
    String? title,
    String? description,
    String? icon,
    String? themeColor,
    int? userId,
    required DateTime createdAt,
    required DateTime updatedAt,
  });
}
