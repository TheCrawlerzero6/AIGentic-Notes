/// Constantes globales de la aplicación
class AppConstants {
  // Base de datos
  static const String dbName = 'mi_agenda.db';
  static const int dbVersion = 1;

  // Tablas
  static const String tableUsers = 'users';
  static const String tableTasks = 'tasks';

  // Prioridades
  static const int priorityLow = 1;
  static const int priorityMedium = 2;
  static const int priorityHigh = 3;

  // Source types
  static const String sourceManual = 'manual';
  static const String sourceVoice = 'voice';
  static const String sourceImage = 'image';
  static const String sourceFile = 'file';

  // Notificaciones
  static const String notificationChannelId = 'task_notifications';
  static const String notificationChannelName = 'Recordatorios de Tareas';
  static const String notificationChannelDescription =
      'Notificaciones para recordatorios de tareas';

  // Regla de visibilidad (48 horas)
  static const int visibilityDays = 2;
}
