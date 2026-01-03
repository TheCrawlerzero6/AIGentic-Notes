import 'package:flutter/foundation.dart';
import '../models/task_model.dart';

/// Servicio de IA para procesar inputs multimodales y convertirlos en tareas
/// 
/// NOTA: Implementación DESACTIVADA hasta FASE 7 (IA Multimodal)
/// Firebase AI requiere configuración adicional y ajustes de API
class AiService {
  // Singleton
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  /// Inicializa el servicio Firebase AI Logic
  /// 
  /// DESACTIVADO: Requiere configuración Firebase y ajustes API
  void initialize() {
    debugPrint('AiService: Inicialización desactivada (FASE 7 pendiente)');
    // TODO FASE 7: Configurar Firebase AI Logic
    // _ai = FirebaseAI.instance;
    // _model = _ai.generativeModel(model: 'gemini-2.0-flash-exp');
  }

  /// Procesa texto natural y lo convierte en una o más tareas
  /// 
  /// DESACTIVADO: Requiere Firebase AI configurado (FASE 7)
  Future<List<TaskModel>> processTextToTasks({
    required String prompt,
    required int userId,
  }) async {
    debugPrint('AiService.processTextToTasks: Desactivado hasta FASE 7');
    return [];
    
    /* TODO FASE 7: Descomentar implementación completa
    try {
      final schema = Schema.object(
        properties: {
          'tasks': Schema.array(
            items: Schema.object(
              properties: {
                'title': Schema.string(description: 'Título corto de la tarea'),
                'description': Schema.string(description: 'Descripción detallada'),
                'due_date': Schema.string(description: 'Fecha ISO8601'),
                'priority': Schema.integer(description: '1=baja, 2=media, 3=alta'),
              },
              requiredProperties: ['title', 'description', 'due_date', 'priority'],
            ),
          ),
        },
      );
      // ... resto de implementación
    } catch (e) {
      debugPrint('Error en AiService.processTextToTasks: $e');
      rethrow;
    }
    */
  }

  /// Procesa imagen y extrae tareas mediante OCR + análisis
  /// 
  /// DESACTIVADO: Requiere Firebase AI configurado (FASE 7)
  Future<List<TaskModel>> processImageToTasks({
    required List<int> imageBytes,
    required int userId,
  }) async {
    debugPrint('AiService.processImageToTasks: Desactivado hasta FASE 7');
    return [];
    
    /* TODO FASE 7: Implementar con Vision API
    try {
      final imagePart = DataPart('image/jpeg', imageBytes);
      final response = await _model.generateContent([
        Content.multi([
          imagePart,
          TextPart('Extrae todas las tareas de esta imagen...'),
        ]),
      ]);
      // ... parseo de respuesta
    } catch (e) {
      debugPrint('Error en AiService.processImageToTasks: $e');
      rethrow;
    }
    */
  }

  /// Procesa archivo Excel y extrae tareas de las filas
  /// 
  /// DESACTIVADO: Requiere Firebase AI configurado (FASE 7)
  Future<List<TaskModel>> processFileToTasks({
    required String filePath,
    required int userId,
  }) async {
    debugPrint('AiService.processFileToTasks: Desactivado hasta FASE 7');
    return [];
    
    /* TODO FASE 7: Implementar parseo Excel
    try {
      // Leer Excel con package 'excel'
      // Extraer filas y columnas
      // Generar TaskModel por cada fila
    } catch (e) {
      debugPrint('Error en AiService.processFileToTasks: $e');
      rethrow;
    }
    */
  }
}
