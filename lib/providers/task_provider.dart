import 'package:flutter/foundation.dart';
import '../data/local/database_helper.dart';
import '../data/models/task_model.dart';
import '../data/services/notification_service.dart';

/// Provider de gestión de tareas
///
/// Gestiona el estado de las tareas del usuario, incluyendo
/// carga, creación, actualización y eliminación de tareas.
/// FASE 5: Integrado con NotificationService para programar alertas.
class TaskProvider with ChangeNotifier {
  List<TaskModel> _tasks = [];
  bool _isLoading = false;
  final _notificationService = NotificationService();

  /// Lista de tareas del usuario actual
  List<TaskModel> get tasks => _tasks;

  /// Indica si se está cargando datos
  bool get isLoading => _isLoading;

  /// Carga las tareas de un usuario desde la base de datos
  /// Aplica la regla de 48 horas para filtrar completadas antiguas
  Future<void> loadTasks(int userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final db = DatabaseHelper.instance;
      _tasks = await db.getAllTasks(userId);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error al cargar tareas: $e');
      rethrow;
    }
  }

  /// Crea una nueva tarea
  /// FASE 5: Programa notificación si la fecha es futura
  Future<void> createTask(TaskModel task) async {
    try {
      final db = DatabaseHelper.instance;
      
      // Programar notificación si la fecha límite es futura
      int? notificationId;
      final dueDate = DateTime.parse(task.dueDate);
      if (dueDate.isAfter(DateTime.now())) {
        try {
          notificationId = await _notificationService.scheduleNotification(
            title: '⏰ ${task.title}',
            body: task.description,
            scheduledDate: dueDate,
            payload: task.id?.toString(),
          );
        } catch (e) {
          debugPrint('⚠️ Error al programar notificación: $e');
          // Continuar sin notificación si falla
        }
      }
      
      // Crear tarea con notification_id
      final taskWithNotification = TaskModel(
        id: task.id,
        userId: task.userId,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        isCompleted: task.isCompleted,
        completedAt: task.completedAt,
        notificationId: notificationId,
        sourceType: task.sourceType,
        priority: task.priority,
      );
      
      final taskId = await db.insertTask(taskWithNotification);
      
      // Agregar la tarea con su ID a la lista local
      final newTask = TaskModel(
        id: taskId,
        userId: task.userId,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        isCompleted: task.isCompleted,
        completedAt: task.completedAt,
        notificationId: notificationId,
        sourceType: task.sourceType,
        priority: task.priority,
      );
      
      _tasks.add(newTask);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al crear tarea: $e');
      rethrow;
    }
  }

  /// Actualiza una tarea existente
  /// FASE 5: Reprograma notificación si cambió la fecha
  Future<void> updateTask(TaskModel task) async {
    try {
      final db = DatabaseHelper.instance;
      
      // Cancelar notificación anterior si existe
      if (task.notificationId != null) {
        try {
          await _notificationService.cancelNotification(task.notificationId!);
        } catch (e) {
          debugPrint('⚠️ Error al cancelar notificación: $e');
        }
      }
      
      // Programar nueva notificación si la fecha es futura y NO está completada
      int? newNotificationId;
      if (task.isCompleted == 0) {
        final dueDate = DateTime.parse(task.dueDate);
        if (dueDate.isAfter(DateTime.now())) {
          try {
            newNotificationId = await _notificationService.scheduleNotification(
              title: '⏰ ${task.title}',
              body: task.description,
              scheduledDate: dueDate,
              payload: task.id?.toString(),
            );
          } catch (e) {
            debugPrint('⚠️ Error al programar notificación: $e');
          }
        }
      }
      
      // Actualizar tarea con nuevo notification_id
      final updatedTask = TaskModel(
        id: task.id,
        userId: task.userId,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        isCompleted: task.isCompleted,
        completedAt: task.completedAt,
        notificationId: newNotificationId,
        sourceType: task.sourceType,
        priority: task.priority,
      );
      
      await db.updateTask(updatedTask);
      
      // Actualizar en la lista local
      final index = _tasks.indexWhere((t) => t.id == task.id);
      if (index != -1) {
        _tasks[index] = updatedTask;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error al actualizar tarea: $e');
      rethrow;
    }
  }

  /// Elimina una tarea
  /// FASE 5: Cancela su notificación programada
  Future<void> deleteTask(int taskId) async {
    try {
      final db = DatabaseHelper.instance;
      
      // Buscar la tarea para obtener su notification_id
      final task = _tasks.firstWhere((t) => t.id == taskId);
      
      // Cancelar notificación si existe
      if (task.notificationId != null) {
        try {
          await _notificationService.cancelNotification(task.notificationId!);
        } catch (e) {
          debugPrint('⚠️ Error al cancelar notificación: $e');
        }
      }
      
      await db.deleteTask(taskId);
      
      // Eliminar de la lista local
      _tasks.removeWhere((t) => t.id == taskId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error al eliminar tarea: $e');
      rethrow;
    }
  }

  /// Cambia el estado de completado de una tarea
  Future<void> toggleComplete(int taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = TaskModel(
        id: task.id,
        userId: task.userId,
        title: task.title,
        description: task.description,
        dueDate: task.dueDate,
        isCompleted: task.isCompleted == 1 ? 0 : 1,
        completedAt: task.isCompleted == 1 ? null : DateTime.now().toIso8601String(),
        notificationId: task.notificationId,
        sourceType: task.sourceType,
        priority: task.priority,
      );
      
      await updateTask(updatedTask);
    } catch (e) {
      debugPrint('Error al cambiar estado de tarea: $e');
      rethrow;
    }
  }
}
