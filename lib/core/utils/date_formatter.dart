import 'package:intl/intl.dart';

/// Utilidades para formatear fechas
class DateFormatter {
  /// Formatea una fecha a formato ISO8601 (para BD)
  static String toIso8601(DateTime date) {
    return date.toIso8601String();
  }

  /// Parsea una fecha desde ISO8601
  static DateTime fromIso8601(String dateStr) {
    return DateTime.parse(dateStr);
  }

  /// Formatea una fecha para mostrar al usuario
  /// Ejemplo: "15 Ene 2026, 15:30"
  static String toDisplayFormat(DateTime date) {
    return DateFormat('dd MMM yyyy, HH:mm', 'es_ES').format(date);
  }

  /// Formatea solo la fecha (sin hora)
  /// Ejemplo: "15 Ene 2026"
  static String toDateOnly(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es_ES').format(date);
  }

  /// Formatea solo la hora
  /// Ejemplo: "15:30"
  static String toTimeOnly(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Verifica si una fecha ya pasó
  static bool isOverdue(DateTime date) {
    return date.isBefore(DateTime.now());
  }

  /// Calcula si una tarea completada debe seguir visible (regla de 48 horas)
  static bool isWithinVisibilityWindow(DateTime completedAt, {int days = 2}) {
    final now = DateTime.now();
    final difference = now.difference(completedAt);
    return difference.inDays < days;
  }
}
