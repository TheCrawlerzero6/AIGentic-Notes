/// Configuración de funcionalidades experimentales y scope MVP
///
/// Este archivo centraliza las banderas de características para controlar
/// el comportamiento de funcionalidades en desarrollo vs producción.
class FeatureFlags {
  // ========== IA MULTIMODAL ==========

  /// Control de creación múltiple de tareas desde IA
  /// 
  /// false: Solo procesa la primera tarea encontrada (MVP actual)
  /// true: Procesa todas las tareas encontradas con dialog confirmación
  // ignore: constant_identifier_names
  static const bool MULTI_TASK_CREATION = false;

  /// Duración máxima de grabación de audio (en segundos)
  /// 
  /// Límite para evitar archivos grandes. Las tareas típicamente se dictan
  /// en menos de 60 segundos.
  // ignore: constant_identifier_names
  static const int MAX_AUDIO_DURATION_SECONDS = 60;

  /// Tipos MIME soportados para audio
  // ignore: constant_identifier_names
  static const String AUDIO_MIME_TYPE = 'audio/aac'; // AAC = mejor compresión para móvil

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

  /// Retorna el prompt adecuado para procesamiento de audio según scope
  ///
  /// El prompt varía dependiendo de si se permite creación múltiple de tareas.
  /// Incluye reglas de inferencia de fechas relativas y prioridad según tono.
  static String getAudioPrompt() {
    final now = DateTime.now();
    final today = now.toIso8601String().split('T')[0];
    
    final baseInstructions = '''
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

  // ========== FUTURAS FLAGS ==========
  // static const bool EXCEL_PARSING_ENABLED = false;
  // static const bool AUDIO_DICTATION_ENABLED = false;
}
