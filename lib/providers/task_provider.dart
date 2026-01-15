// import 'package:flutter/foundation.dart';
// import 'package:mi_agenda/app/data/services/sqlite_service.dart';
// import 'package:sqflite_common/sqlite_api.dart';
// import '../app/data/datasources/user_local_datasource.dart';
// import '../app/data/models/task_model.dart';
// import '../app/data/services/notification_service.dart';

// /// Provider de gestión de tareas
// ///
// /// Gestiona el estado de las tareas del usuario, incluyendo
// /// carga, creación, actualización y eliminación de tareas.
// /// FASE 5: Integrado con NotificationService para programar alertas.
// class TaskProvider with ChangeNotifier {
//   List<TaskModel> _tasks = [];
//   bool _isLoading = false;
//   final _notificationService = NotificationService();

//   /// Lista de tareas del usuario actual
//   List<TaskModel> get tasks => _tasks;

//   /// Indica si se está cargando datos
//   bool get isLoading => _isLoading;

//   /// Carga las tareas de un usuario desde la base de datos
//   /// Aplica la regla de 48 horas para filtrar completadas antiguas
//   Future<void> loadTasks(int userId) async {
//     try {
//       _isLoading = true;
//       notifyListeners();

//       final db = await SqliteService.instance.database;
//       _tasks = await db.getAllTasks(userId);

//       _isLoading = false;
//       notifyListeners();
//     } catch (e) {
//       _isLoading = false;
//       notifyListeners();
//       debugPrint('Error al cargar tareas: $e');
//       rethrow;
//     }
//   }

//   /// Crea una nueva tarea
//   /// Programa notificación si la fecha límite es futura
//   Future<void> createTask(TaskModel task) async {
//     try {
//       final db = await SqliteService.instance.database;

//       // Programar notificación si la fecha límite es futura
//       int? notificationId;
//       final dueDate = DateTime.parse(task.dueDate);
//       final now = DateTime.now();

//       debugPrint('Creando tarea. Fecha límite: $dueDate, Ahora: $now');

//       if (dueDate.isAfter(now)) {
//         try {
//           notificationId = await _notificationService.scheduleNotification(
//             title: 'Recordatorio: ${task.title}',
//             body: "asda",
//             scheduledDate: dueDate,
//             payload: task.id?.toString(),
//           );
//           debugPrint(
//             'Notificación programada exitosamente con ID: $notificationId',
//           );
//         } catch (e) {
//           debugPrint('Error al programar notificación: $e');
//         }
//       } else {
//         debugPrint('Fecha límite no es futura, no se programa notificación');
//       }

//       // Crear tarea con notification_id
//       final taskWithNotification = TaskModel(
//         id: task.id,
//         userId: task.userId,
//         title: task.title,
//         description: task.description,
//         dueDate: task.dueDate,
//         isCompleted: task.isCompleted,
//         completedAt: task.completedAt,
//         notificationId: notificationId,
//         sourceType: task.sourceType,
//         priority: task.priority,
//       );

//       final taskId = await db.insertTask(taskWithNotification);

//       // Agregar la tarea con su ID a la lista local
//       final newTask = TaskModel(
//         id: taskId,
//         userId: task.userId,
//         title: task.title,
//         description: task.description,
//         dueDate: task.dueDate,
//         isCompleted: task.isCompleted,
//         completedAt: task.completedAt,
//         notificationId: notificationId,
//         sourceType: task.sourceType,
//         priority: task.priority, projectId: null, createdAt: null, updatedAt: null,
//       );

//       _tasks.add(newTask);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error al crear tarea: $e');
//       rethrow;
//     }
//   }

//   /// Actualiza una tarea existente
//   /// Reprograma notificación si cambió la fecha
//   Future<void> updateTask(TaskModel task) async {
//     try {
//       final db = await SqliteService.instance.database;

//       // Cancelar notificación anterior si existe
//       if (task.notificationId != null) {
//         try {
//           await _notificationService.cancelNotification(task.notificationId!);
//         } catch (e) {
//           debugPrint('Error al cancelar notificación: $e');
//         }
//       }

//       // Programar nueva notificación si la fecha es futura y no está completada
//       int? newNotificationId;
//       if (task.isCompleted == 0) {
//         final dueDate = DateTime.parse(task.dueDate);
//         if (dueDate.isAfter(DateTime.now())) {
//           try {
//             newNotificationId = await _notificationService.scheduleNotification(
//               title: 'Recordatorio: ${task.title}',
//               body: task.description,
//               scheduledDate: dueDate,
//               payload: task.id?.toString(),
//             );
//           } catch (e) {
//             debugPrint('Error al programar notificación: $e');
//           }
//         }
//       }

//       // Actualizar tarea con nuevo notification_id
//       final updatedTask = TaskModel(
//         id: task.id,
//         userId: task.userId,
//         title: task.title,
//         description: task.description,
//         dueDate: task.dueDate,
//         isCompleted: task.isCompleted,
//         completedAt: task.completedAt,
//         notificationId: newNotificationId,
//         sourceType: task.sourceType,
//         priority: task.priority,
//       );

//       await db.updateTask(updatedTask);

//       // Actualizar en la lista local
//       final index = _tasks.indexWhere((t) => t.id == task.id);
//       if (index != -1) {
//         _tasks[index] = updatedTask;
//         notifyListeners();
//       }
//     } catch (e) {
//       debugPrint('Error al actualizar tarea: $e');
//       rethrow;
//     }
//   }

//   /// Elimina una tarea
//   /// Cancela su notificación programada si existe
//   Future<void> deleteTask(int taskId) async {
//     try {
//       final db = await SqliteService.instance.database;

//       // Buscar la tarea para obtener su notification_id
//       final task = _tasks.firstWhere((t) => t.id == taskId);

//       // Cancelar notificación si existe
//       if (task.notificationId != null) {
//         try {
//           await _notificationService.cancelNotification(task.notificationId!);
//         } catch (e) {
//           debugPrint('Error al cancelar notificación: $e');
//         }
//       }

//       await db.deleteTask(taskId);

//       // Eliminar de la lista local
//       _tasks.removeWhere((t) => t.id == taskId);
//       notifyListeners();
//     } catch (e) {
//       debugPrint('Error al eliminar tarea: $e');
//       rethrow;
//     }
//   }

//   /// Cambia el estado de completado de una tarea
//   ///
//   /// Al completar: Cancela la notificación programada
//   /// Al descompletar: Reprograma la notificación si la fecha es futura
//   Future<void> toggleComplete(int taskId) async {
//     try {
//       final task = _tasks.firstWhere((t) => t.id == taskId);
//       final db = await SqliteService.instance.database;

//       final isGoingToComplete = task.isCompleted == 0;

//       if (isGoingToComplete) {
//         // Completar tarea: cancelar notificación
//         if (task.notificationId != null) {
//           try {
//             await _notificationService.cancelNotification(task.notificationId!);
//           } catch (e) {
//             debugPrint('Error al cancelar notificación: $e');
//           }
//         }

//         final updatedTask = TaskModel(
//           id: task.id,
//           userId: task.userId,
//           title: task.title,
//           description: task.description,
//           dueDate: task.dueDate,
//           isCompleted: 1,
//           completedAt: DateTime.now().toIso8601String(),
//           notificationId: task.notificationId,
//           sourceType: task.sourceType,
//           priority: task.priority,
//         );

//         await db.updateTask(updatedTask);

//         final index = _tasks.indexWhere((t) => t.id == taskId);
//         if (index != -1) {
//           _tasks[index] = updatedTask;
//           notifyListeners();
//         }
//       } else {
//         // Descompletar tarea: reprogramar notificación si la fecha es futura
//         int? newNotificationId;
//         final dueDate = DateTime.parse(task.dueDate);

//         if (dueDate.isAfter(DateTime.now())) {
//           try {
//             newNotificationId = await _notificationService.scheduleNotification(
//               title: 'Recordatorio: ${task.title}',
//               body: task.description,
//               scheduledDate: dueDate,
//               payload: task.id?.toString(),
//             );
//           } catch (e) {
//             debugPrint('Error al reprogramar notificación: $e');
//           }
//         }

//         final updatedTask = TaskModel(
//           id: task.id,
//           userId: task.userId,
//           title: task.title,
//           description: task.description,
//           dueDate: task.dueDate,
//           isCompleted: 0,
//           completedAt: null,
//           notificationId: newNotificationId,
//           sourceType: task.sourceType,
//           priority: task.priority,
//         );

//         await db.updateTask(updatedTask);

//         final index = _tasks.indexWhere((t) => t.id == taskId);
//         if (index != -1) {
//           _tasks[index] = updatedTask;
//           notifyListeners();
//         }
//       }
//     } catch (e) {
//       debugPrint('Error al cambiar estado de tarea: $e');
//       rethrow;
//     }
//   }
// }

// extension on Database {
//   Future insertTask(TaskModel taskWithNotification) {}
// }
