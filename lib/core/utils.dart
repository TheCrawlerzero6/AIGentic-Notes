import 'package:intl/intl.dart';

class Utils {

  static String toIso8601(DateTime date) {
    return date.toIso8601String();
  }

  static DateTime fromIso8601(String dateStr) {
    return DateTime.parse(dateStr);
  }
  static String toDisplayFormat(DateTime date) {
    return DateFormat('dd MMM yyyy, h:mm a', 'es_ES').format(date);
  }
  static String toDateOnly(DateTime date) {
    return DateFormat('dd MMM yyyy', 'es_ES').format(date);
  }
  static String toTimeOnly(DateTime date) {
    return DateFormat('h:mm a').format(date);
  }

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
