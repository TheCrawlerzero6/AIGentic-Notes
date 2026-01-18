import 'dart:typed_data';

import '../repositories/i_ai_service.dart';
import '../../../../core/domain/dtos/task_dtos.dart';
import '../../../../core/domain/repositories/task_repository.dart';
import '../../../../core/data/validators/task_validator.dart';
import '../../../../core/data/helpers/task_datetime_calculator.dart';

class ProcessAiImageUseCase {
  final IAiService aiService;
  final ITaskRepository taskRepository;

  ProcessAiImageUseCase({
    required this.aiService,
    required this.taskRepository,
  });

  Future<int> call({
    required Uint8List imageBytes,
    required int projectId,
  }) async {
    // Validación 1: Verificar que los bytes de imagen no estén vacíos
    if (imageBytes.isEmpty) {
      throw ArgumentError('Los bytes de imagen no pueden estar vacíos');
    }

    // Validación 2: Verificar que projectId sea válido
    if (projectId <= 0) {
      throw ArgumentError('El projectId debe ser un entero positivo');
    }

    // Validación 3: Procesar con IA y capturar errores específicos
    List<dynamic> taskModels;
    try {
      taskModels = await aiService.processMultimodalContent(
        data: imageBytes,
        type: ContentType.image,
        userId: projectId,
      );
    } catch (e) {
      if (e.toString().contains('timeout')) {
        throw Exception('Tiempo de espera agotado al procesar la imagen con IA. Intenta nuevamente.');
      } else if (e.toString().contains('quota')) {
        throw Exception('Límite de solicitudes de IA alcanzado. Espera unos minutos.');
      } else if (e.toString().contains('network')) {
        throw Exception('Error de conexión. Verifica tu conexión a internet.');
      } else {
        throw Exception('Error al procesar imagen con IA: ${e.toString()}');
      }
    }

    // Validación 4: Verificar que se retornó al menos una tarea
    if (taskModels.isEmpty) {
      throw Exception('La IA no pudo extraer tareas de la imagen. Intenta con una imagen más clara.');
    }

    final now = DateTime.now();
    final tasksToCreate = <CreateTaskDto>[];

    // Validación 5: Validar cada tarea usando TaskValidator
    for (var taskModel in taskModels) {
      // Calcular fecha de vencimiento final usando TaskDateTimeCalculator
      final finalDueDate = TaskDateTimeCalculator.calculateFinalDueDate(
        dueDate: taskModel.dueDate,
        currentTime: now,
      );

      // Validar todos los campos de la tarea
      TaskValidator.validateTask(
        title: taskModel.title,
        priority: taskModel.priority,
        dueDate: finalDueDate,
      );

      tasksToCreate.add(
        CreateTaskDto(
          title: taskModel.title.trim(),
          description: taskModel.description?.trim(),
          dueDate: finalDueDate,
          isCompleted: false,
          sourceType: 'image',
          priority: taskModel.priority,
          projectId: projectId,
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // Validación 6: Crear todas las tareas en una transacción atómica
    try {
      final insertedCount = await taskRepository.createTasksBatch(tasksToCreate);
      
      // Validación 7: Verificar que se insertaron todas las tareas
      if (insertedCount != tasksToCreate.length) {
        throw Exception('Error al crear algunas tareas. Se esperaban ${tasksToCreate.length}, se crearon $insertedCount.');
      }

      return insertedCount;
    } catch (e) {
      throw Exception('Error al guardar las tareas en la base de datos: ${e.toString()}');
    }
  }
}
