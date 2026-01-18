/// Validador centralizado para TaskModel
///
/// Contiene todas las validaciones de negocio relacionadas con tareas.
/// Métodos estáticos para facilitar el testing y reutilización.
class TaskValidator {
  // Constructor privado para evitar instanciación
  TaskValidator._();

  /// Longitud máxima permitida para el título de una tarea
  static const int maxTitleLength = 200;

  /// Días máximos en el pasado permitidos para una fecha de vencimiento
  static const int maxDaysInPast = 365;

  /// Valida que el título de la tarea sea válido
  ///
  /// Lanza [Exception] si:
  /// - El título está vacío
  /// - El título excede [maxTitleLength] caracteres
  static void validateTitle(String title) {
    if (title.trim().isEmpty) {
      throw Exception(
        'Una de las tareas no tiene título. Todas las tareas deben tener título.',
      );
    }

    if (title.length > maxTitleLength) {
      throw Exception(
        'El título "$title" es demasiado largo (máximo $maxTitleLength caracteres).',
      );
    }
  }

  /// Valida que la prioridad esté en el rango válido [1-3]
  ///
  /// Lanza [Exception] si la prioridad no es 1, 2 o 3
  static void validatePriority(int priority, String taskTitle) {
    if (priority < 1 || priority > 3) {
      throw Exception(
        'Prioridad inválida para "$taskTitle". Debe ser 1, 2 o 3.',
      );
    }
  }

  /// Valida que la fecha de vencimiento no esté muy en el pasado
  ///
  /// Lanza [Exception] si la fecha es anterior a [maxDaysInPast] días atrás
  static void validateDueDate(DateTime dueDate, String taskTitle) {
    final now = DateTime.now();
    final maxPastDate = now.subtract(Duration(days: maxDaysInPast));

    if (dueDate.isBefore(maxPastDate)) {
      throw Exception(
        'La fecha de vencimiento de "$taskTitle" está muy en el pasado.',
      );
    }
  }

  /// Valida todos los campos de una tarea en un solo método
  ///
  /// Ejecuta todas las validaciones en orden. Si alguna falla,
  /// lanza una excepción descriptiva.
  static void validateTask({
    required String title,
    required int priority,
    required DateTime dueDate,
  }) {
    validateTitle(title);
    validatePriority(priority, title);
    validateDueDate(dueDate, title);
  }
}
