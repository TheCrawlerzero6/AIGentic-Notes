import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import '../models/task_model.dart';
import '../../config/feature_flags.dart';

/// Tipos de contenido soportados por el servicio de IA
enum ContentType {
  image,  // Imágenes (JPG, PNG)
  audio,  // Audio (AAC, WAV, MP3, OGG, FLAC)
  file,   // Archivos (Excel, PDF, Word)
}

class AiService {
  // Singleton
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  GenerativeModel? _model;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // FirebaseAI.googleAI() lee automáticamente la API key desde google-services.json
      final ai = FirebaseAI.googleAI();

      // Configurar modelo con salida JSON estructurada
      _model = ai.generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topK: 32,
          topP: 1.0,
          maxOutputTokens: 2048,
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'tasks': Schema.array(
                items: Schema.object(
                  properties: {
                    'title': Schema.string(description: 'Título de la tarea'),
                    'description': Schema.string(
                      description: 'Descripción detallada',
                      nullable: true,
                    ),
                    'due_date': Schema.string(
                      description: 'Fecha ISO8601',
                      format: 'date-time',
                      nullable: true,
                    ),
                    'priority': Schema.integer(
                      description: '1=Baja, 2=Media, 3=Alta',
                      minimum: 1,
                      maximum: 3,
                    ),
                  },
                  optionalProperties: ['description', 'due_date'],
                ),
              ),
            },
          ),
        ),
      );

      _isInitialized = true;
      debugPrint('AiService: Inicializado con gemini-2.5-flash');
    } catch (e) {
      debugPrint('AiService: Error inicializando - $e');
      rethrow;
    }
  }

  /// Testing: Validar que la conexión con Gemini funciona correctamente
  ///
  /// Envía un prompt simple y retorna la respuesta para verificar
  /// que el modelo está accesible y respondiendo.
  Future<String> testConnection() async {
    if (!_isInitialized) await initialize();

    try {
      final response = await _model!.generateContent([
        Content.text('Responde SOLO con la palabra "OK" si me entiendes.')
      ]);

      final text = response.text ?? 'ERROR: Sin respuesta';
      debugPrint('AiService: Test conexión - $text');
      return text;
    } catch (e) {
      debugPrint('AiService: Error test conexión - $e');
      rethrow;
    }
  }

  /// Procesa contenido multimodal (imagen, audio, archivo) y extrae tareas
  Future<List<TaskModel>> processMultimodalContent({
    required Uint8List data,
    required ContentType type,
    required int userId,
  }) async {
    if (!_isInitialized) await initialize();

    debugPrint('AiService: Procesando contenido tipo: ${type.name}');

    switch (type) {
      case ContentType.image:
        return _processImage(data, userId);
      case ContentType.audio:
        return _processAudio(data, userId);
      case ContentType.file:
        return _processFile(data, userId);
    }
  }

  /// Procesa imagen con Gemini Vision
  Future<List<TaskModel>> _processImage(Uint8List imageBytes, int userId) async {

    try {
      final prompt = FeatureFlags.getImagePrompt();
      final imagePart = InlineDataPart('image/jpeg', imageBytes);

      final response = await _model!.generateContent([
        Content.multi([TextPart(prompt), imagePart])
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('La IA no pudo procesar la imagen');
      }

      // LOG: Ver respuesta completa de Gemini
      debugPrint('=== RESPUESTA GEMINI (RAW) ===');
      debugPrint(response.text!);
      debugPrint('=== FIN RESPUESTA ===');

      final jsonText = _extractJson(response.text!);
      
      // LOG: Ver JSON limpio
      debugPrint('=== JSON EXTRAÍDO ===');
      debugPrint(jsonText);
      debugPrint('=== FIN JSON ===');
      
      final jsonData = jsonDecode(jsonText);
      final tasksList = jsonData['tasks'] as List;

      if (tasksList.isEmpty) {
        throw Exception('No se encontraron tareas en la imagen');
      }

      // Validar que la primera tarea tenga un título válido
      final firstTask = tasksList.first;
      if (firstTask['title'] == null || 
          (firstTask['title'] as String).trim().isEmpty) {
        throw Exception('La IA no pudo extraer información válida de la imagen');
      }

      debugPrint('✓ Título extraído: ${firstTask['title']}');

      // Aplicar scope MVP: solo primera tarea o todas
      final tasksToProcess = FeatureFlags.MULTI_TASK_CREATION
          ? tasksList
          : [tasksList.first];

      final tasks = <TaskModel>[];
      for (var taskJson in tasksToProcess) {
        String? dueDateString;
        if (taskJson['due_date'] != null) {
          dueDateString = taskJson['due_date'] as String;
        }

        tasks.add(TaskModel(
          title: taskJson['title'] as String,
          description: taskJson['description'] as String? ?? '',
          dueDate: dueDateString ?? DateTime.now().toIso8601String(),
          isCompleted: 0,
          userId: userId,
          priority: taskJson['priority'] as int? ?? 2,
          sourceType: 'image',
        ));
      }

      debugPrint('AiService: Procesadas ${tasks.length} tareas');
      return tasks;
    } catch (e) {
      debugPrint('Error procesando imagen: $e');
      if (e.toString().contains('quota') || e.toString().contains('RESOURCE_EXHAUSTED')) {
        throw Exception('Configura tu API key en Google AI Studio');
      }
      rethrow;
    }
  }

  /// Procesa audio con Gemini (transcribe y extrae tareas)
  Future<List<TaskModel>> _processAudio(Uint8List audioBytes, int userId) async {
    try {
      final prompt = FeatureFlags.getAudioPrompt();
      final audioPart = InlineDataPart(FeatureFlags.AUDIO_MIME_TYPE, audioBytes);

      final response = await _model!.generateContent([
        Content.multi([TextPart(prompt), audioPart])
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('La IA no pudo procesar el audio');
      }

      debugPrint('=== RESPUESTA GEMINI AUDIO (RAW) ===');
      debugPrint(response.text!);
      debugPrint('=== FIN RESPUESTA ===');

      final jsonText = _extractJson(response.text!);
      
      debugPrint('=== JSON EXTRAÍDO (AUDIO) ===');
      debugPrint(jsonText);
      debugPrint('=== FIN JSON ===');
      
      final jsonData = jsonDecode(jsonText);
      final tasksList = jsonData['tasks'] as List;

      if (tasksList.isEmpty) {
        throw Exception('No se encontraron tareas en el audio');
      }

      final firstTask = tasksList.first;
      if (firstTask['title'] == null || 
          (firstTask['title'] as String).trim().isEmpty) {
        throw Exception('La IA no pudo extraer información válida del audio');
      }

      debugPrint('✓ Título extraído de audio: ${firstTask['title']}');

      final tasksToProcess = FeatureFlags.MULTI_TASK_CREATION
          ? tasksList
          : [tasksList.first];

      final tasks = <TaskModel>[];
      for (var taskJson in tasksToProcess) {
        String? dueDateString;
        if (taskJson['due_date'] != null) {
          dueDateString = taskJson['due_date'] as String;
        }

        tasks.add(TaskModel(
          title: taskJson['title'] as String,
          description: taskJson['description'] as String? ?? '',
          dueDate: dueDateString ?? DateTime.now().toIso8601String(),
          isCompleted: 0,
          userId: userId,
          priority: taskJson['priority'] as int? ?? 2,
          sourceType: 'audio',
        ));
      }

      debugPrint('AiService: Procesadas ${tasks.length} tareas desde audio');
      return tasks;
    } catch (e) {
      debugPrint('Error procesando audio: $e');
      if (e.toString().contains('quota') || e.toString().contains('RESOURCE_EXHAUSTED')) {
        throw Exception('Límite de API alcanzado. Intenta más tarde');
      }
      rethrow;
    }
  }

  /// Procesa archivos (Excel, PDF, Word) - PENDIENTE
  Future<List<TaskModel>> _processFile(Uint8List fileBytes, int userId) async {
    debugPrint('AiService._processFile: Pendiente implementación');
    throw UnimplementedError('Procesamiento de archivos pendiente para Fase 2');
  }

  /// Extrae JSON de markdown fences si existe
  String _extractJson(String text) {
    final jsonPattern = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = jsonPattern.firstMatch(text);
    return match != null ? match.group(1)! : text.trim();
  }

  /// @deprecated Usar processMultimodalContent()
  Future<List<TaskModel>> processImageToTasks({
    required Uint8List imageBytes,
    required int userId,
  }) async {
    return processMultimodalContent(
      data: imageBytes,
      type: ContentType.image,
      userId: userId,
    );
  }

  /// Procesa texto natural y lo convierte en una o más tareas
  /// 
  /// PENDIENTE: Implementar en Sprint futuro
  Future<List<TaskModel>> processTextToTasks({
    required String prompt,
    required int userId,
  }) async {
    debugPrint('AiService.processTextToTasks: Pendiente implementación');
    return [];
  }

  /// Procesa archivo Excel y extrae tareas de las filas
  /// 
  /// PENDIENTE: Implementar en Sprint futuro
  Future<List<TaskModel>> processFileToTasks({
    required String filePath,
    required int userId,
  }) async {
    debugPrint('AiService.processFileToTasks: Pendiente implementación');
    return [];
  }
}
