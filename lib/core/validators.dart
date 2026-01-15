/// Utilidades para validar inputs del usuario
class Validators {
  /// Valida que un string no esté vacío
  static String? required(String? value, {String fieldName = 'Este campo'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  /// Valida longitud mínima
  static String? minLength(String? value, int min,
      {String fieldName = 'Este campo'}) {
    if (value == null || value.length < min) {
      return '$fieldName debe tener al menos $min caracteres';
    }
    return null;
  }

  /// Valida que una contraseña tenga longitud adecuada
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es obligatoria';
    }
    if (value.length < 4) {
      return 'La contraseña debe tener al menos 4 caracteres';
    }
    return null;
  }

  /// Valida que un username sea válido
  static String? username(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre de usuario es obligatorio';
    }
    if (value.length < 3) {
      return 'El nombre de usuario debe tener al menos 3 caracteres';
    }
    return null;
  }
}
