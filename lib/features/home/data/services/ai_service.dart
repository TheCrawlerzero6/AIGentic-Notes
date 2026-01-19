import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:firebase_ai/firebase_ai.dart';
import 'package:mi_agenda/core/constants.dart';

import '../../../../core/domain/dtos/project_dtos.dart';
import '../../../../core/data/models/task_model.dart';
import '../../domain/repositories/i_ai_service.dart';
import '../../../../core/domain/entities/task.dart';
import '../../../../core/domain/dtos/distribution_dtos.dart';
import '../../../../core/domain/entities/distribution_result.dart';

class AiService implements IAiService {
  // Singleton
  static final AiService _instance = AiService._internal();
  factory AiService() => _instance;
  AiService._internal();

  GenerativeModel? _model;
  GenerativeModel? _distributionModel;
  bool _isInitialized = false;

  // Contador de solicitudes para debugging
  int _totalRequests = 0;
  final List<DateTime> _requestTimestamps = [];

  @override
  int get totalRequests => _totalRequests;

  @override
  bool get isInitialized => _isInitialized;

  /// Obtiene el número de solicitudes en los últimos 60 segundos
  int getRequestsInLastMinute() {
    final now = DateTime.now();
    final oneMinuteAgo = now.subtract(const Duration(seconds: 60));
    _requestTimestamps.removeWhere(
      (timestamp) => timestamp.isBefore(oneMinuteAgo),
    );
    return _requestTimestamps.length;
  }

  /// Registra una nueva solicitud al API
  void _registerRequest() {
    _totalRequests++;
    _requestTimestamps.add(DateTime.now());

    final requestsLastMinute = getRequestsInLastMinute();
    debugPrint(
      'API Request #$_totalRequests | Últimos 60s: $requestsLastMinute | Límite diario: $_totalRequests/20',
    );

    if (_totalRequests >= 18) {
      debugPrint(
        'ADVERTENCIA: Acercándose al límite diario ($_totalRequests/20)',
      );
    }
  }

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // FirebaseAI.googleAI() lee automáticamente la API key desde google-services.json
      final ai = FirebaseAI.googleAI();

      // Configurar modelo gemini-2.5-flash con límite de 20 solicitudes diarias
      _model = ai.generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topK: 32,
          topP: 1.0,
          maxOutputTokens: 4096,
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
      debugPrint('Límite de API: 20 solicitudes por día');
    } catch (e) {
      debugPrint('AiService: Error inicializando - $e');
      rethrow;
    }
  }

  Future<void> _ensureDistributionModelInitialized() async {
    if (_distributionModel != null) return;
    try {
      final ai = FirebaseAI.googleAI();
      _distributionModel = ai.generativeModel(
        model: 'gemini-2.5-flash',
        generationConfig: GenerationConfig(
          temperature: 0.2,
          topK: 32,
          topP: 1.0,
          maxOutputTokens: 4096,
          responseMimeType: 'application/json',
          responseSchema: Schema.object(
            properties: {
              'task_distributions': Schema.array(
                items: Schema.object(
                  properties: {
                    'project_id': Schema.integer(),
                    'tasks': Schema.array(
                      items: Schema.object(
                        properties: {
                          'title': Schema.string(
                            description: 'Título de la tarea',
                          ),
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
              'new_projects': Schema.array(
                items: Schema.object(
                  properties: {
                    'title': Schema.string(
                      description: 'Título del proyecto nuevo',
                    ),
                    'suggested_description': Schema.string(nullable: true),
                    'suggested_icon': Schema.string(nullable: true),
                    'tasks': Schema.array(
                      items: Schema.object(
                        properties: {
                          'title': Schema.string(
                            description: 'Título de la tarea',
                          ),
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
            },
          ),
        ),
      );
    } catch (e) {
      debugPrint('AiService: Error inicializando modelo de distribución - $e');
      rethrow;
    }
  }

  Future<String> testConnection() async {
    if (!_isInitialized) await initialize();

    try {
      _registerRequest(); // Registrar solicitud

      final response = await _model!.generateContent([
        Content.text('Responde SOLO con la palabra "OK" si me entiendes.'),
      ]);

      final text = response.text ?? 'ERROR: Sin respuesta';

      // Logging de consumo de tokens
      if (response.usageMetadata != null) {
        debugPrint('=== CONSUMO DE TOKENS (testConnection) ===');
        debugPrint(
          'Tokens de entrada: ${response.usageMetadata!.promptTokenCount}',
        );
        debugPrint(
          'Tokens de salida: ${response.usageMetadata!.candidatesTokenCount}',
        );
        debugPrint('Total tokens: ${response.usageMetadata!.totalTokenCount}');
        debugPrint('==========================================');
      }

      debugPrint('AiService: Test conexión - $text');
      return text;
    } catch (e) {
      debugPrint('AiService: Error test conexión - $e');
      rethrow;
    }
  }

  @override
  Future<List<Task>> processMultimodalContent({
    required Uint8List data,
    required ContentType type,
    required int userId,
  }) async {
    if (!_isInitialized) await initialize();

    debugPrint('AiService: Procesando contenido tipo: ${type.name}');

    switch (type) {
      case ContentType.image:
        return await _processImage(data, userId);
      case ContentType.audio:
        return await _processAudio(data, userId);
      case ContentType.file:
        return await _processFile(data, userId);
    }
  }

  @override
  Future<DistributionResult> processMultimodalContentWithDistribution({
    required Uint8List data,
    required ContentType type,
    required List<DetailedProjectDto> existingProjects,
    required int userId,
  }) async {
    await _ensureDistributionModelInitialized();

    _registerRequest();

    final projectsContext = _buildProjectsContext(existingProjects);

    Content content;
    switch (type) {
      case ContentType.image:
        content = Content.multi([
          TextPart(Constants.getImagePrompt(projectsContext)),
          InlineDataPart('image/jpeg', data),
        ]);
        break;
      case ContentType.audio:
        content = Content.multi([
          TextPart(Constants.getAudioPrompt(projectsContext)),
          InlineDataPart(Constants.AUDIO_MIME_TYPE, data),
        ]);
        break;
      case ContentType.file:
        throw UnimplementedError('Distribución para archivos no implementada');
    }

    final response = await _distributionModel!.generateContent([content]);

    final rawText = response.text;
    if (rawText == null || rawText.isEmpty) {
      throw Exception('La IA no devolvió contenido');
    }

    final jsonText = _extractJson(rawText);
    final Map<String, dynamic> dataMap = jsonDecode(jsonText);

    final existingDistributions = <ProjectDistribution>[];
    final newDistributions = <NewProjectDistribution>[];

    if (dataMap['task_distributions'] is List) {
      for (final dist in (dataMap['task_distributions'] as List)) {
        final projectId = dist['project_id'] as int;
        final tasksJson = dist['tasks'] as List? ?? [];
        final tasks = tasksJson
            .map((taskJson) => _mapJsonToTaskModel(taskJson, projectId, type))
            .toList();
        existingDistributions.add(
          ProjectDistribution(projectId: projectId, tasks: tasks),
        );
      }
    }

    if (dataMap['new_projects'] is List) {
      for (final proj in (dataMap['new_projects'] as List)) {
        final title = proj['title'] as String? ?? '';
        final tasksJson = proj['tasks'] as List? ?? [];
        final tasks = tasksJson
            .map((taskJson) => _mapJsonToTaskModel(taskJson, 0, type))
            .toList();
        newDistributions.add(
          NewProjectDistribution(
            title: title,
            suggestedDescription: proj['suggested_description'] as String?,
            suggestedIcon: proj['suggested_icon'] as String?,
            tasks: tasks,
          ),
        );
      }
    }

    final totalTasksProcessed =
        existingDistributions.fold<int>(0, (prev, e) => prev + e.tasks.length) +
        newDistributions.fold<int>(0, (prev, e) => prev + e.tasks.length);

    return DistributionResult(
      existingProjectDistributions: existingDistributions,
      newProjectDistributions: newDistributions,
      totalTasksProcessed: totalTasksProcessed,
      projectsUsed: existingDistributions.length,
      newProjectsCreated: newDistributions.length,
    );
  }

  /// Procesa imagen con Gemini Vision
  Future<List<TaskModel>> _processImage(
    Uint8List imageBytes,
    int projectId,
  ) async {
    try {
      _registerRequest(); // Registrar solicitud

      final prompt = Constants.getImagePrompt();
      final imagePart = InlineDataPart('image/jpeg', imageBytes);

      final response = await _model!.generateContent([
        Content.multi([TextPart(prompt), imagePart]),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('La IA no pudo procesar la imagen');
      }

      // Logging de consumo de tokens
      if (response.usageMetadata != null) {
        debugPrint('=== CONSUMO DE TOKENS (Imagen) ===');
        debugPrint(
          'Tokens de entrada: ${response.usageMetadata!.promptTokenCount}',
        );
        debugPrint(
          'Tokens de salida: ${response.usageMetadata!.candidatesTokenCount}',
        );
        debugPrint('Total tokens: ${response.usageMetadata!.totalTokenCount}');
        debugPrint('=====================================');
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
        throw Exception(
          'La IA no pudo extraer información válida de la imagen',
        );
      }

      debugPrint('✓ Título extraído: ${firstTask['title']}');

      // Aplicar scope MVP: solo primera tarea o todas
      final tasksToProcess = Constants.MULTI_TASK_CREATION
          ? tasksList
          : [tasksList.first];

      final tasks = <TaskModel>[];
      for (var taskJson in tasksToProcess) {
        String? dueDateString;
        if (taskJson['due_date'] != null) {
          dueDateString = taskJson['due_date'] as String;
        }

        tasks.add(
          TaskModel(
            id: 0,
            title: taskJson['title'] as String,
            description: taskJson['description'] as String? ?? '',
            dueDate: dueDateString?.isNotEmpty ?? false
                ? _parseAiDateAsLocal(dueDateString!)
                : DateTime.now(),
            isCompleted: false,
            projectId: projectId,
            priority: taskJson['priority'] as int? ?? 2,
            sourceType: 'image',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      debugPrint('AiService: Procesadas ${tasks.length} tareas');
      return tasks;
    } catch (e) {
      debugPrint('Error procesando imagen: $e');
      rethrow;
    }
  }

  /// Procesa audio con Gemini (transcribe y extrae tareas)
  Future<List<TaskModel>> _processAudio(
    Uint8List audioBytes,
    int projectId,
  ) async {
    try {
      _registerRequest(); // Registrar solicitud

      final prompt = Constants.getAudioPrompt();
      final audioPart = InlineDataPart(Constants.AUDIO_MIME_TYPE, audioBytes);

      final response = await _model!.generateContent([
        Content.multi([TextPart(prompt), audioPart]),
      ]);

      if (response.text == null || response.text!.isEmpty) {
        throw Exception('La IA no pudo procesar el audio');
      }

      // Logging de consumo de tokens
      if (response.usageMetadata != null) {
        debugPrint('=== CONSUMO DE TOKENS (Audio) ===');
        debugPrint(
          'Tokens de entrada: ${response.usageMetadata!.promptTokenCount}',
        );
        debugPrint(
          'Tokens de salida: ${response.usageMetadata!.candidatesTokenCount}',
        );
        debugPrint('Total tokens: ${response.usageMetadata!.totalTokenCount}');
        debugPrint('====================================');
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

      final tasksToProcess = Constants.MULTI_TASK_CREATION
          ? tasksList
          : [tasksList.first];

      final tasks = <TaskModel>[];
      for (var taskJson in tasksToProcess) {
        String? dueDateString;
        if (taskJson['due_date'] != null) {
          dueDateString = taskJson['due_date'] as String;
        }

        tasks.add(
          TaskModel(
            id: 0,
            title: taskJson['title'] as String,
            description: taskJson['description'] as String? ?? '',
            dueDate: dueDateString?.isNotEmpty ?? false
                ? _parseAiDateAsLocal(dueDateString!)
                : DateTime.now(),
            isCompleted: false,
            projectId: projectId,
            priority: taskJson['priority'] as int? ?? 2,
            sourceType: 'audio',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
      }

      debugPrint('AiService: Procesadas ${tasks.length} tareas desde audio');
      return tasks;
    } catch (e) {
      debugPrint('Error procesando audio: $e');
      rethrow;
    }
  }

  /// Procesa archivos (Excel, PDF, Word) - PENDIENTE
  Future<List<TaskModel>> _processFile(Uint8List fileBytes, int userId) async {
    debugPrint('AiService._processFile: Pendiente implementación');
    throw UnimplementedError('Procesamiento de archivos pendiente para Fase 2');
  }

  String _buildProjectsContext(List<DetailedProjectDto> projects) {
    final buffer = StringBuffer('PROYECTOS DISPONIBLES:');
    final limited = projects.take(30).toList();
    for (var i = 0; i < limited.length; i++) {
      final p = limited[i];
      buffer.writeln('\n${i + 1}. ID:${p.id} | "${p.title}"');
    }
    return buffer.toString();
  }

  TaskModel _mapJsonToTaskModel(
    Map<String, dynamic> taskJson,
    int projectId,
    ContentType type,
  ) {
    String? dueDateString;
    if (taskJson['due_date'] != null) {
      dueDateString = taskJson['due_date'] as String;
    }

    final mappedSource = switch (type) {
      ContentType.image => 'image',
      ContentType.audio => 'voice',
      ContentType.file => 'file',
    };

    return TaskModel(
      id: 0,
      title: taskJson['title'] as String? ?? '',
      description: taskJson['description'] as String? ?? '',
      dueDate: (dueDateString != null && dueDateString.isNotEmpty)
          ? _parseAiDateAsLocal(dueDateString)
          : null,
      isCompleted: false,
      projectId: projectId,
      priority: taskJson['priority'] as int? ?? 2,
      sourceType: mappedSource,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Parsea fecha de respuesta IA como hora local
  /// Gemini retorna fechas con "Z" (UTC) pero el usuario da horas locales,
  /// asi que eliminamos el sufijo UTC y parseamos como local
  DateTime _parseAiDateAsLocal(String dateStr) {
    // Eliminar sufijo Z o offset para interpretar como hora local
    String cleanDate = dateStr.replaceAll(RegExp(r'Z$'), '');
    cleanDate = cleanDate.replaceAll(RegExp(r'[+-]\d{2}:\d{2}$'), '');
    return DateTime.parse(cleanDate);
  }

  /// Extrae JSON de markdown fences si existe
  String _extractJson(String text) {
    final jsonPattern = RegExp(r'```json\s*([\s\S]*?)\s*```');
    final match = jsonPattern.firstMatch(text);
    return match != null ? match.group(1)! : text.trim();
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
