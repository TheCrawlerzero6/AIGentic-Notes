# Contexto del Proyecto: Agenda Inteligente MVP

Aplicación Local-First en Flutter. Privacidad total con SQLite y procesamiento de IA en la nube mediante Firebase.

## 1. Stack Tecnológico (Estricto)
- Frontend: Flutter + Provider (Gestión de Estado)
- Datos: sqflite (SQLite Local)
- IA: firebase_ai (SDK Unificado para Gemini)
- Notificaciones: flutter_local_notifications
- Utils: intl, file_picker, crypto

## 2. Esquema de Base de Datos (SQLite)
Fuente única de verdad. Crear estas 2 tablas obligatoriamente.

### Tabla users
- id (INTEGER PK AUTOINCREMENT)
- username (TEXT)
- password_hash (TEXT)
- createdAt (TEXT)

### Tabla tasks
- id (INTEGER PK AUTOINCREMENT)
- user_id (INTEGER FK)
- title (TEXT)
- description (TEXT)
- dueDate (TEXT ISO8601)
- isCompleted (INTEGER)
- completedAt (TEXT ISO8601)
- notificationId (INTEGER)
- source_type (TEXT)
- priority (INTEGER)

## 3. Reglas de Negocio Críticas

### A. Visibilidad (Regla de las 48 Horas)
La consulta SQL del Dashboard debe filtrar así:
- Muestra TODAS las pendientes (isCompleted = 0)
- Muestra completadas (isCompleted = 1) SOLO si completedAt es mayor a hace 2 días
- Oculta las completadas antiguas para no saturar la vista

### B. Ciclo de Notificaciones
- Al Crear: Generar notificationId y programar alerta local en dueDate
- Al Completar: Cancelar la alerta usando notificationId
- Al Des-completar: Reprogramar la alerta si la fecha es futura

### C. Integración IA (firebase_ai)
- Usar Function Calling para obligar a la IA a devolver JSON exacto
- Configurar el backend como FirebaseAI.googleAI() para desarrollo gratuito
- No guardar datos en la nube; la IA solo procesa y devuelve al cliente

## 4. Estructura de Carpetas
- lib/data/: Modelos, DB Helper, Servicios
- lib/providers/: Lógica de negocio
- lib/ui/: Pantallas y Widgets