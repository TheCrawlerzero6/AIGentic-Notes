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
   - `users`: id, username, password_hash, created_at.
   - `tasks`: id, user_id, title, description, due_date, is_completed, completed_at, notification_id, source_type, priority.
2. Modelos: Genera `TaskModel` y `UserModel` con métodos `toMap()` y `fromMap()`.
3. Dashboard Query (Vital): El método `getDashboardTasks()` debe filtrar:
   - Todas las pendientes (`is_completed = 0`).
   - Y las completadas (`is_completed = 1`) SOLO si `completed_at` es posterior a hace 2 días (`datetime('now', '-2 days')`).
   - Ordenar por `due_date` ASC.
4. CRUD: Métodos para insert, update, delete y get.