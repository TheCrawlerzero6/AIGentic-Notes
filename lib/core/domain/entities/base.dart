abstract class Entity {
  int? id;
  final DateTime createdAt;
  final DateTime updatedAt;

Entity({
    this.id,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toMap();

  Map<String, dynamic> toJson();

  Entity copyWith({
    int? id,
    required DateTime createdAt,
    required DateTime updatedAt,
  });
}
