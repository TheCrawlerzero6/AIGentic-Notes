class Constants {
  // Base de datos
  static const String dbName = 'mi_agenda.db';
  static const int dbVersion = 1;

  // Tablas
  static const String tableUsers = 'users';
  static const String tableProjects = 'projects';
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

  static const bool MULTI_TASK_CREATION = false;

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

  /// Retorna el prompt adecuado para procesamiento de imágenes según scope
  ///
  /// El prompt varía dependiendo de si se permite creación múltiple de tareas.
  /// En MVP se extrae solo la primera tarea visible, en modo avanzado se
  /// extraen todas las tareas encontradas en la imagen.
  static String getImagePrompt() {
    if (MULTI_TASK_CREATION) {
      return '''Analiza esta imagen y extrae TODAS las tareas, recordatorios o eventos visibles.

Devuelve un array JSON con esta estructura exacta:
{
  "tasks": [
    {
      "title": "Título corto de la tarea",
      "description": "Descripción detallada (opcional)",
      "due_date": "2026-01-15T14:30:00" o null si no hay fecha,
      "priority": 1, 2 o 3 (1=Baja, 2=Media, 3=Alta)
    }
  ]
}

Reglas:
- Extrae TODAS las tareas encontradas en la imagen
- Si no hay fecha clara en el texto, usa null
- Infiere prioridad del contexto (palabras como "urgente", "importante")
- description puede ser null si no hay detalles adicionales''';
    } else {
      return '''Analiza esta imagen y extrae SOLO LA PRIMERA tarea, recordatorio o evento visible.

Devuelve un array JSON con UN ÚNICO elemento:
{
  "tasks": [
    {
      "title": "Título corto de la tarea",
      "description": "Descripción detallada (opcional)",
      "due_date": "2026-01-15T14:30:00" o null si no hay fecha,
      "priority": 1, 2 o 3 (1=Baja, 2=Media, 3=Alta)
    }
  ]
}

Reglas:
- Extrae SOLO la primera tarea visible, ignora todas las demás
- Si no hay fecha clara en el texto, usa null
- Infiere prioridad del contexto (palabras como "urgente", "importante")
- description puede ser null si no hay detalles adicionales''';
    }
  }

  static String getAudioPrompt() {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];

    final baseInstructions =
        '''
        TRANSCRIBE el audio y extrae información para crear ${MULTI_TASK_CREATION ? 'tareas' : 'UNA tarea'}.

        FECHA ACTUAL: $today (úsala como referencia)

        Reglas de inferencia de fechas:
        - "mañana" → +1 día a las 23:59
        - "pasado mañana" → +2 días a las 23:59
        - "próxima semana" / "la próxima semana" → +7 días a las 23:59
        - "en X días" → +X días a las 23:59
        - "hoy" / "hoy mismo" → hoy a las 23:59
        - "esta tarde" → hoy a las 18:00
        - "esta noche" → hoy a las 21:00
        - Si NO menciona fecha → +1 día (mañana a las 23:59)

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
