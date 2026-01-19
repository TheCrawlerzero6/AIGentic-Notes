class Constants {
  // Base de datos
  static const String dbName = 'mi_agenda.db';
  static const int dbVersion = 1;

  // Tablas
  static const String tableUsers = 'users';
  static const String tableProjects = 'projects';
  static const String tableTasks = 'tasks';
  
  static const String tableNotifications = 'notifications';

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

  static const bool MULTI_TASK_CREATION = true;

  static const bool INTELLIGENT_DISTRIBUTION = true;

  /// Duración máxima de grabación de audio (en segundos)
  ///
  /// Límite para evitar archivos grandes. Las tareas típicamente se dictan
  /// en menos de 60 segundos.
  // ignore: constant_identifier_names
  static const int MAX_AUDIO_DURATION_SECONDS = 60;

  /// Tipos MIME soportados para audio
  // ignore: constant_identifier_names
  static const String AUDIO_MIME_TYPE =
      'audio/aac'; // AAC = mejor compresión para móvil

  static String _getDayOfWeek(int weekday) {
    const days = ['lunes', 'martes', 'miércoles', 'jueves', 'viernes', 'sábado', 'domingo'];
    return days[weekday - 1];
  }

  static String getImagePrompt([String? projectsContext]) {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    final nowWithOffset = '${now.toIso8601String().split('.')[0]}${now.timeZoneOffset.isNegative ? '-' : '+'}${now.timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:${(now.timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
    final dayOfWeek = _getDayOfWeek(now.weekday);

    if (projectsContext != null && INTELLIGENT_DISTRIBUTION) {
      return '''Extrae tareas de la imagen y clasifícalas en proyectos.

$projectsContext

REFERENCIA TEMPORAL: Ahora=$nowWithOffset ($dayOfWeek) | Hora=$currentTime
IMPORTANTE: Retorna todas las fechas en formato ISO8601 usando el MISMO offset de zona horaria que "Ahora"

ESTRUCTURA JSON:
{
  "task_distributions": [{"project_id": 1, "tasks": [{"title": "...", "description": "...", "due_date": "YYYY-MM-DDTHH:MM:SS-05:00" | null, "priority": 1-3}]}],
  "new_projects": [{"title": "...", "tasks": [...]}]
}

FECHAS/HORAS:
- "hoy" → $today + hora mencionada (o null)
- "mañana" → +1 día + hora (o null)
- "lunes", "martes", "miércoles", etc. → Próximo día de esa semana desde hoy ($dayOfWeek)
- Sin fecha → null
- Fecha sin hora → "YYYY-MM-DDT00:00:00"
- Fecha+hora → "YYYY-MM-DDTHH:MM:SS"

REGLA CRÍTICA:
- Extrae TODAS las tareas sin excepción, no omitas ninguna
- Cada tarea mantiene su PROPIA fecha, NO las mezcles
- Si hay 5 tareas con fechas diferentes, retorna las 5 con sus fechas respectivas

PRIORIDAD: "urgente/importante/crítico"=3 | "cuando puedas/sin prisa"=1 | default=2

CLASIFICACIÓN (IMPORTANTE - Analiza el CONTEXTO real de cada tarea):
- "Comprar pan/leche/supermercado" → NUEVO proyecto "Compras" (NO es Personal)
- "Ejercicio/gym/correr" → NUEVO proyecto "Fitness" (NO es Personal)
- "Estudiar/examen/universidad" → NUEVO proyecto "Estudios" (NO es Personal)
- "Reunión/email/reporte" → Busca proyecto "Trabajo" o similar existente
- "Pagar/trámite/documentos" → Proyecto "Personal" SÍ aplica aquí

REGLA: NO pongas TODAS las tareas en el MISMO proyecto por defecto.
Analiza el TEMA de cada tarea y crea proyectos específicos cuando sea necesario.
Si 3 tareas son de compras, 2 de gym y 1 personal → Crea 3 distribuciones diferentes.''';
    } else if (MULTI_TASK_CREATION) {
      return '''Extrae TODAS las tareas de la imagen sin omitir ninguna.

REFERENCIA TEMPORAL: Ahora=$nowWithOffset ($dayOfWeek) | Hora=$currentTime
IMPORTANTE: Retorna todas las fechas en formato ISO8601 usando el MISMO offset de zona horaria que "Ahora"

JSON:
{
  "tasks": [{"title": "...", "description": "...", "due_date": "YYYY-MM-DDTHH:MM:SS-05:00" | null, "priority": 1-3}]
}

FECHAS:
- "hoy"→$today+hora | "mañana"→+1día+hora
- "lunes", "martes", "miércoles", etc. → Próximo día desde $dayOfWeek
- Sin fecha→null | Sin hora→"T00:00:00"

REGLA: Cada tarea conserva su PROPIA fecha, no las mezcles. Si hay 3 tareas, retorna las 3.
PRIORIDAD: urgente=3 | sin prisa=1 | default=2''';
    } else {
      return '''Extrae SOLO la PRIMERA tarea visible.

REFERENCIA TEMPORAL: Ahora=$nowWithOffset
IMPORTANTE: Retorna la fecha en formato ISO8601 usando el MISMO offset de zona horaria que "Ahora"

JSON:
{"tasks": [{"title": "...", "description": "...", "due_date": "YYYY-MM-DDTHH:MM:SS-05:00" | null, "priority": 1-3}]}

Fecha sin hora → "T00:00:00" | Sin fecha → null''';
    }
  }

  static String getAudioPrompt([String? projectsContext]) {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    final nowWithOffset = '${now.toIso8601String().split('.')[0]}${now.timeZoneOffset.isNegative ? '-' : '+'}${now.timeZoneOffset.inHours.abs().toString().padLeft(2, '0')}:${(now.timeZoneOffset.inMinutes.abs() % 60).toString().padLeft(2, '0')}';
    final dayOfWeek = _getDayOfWeek(now.weekday);

    if (projectsContext != null && INTELLIGENT_DISTRIBUTION) {
      return '''Transcribe audio y clasifica TODAS las tareas mencionadas.

$projectsContext

REFERENCIA TEMPORAL: Ahora=$nowWithOffset ($dayOfWeek)

FORMATO DE FECHAS OBLIGATORIO:
- USA el offset de zona horaria del "Ahora" de referencia
- NUNCA uses "Z" (UTC) al final
- Ejemplo CORRECTO: "2026-01-19T14:30:00-05:00"
- Ejemplo INCORRECTO: "2026-01-19T14:30:00.000Z"

JSON:
{
  "task_distributions": [{"project_id": 1, "tasks": [{"title": "...", "description": "Transcripción+detalles", "due_date": "2026-01-19T14:30:00-05:00" | null, "priority": 1-3}]}],
  "new_projects": [{"title": "...", "tasks": [...]}]
}

CÁLCULO DE FECHAS (usando hora local del usuario):
- "hoy a las 3pm" → "$today" + "T15:00:00-05:00"
- "mañana" → día siguiente + hora actual + "-05:00"
- "tarde" → 18:00:00-05:00 | "noche" → 21:00:00-05:00
- Sin hora específica → null

REGLA CRÍTICA: NO omitas ninguna tarea mencionada. Cada tarea mantiene su fecha individual.
PRIORIDAD: urgente/ya/rápido=3 | sin prisa=1 | default=2

CLASIFICACIÓN (Analiza el TEMA de cada tarea):
- "Comprar pan/leche/supermercado" → NUEVO proyecto "Compras"
- "Ejercicio/gym/correr" → NUEVO proyecto "Fitness"
- "Estudiar/leer/tarea" → NUEVO proyecto "Estudios"
- "Reunión/trabajo/email" → Busca proyecto existente relacionado con trabajo

NO asignes TODAS las tareas al mismo proyecto. Evalúa el contexto de cada una.''';    }

    final mode = MULTI_TASK_CREATION ? 'TODAS las tareas sin omitir ninguna' : 'SOLO la PRIMERA tarea';
    return '''Transcribe audio y extrae $mode.

REFERENCIA TEMPORAL: Ahora=$nowWithOffset ($dayOfWeek)

⚠️ FORMATO DE FECHAS OBLIGATORIO:
- USA el offset del "Ahora" de referencia (ejemplo: -05:00)
- NUNCA termines con "Z"
- Ejemplo CORRECTO: "2026-01-19T14:30:00-05:00"
- Ejemplo INCORRECTO: "2026-01-19T14:30:00Z" ❌

JSON:
{"tasks": [{"title": "...", "description": "Transcripción completa", "due_date": "2026-01-19T14:30:00-05:00" | null, "priority": 1-3}]}

CÁLCULO DE FECHAS:
- "mañana"→+1día+hora actual+offset | "tarde"→18:00:00+offset | Sin mención→null

REGLA: Cada tarea con su propia fecha, no las mezcles.
PRIORIDAD: urgente=3 | sin prisa=1 | default=2''';
  }
}
