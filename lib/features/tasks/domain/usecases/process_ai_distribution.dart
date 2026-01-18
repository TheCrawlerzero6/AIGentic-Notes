import 'dart:typed_data';

import '../dtos/distribution_execution_result.dart';
import '../dtos/project_dtos.dart';
import '../dtos/task_dtos.dart';
import '../entities/project.dart';
import '../helpers/task_datetime_calculator.dart';
import '../repositories/i_ai_service.dart';
import '../repositories/project_repository.dart';
import '../repositories/task_repository.dart';
import '../validators/task_validator.dart';

class ProcessAiDistributionUseCase {
  final IAiService aiService;
  final ITaskRepository taskRepository;
  final IProjectRepository projectRepository;

  ProcessAiDistributionUseCase({
    required this.aiService,
    required this.taskRepository,
    required this.projectRepository,
  });

  Future<DistributionExecutionResult> call({
    required Uint8List bytes,
    required ContentType contentType,
    required int userId,
    required List<Project> existingProjects,
  }) async {
    if (bytes.isEmpty) {
      throw ArgumentError('Los bytes no pueden estar vacíos');
    }

    if (contentType == ContentType.file) {
      throw UnimplementedError('Distribución para archivos no implementada');
    }

    final distribution = await aiService.processMultimodalContentWithDistribution(
      data: bytes,
      type: contentType,
      existingProjects: existingProjects,
      userId: userId,
    );

    final now = DateTime.now();
    final projectMap = {for (final project in existingProjects) project.id: project};

    var tasksCreated = 0;
    var projectsCreated = 0;

    // Tareas para proyectos existentes
    for (final dist in distribution.existingProjectDistributions) {
      if (!projectMap.containsKey(dist.projectId)) {
        continue;
      }

      final tasksToCreate = <CreateTaskDto>[];

      for (final task in dist.tasks) {
        final finalDueDate = TaskDateTimeCalculator.calculateFinalDueDate(
          dueDate: task.dueDate,
          currentTime: now,
        );

        TaskValidator.validateTask(
          title: task.title,
          priority: task.priority,
          dueDate: finalDueDate,
        );

        tasksToCreate.add(
          CreateTaskDto(
            title: task.title.trim(),
            description: task.description?.trim(),
            dueDate: finalDueDate,
            isCompleted: false,
            sourceType: _mapContentTypeToSourceType(contentType),
            priority: task.priority,
            projectId: dist.projectId,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      if (tasksToCreate.isNotEmpty) {
        tasksCreated += await taskRepository.createTasksBatch(tasksToCreate);
      }
    }

    // Proyectos nuevos sugeridos
    for (final newProject in distribution.newProjectDistributions) {
      final projectId = await projectRepository.createProject(
        CreateProjectDto(
          title: newProject.title.isNotEmpty
              ? newProject.title.trim()
              : 'Nuevo proyecto',
          description: newProject.suggestedDescription?.trim(),
          icon: (newProject.suggestedIcon?.trim().isNotEmpty ?? false)
              ? newProject.suggestedIcon!.trim()
              : 'add',
          themeColor: '0xFAFAFA',
          userId: userId,
          createdAt: now,
          updatedAt: now,
        ),
      );

      projectsCreated++;

      final tasksToCreate = <CreateTaskDto>[];

      for (final task in newProject.tasks) {
        final finalDueDate = TaskDateTimeCalculator.calculateFinalDueDate(
          dueDate: task.dueDate,
          currentTime: now,
        );

        TaskValidator.validateTask(
          title: task.title,
          priority: task.priority,
          dueDate: finalDueDate,
        );

        tasksToCreate.add(
          CreateTaskDto(
            title: task.title.trim(),
            description: task.description?.trim(),
            dueDate: finalDueDate,
            isCompleted: false,
            sourceType: _mapContentTypeToSourceType(contentType),
            priority: task.priority,
            projectId: projectId,
            createdAt: now,
            updatedAt: now,
          ),
        );
      }

      if (tasksToCreate.isNotEmpty) {
        tasksCreated += await taskRepository.createTasksBatch(tasksToCreate);
      }
    }

    return DistributionExecutionResult(
      tasksCreated: tasksCreated,
      projectsCreated: projectsCreated,
      distribution: distribution,
    );
  }

  String _mapContentTypeToSourceType(ContentType type) {
    switch (type) {
      case ContentType.image:
        return 'image';
      case ContentType.audio:
        return 'voice';
      case ContentType.file:
        return 'file';
    }
  }
}
