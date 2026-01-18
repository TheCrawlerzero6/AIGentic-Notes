/// Helper de cálculo de fecha/hora para tareas
///
/// Centraliza la lógica de negocio para determinar la fecha de vencimiento
/// final de una tarea basándose en las reglas de la aplicación.
class TaskDateTimeCalculator {
  // Constructor privado para evitar instanciación
  TaskDateTimeCalculator._();

  /// Calcula la fecha de vencimiento final de una tarea
  ///
  /// Aplica las siguientes reglas de negocio:
  ///
  /// **Regla 1: Sin fecha (dueDate == null)**
  /// - Resultado: Fecha actual + 1 hora
  /// - Ejemplo: Si son las 13:30, la tarea vence a las 14:30 hoy
  ///
  /// **Regla 2: Con fecha pero sin hora (hora = 00:00:00)**
  /// - Resultado: Fecha indicada + hora actual
  /// - Ejemplo: "Reunión el 20 de enero" sin hora específica
  ///   → 20/01/2026 a las 13:30 (si son las 13:30 ahora)
  ///
  /// **Regla 3: Con fecha Y hora específica**
  /// - Resultado: Usar la fecha/hora tal cual
  /// - Ejemplo: "Llamar mañana a las 10:00"
  ///   → 18/01/2026 a las 10:00
  ///
  /// Parámetros:
  /// - [dueDate]: Fecha de vencimiento proporcionada por la IA (puede ser null)
  /// - [currentTime]: Fecha/hora de referencia (normalmente DateTime.now())
  ///
  /// Retorna: La fecha de vencimiento final calculada según las reglas
  static DateTime calculateFinalDueDate({
    required DateTime? dueDate,
    required DateTime currentTime,
  }) {
    // Regla 1: Sin fecha → HOY + 1 hora
    if (dueDate == null) {
      return currentTime.add(const Duration(hours: 1));
    }

    // Regla 2: Con fecha pero sin hora (00:00:00) → FECHA indicada + HORA actual
    if (dueDate.hour == 0 && dueDate.minute == 0 && dueDate.second == 0) {
      return DateTime(
        dueDate.year,
        dueDate.month,
        dueDate.day,
        currentTime.hour,
        currentTime.minute,
      );
    }

    // Regla 3: Con fecha Y hora → usar tal cual
    return dueDate;
  }

  /// Verifica si una fecha tiene hora específica o es medianoche (00:00:00)
  ///
  /// Útil para determinar si la IA proporcionó una hora específica
  /// o solo una fecha sin hora.
  ///
  /// Retorna:
  /// - `true` si la hora es 00:00:00 (sin hora específica)
  /// - `false` si tiene cualquier otra hora
  static bool isDateWithoutTime(DateTime date) {
    return date.hour == 0 && date.minute == 0 && date.second == 0;
  }

  /// Obtiene una descripción legible de cómo se calculó la fecha
  ///
  /// Útil para debugging y logging. Explica qué regla se aplicó.
  ///
  /// Ejemplo de retorno:
  /// - "Regla 1: Sin fecha → HOY + 1 hora"
  /// - "Regla 2: Con fecha sin hora → 20/01/2026 + hora actual"
  /// - "Regla 3: Fecha y hora específica → 18/01/2026 10:00"
  static String getCalculationDescription({
    required DateTime? originalDueDate,
    required DateTime finalDueDate,
  }) {
    if (originalDueDate == null) {
      return 'Regla 1: Sin fecha → HOY + 1 hora';
    }

    if (isDateWithoutTime(originalDueDate)) {
      return 'Regla 2: Con fecha sin hora → ${_formatDate(originalDueDate)} + hora actual';
    }

    return 'Regla 3: Fecha y hora específica → ${_formatDateTime(finalDueDate)}';
  }

  // Método privado para formatear fecha
  static String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  // Método privado para formatear fecha con hora
  static String _formatDateTime(DateTime date) {
    return '${_formatDate(date)} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}
