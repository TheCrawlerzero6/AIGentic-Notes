---
name: gen-database
description: Genera el código SQLite con las tablas users y tasks actualizadas
tools: [ 'edit' ]
argument-hint: Genera database_helper.dart y modelos
---
Actúa como un DBA experto en SQLite y Dart.
Genera el código completo para `lib/data/local/database_helper.dart` y los modelos en `lib/data/models/`.

Requisitos Estrictos:
1. Schema: Implementa `onCreate` creando las tablas:
   - `users`: id, username, password_hash, createdAt.
   - `tasks`: id, user_id, title, description, dueDate, isCompleted, completedAt, notificationId, source_type, priority.
2. Modelos: Genera `TaskModel` y `UserModel` con métodos `toMap()` y `fromMap()`.
3. Dashboard Query (Vital): El método `getDashboardTasks()` debe filtrar:
   - Todas las pendientes (`isCompleted = 0`).
   - Y las completadas (`isCompleted = 1`) SOLO si `completedAt` es posterior a hace 2 días (`datetime('now', '-2 days')`).
   - Ordenar por `dueDate` ASC.
4. CRUD: Métodos para insert, update, delete y get.