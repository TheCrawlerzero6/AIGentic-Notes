/// Modelo de Usuario para la tabla 'users' de SQLite
class UserModel {
  final int? id;
  final String username;
  final String passwordHash;
  final DateTime createdAt;

  UserModel({
    this.id,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
  });

  /// Crea un UserModel desde un Map (de SQLite)
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      username: map['username'] as String,
      passwordHash: map['password_hash'] as String,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convierte el UserModel a Map (para SQLite)
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'username': username,
      'password_hash': passwordHash,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Crea una copia del UserModel con campos actualizados
  UserModel copyWith({
    int? id,
    String? username,
    String? passwordHash,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      passwordHash: passwordHash ?? this.passwordHash,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, createdAt: $createdAt)';
  }
}
