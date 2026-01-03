---
name: gen-logic
description: Genera los Providers y orquesta Notificaciones con Base de Datos
tools: [ 'edit' ]
argument-hint: Genera TaskProvider y NotificationService
---
Actúa como un desarrollador Senior Flutter.
Genera `lib/providers/task_provider.dart` y `lib/data/services/notification_service.dart`.

Lógica de Orquestación:
1. Agregar Tarea:
   - Inserta en SQLite usando `DatabaseHelper`.
   - Genera `notification_id` aleatorio.
   - Llama a `notificationService.schedule(...)` con el `due_date`.
   - Recarga la lista del dashboard.
2. Completar Tarea (Check):
   - Update `is_completed = 1` y `completed_at = DateTime.now()`.
   - Llama a `notificationService.cancel(id)`.
3. Descompletar:
   - Update `is_completed = 0` y `completed_at = null`.
   - Reprograma notificación si la fecha es futura.

Notificaciones:
- Configura `flutter_local_notifications` para Android e iOS.
- Métodos `scheduleNotification` y `cancelNotification`.