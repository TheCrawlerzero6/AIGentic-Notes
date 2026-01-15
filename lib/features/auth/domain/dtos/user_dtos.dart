class CreateUserDto {
  final String username;
  final String passwordHash;
  final DateTime createdAt;
  final DateTime updatedAt;

  CreateUserDto({
    required this.username,
    required this.passwordHash,
    required this.createdAt,
    required this.updatedAt,
  });
}

class UpdateUserDto {
  final int id;
  final String? username;
  final String? passwordHash;
  final DateTime? createdAt;
  final DateTime updatedAt;

  UpdateUserDto({
    required this.id,
    this.username,
    this.passwordHash,
    this.createdAt,
    required this.updatedAt,
  });
}
