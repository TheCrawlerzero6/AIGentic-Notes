class CreateProjectDto {
  final String title;
  final String? description;
  final String icon;
  final String themeColor;

  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreateProjectDto({
    required this.title,
    this.description,
    required this.icon,
    required this.themeColor,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });
}

class UpdateProjectDto {
  final int id;
  final String? title;
  final String? description;
  final String? icon;
  final String? themeColor;

  final int? userId;
  final DateTime? createdAt;
  final DateTime updatedAt;

  UpdateProjectDto({
    required this.id,
    this.title,
    this.description,
    this.icon,
    this.themeColor,
    this.userId,
    this.createdAt,
    required this.updatedAt,
  });
}
