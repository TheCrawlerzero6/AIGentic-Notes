import '../../../../core/domain/entities/base.dart';

abstract class User extends Entity {
  final String? username;
  final String? passwordHash;

  User({
    super.id,
    required this.username,
    required this.passwordHash,
    required super.createdAt,
    required super.updatedAt,
  });

  @override
  Map<String, dynamic> toMap();

  @override
  Map<String, dynamic> toJson();

  @override
  User copyWith({
    int? id,
    String? username,
    String? passwordHash,
    required DateTime createdAt,
    required DateTime updatedAt,
  });
}
