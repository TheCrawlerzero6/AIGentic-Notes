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

  static String getImagePrompt([String? projectsContext]) {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    final currentTime = '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

    if (projectsContext != null && INTELLIGENT_DISTRIBUTION) {
      return '''Eres un asistente experto en organización de tareas.

$projectsContext

FECHA ACTUAL: $today
HORA ACTUAL: $currentTime

TU TAREA: Analizar la imagen, extraer todas las tareas, y clasificar cada una en el proyecto MÁS RELEVANTE.

EJEMPLOS DE CLASIFICACIÓN CORRECTA:
1. Tarea: "Comprar leche" | Proyectos: [Trabajo, Gimnasio] → Crear proyecto "Compras"
2. Tarea: "Enviar reporte" | Proyectos: [Trabajo, Personal] → Asignar a "Trabajo"
3. Tarea: "Hacer cardio" | Proyectos: [Trabajo, Gimnasio] → Asignar a "Gimnasio"
4. Tarea: "Pagar impuestos" | Proyectos: [Trabajo, Personal] → Asignar a "Personal"
5. Tarea: "Comprar manzanas, pan, leche" → Crear UN proyecto "Compras" con 3 tareas

Devuelve un JSON con esta estructura:
{
  "task_distributions": [
    {
      "project_id": 1,
      "tasks": [
        {
          "title": "Título de la tarea",
          "description": "Descripción (opcional)",
          "due_date": "2026-01-15T14:30:00" o null,
          "priority": 1, 2 o 3
        }
      ]
    }
  ],
  "new_projects": [
    {
      "title": "Nombre del proyecto",
      "tasks": [...]
    }
  ]
}

Reglas OBLIGATORIAS de fecha/hora:
- "hoy" / "hoy mismo" → $today con la hora mencionada o null si no hay hora
- "mañana" → día siguiente a $today con la hora mencionada o null si no hay hora
- "pasado mañana" → dos días después de $today con la hora o null
- Si NO menciona fecha → usa null
- Si menciona fecha pero NO hora → usa "YYYY-MM-DDT00:00:00"
- Si menciona fecha Y hora → usa "YYYY-MM-DDTHH:MM:SS"
- Formato SIEMPRE: "YYYY-MM-DDTHH:MM:SS" o null

CRITERIO DE RELEVANCIA:
- Si la tarea menciona el dominio del proyecto, asignar ahí
- Si la tarea es genérica, evaluar contexto del usuario
- PRIORIZA asignar a proyectos existentes (incluso si no es match perfecto)
- Solo crear nuevo proyecto si la tarea NO encaja en NINGUNO de los existentes

REGLA CRÍTICA: Solo crea UN nuevo proyecto si NINGUNO de los existentes es adecuado.
Si varias tareas similares no encajan, agrúpalas en UN SOLO proyecto nuevo.
NO crear proyectos individuales por tarea.

Extraer TODAS las tareas encontradas en la imagen.''';
    } else if (MULTI_TASK_CREATION) {
      return '''Analiza esta imagen y extrae TODAS las tareas, recordatorios o eventos visibles.

FECHA ACTUAL: $today
HORA ACTUAL: $currentTime

Devuelve un array JSON con esta estructura exacta:
{
  "tasks": [
    {
      "title": "Título corto de la tarea",
      "description": "Descripción detallada (opcional)",
      "due_date": "2026-01-15T14:30:00" o null,
      "priority": 1, 2 o 3 (1=Baja, 2=Media, 3=Alta)
    }
  ]
}

Reglas OBLIGATORIAS de fecha/hora:
- "hoy" / "hoy mismo" → $today con la hora mencionada o null si no hay hora
- "mañana" → día siguiente a $today con la hora mencionada o null si no hay hora
- "pasado mañana" → dos días después de $today con la hora o null
- Si NO menciona fecha → usa null
- Si menciona fecha pero NO hora → usa "YYYY-MM-DDT00:00:00"
- Si menciona fecha Y hora → usa "YYYY-MM-DDTHH:MM:SS"
- Formato SIEMPRE: "YYYY-MM-DDTHH:MM:SS" o null

Prioridad:
- Palabras como "urgente", "importante", "crítico" → 3 (Alta)
- Palabras como "cuando puedas", "sin prisa" → 1 (Baja)
- Sin indicadores → 2 (Media)

Extrae TODAS las tareas encontradas en la imagen.''';
    } else {
      return '''Analiza esta imagen y extrae SOLO LA PRIMERA tarea, recordatorio o evento visible.

FECHA ACTUAL: $today
HORA ACTUAL: $currentTime

Devuelve un array JSON con UN ÚNICO elemento:
{
  "tasks": [
    {
      "title": "Título corto de la tarea",
      "description": "Descripción detallada (opcional)",
      "due_date": "2026-01-15T14:30:00" o null,
      "priority": 1, 2 o 3 (1=Baja, 2=Media, 3=Alta)
    }
  ]
}

Reglas:
- Extrae SOLO la primera tarea visible
- Usa la FECHA ACTUAL ($today) para interpretar "hoy", "mañana", etc.
- Si no hay fecha clara, usa null
- Si hay fecha sin hora, usa "YYYY-MM-DDT00:00:00"
- Infiere prioridad del contexto''';
    }
  }

  static String getAudioPrompt([String? projectsContext]) {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];

    if (projectsContext != null && INTELLIGENT_DISTRIBUTION) {
      return '''Eres un asistente experto en organización de tareas.

$projectsContext

FECHA ACTUAL: $today

TU TAREA: Transcribir el audio, extraer todas las tareas y clasificarlas en el proyecto MÁS RELEVANTE.

EJEMPLOS DE CLASIFICACIÓN CORRECTA:
1. "Enviar reporte" | Proyectos: [Trabajo, Personal] → "Trabajo"
2. "Comprar leche" | Proyectos: [Trabajo, Gimnasio] → Crear "Compras"
3. "Hacer cardio" | Proyectos: [Trabajo, Gimnasio] → "Gimnasio"
4. "Pagar impuestos" | Proyectos: [Trabajo, Personal] → "Personal"
5. "Comprar manzanas, pan, leche" → Crear UN proyecto "Compras" con 3 tareas

Devuelve un JSON con esta estructura:
{
  "task_distributions": [
    {
      "project_id": 1,
      "tasks": [
        {
          "title": "Título claro y conciso",
          "description": "Transcripción completa + detalles",
          "due_date": "YYYY-MM-DDTHH:MM:SS" o null,
          "priority": 1 o 2 o 3
        }
      ]
    }
  ],
  "new_projects": [
    {
      "title": "Nombre del proyecto",
      "tasks": [...]
    }
  ]
}

Reglas OBLIGATORIAS de fecha/hora:
- "mañana" → +1 día con la hora mencionada, si no hay hora usa null
- "pasado mañana" → +2 días con la hora mencionada, si no hay hora usa null
- "hoy" / "hoy mismo" → hoy con la hora mencionada, si no hay hora usa null
- "esta tarde" → hoy a las 18:00
- "esta noche" → hoy a las 21:00
- SI NO MENCIONA FECHA → usa null
- SI NO MENCIONA HORA → usa null
- Formato SIEMPRE: "YYYY-MM-DDTHH:MM:SS" o null

Prioridad según tono/palabras:
- "urgente", "importante", "ya", "rápido", "crítico" → priority: 3 (Alta)
- "cuando puedas", "no urge", "tranquilo", "sin prisa" → priority: 1 (Baja)
- Sin indicadores → priority: 2 (Media)

CRITERIO DE RELEVANCIA:
- Si la tarea menciona el dominio del proyecto, asignar ahí
- Si es genérica, evaluar contexto
- PRIORIZA asignar a proyectos existentes incluso si el match no es perfecto
- Solo crea nuevo proyecto si la tarea NO encaja en NINGUNO de los existentes

REGLA CRÍTICA: Solo crea UN nuevo proyecto si NINGUNO de los existentes es adecuado.
Si varias tareas similares no encajan, agrúpalas en UN SOLO proyecto nuevo.
NO crear proyectos individuales por tarea.
''';
    }

    final baseInstructions =
        '''
        TRANSCRIBE el audio y extrae información para crear ${MULTI_TASK_CREATION ? 'tareas' : 'UNA tarea'}.

        FECHA ACTUAL: $today (úsala como referencia)

        Reglas OBLIGATORIAS de fecha/hora:
        - "mañana" → +1 día con la hora mencionada, si no hay hora usa null
        - "pasado mañana" → +2 días con la hora mencionada, si no hay hora usa null
        - "hoy" / "hoy mismo" → hoy con la hora mencionada, si no hay hora usa null
        - "esta tarde" → hoy a las 18:00
        - "esta noche" → hoy a las 21:00
        - SI NO MENCIONA FECHA → usa null
        - SI NO MENCIONA HORA → usa null
        - Formato SIEMPRE: "YYYY-MM-DDTHH:MM:SS" o null

        Prioridad según tono/palabras:
        - "urgente", "importante", "ya", "rápido", "crítico" → priority: 3 (Alta)
        - "cuando puedas", "no urge", "tranquilo", "sin prisa" → priority: 1 (Baja)
        - Sin indicadores → priority: 2 (Media)

        ESTRUCTURA JSON OBLIGATORIA:
        {
          "tasks": [
            {
              "title": "Título claro y conciso",
              "description": "Transcripción completa del audio + detalles",
              "due_date": "YYYY-MM-DDTHH:MM:SS",
              "priority": 1 o 2 o 3
            }
          ]
        }
      ''';

    if (MULTI_TASK_CREATION) {
      return '''
        $baseInstructions
        IMPORTANTE: Extrae TODAS las tareas mencionadas en el audio.
        Si el usuario dice "tengo 3 cosas: A, B y C", crea 3 tareas separadas.
        ''';
    } else {
      return '''
        $baseInstructions
        IMPORTANTE: Extrae SOLO LA PRIMERA tarea mencionada en el audio.
        Si menciona varias tareas, ignora las demás y procesa solo la primera.
        ''';
    }
  }
}
