import 'dart:typed_data';
import 'package:mi_agenda/core/domain/dtos/project_dtos.dart';

import '../../../../core/domain/entities/task.dart';
import '../../../../core/domain/entities/distribution_result.dart';

/// Tipos de contenido soportados por el servicio de IA
enum ContentType {
  image, // Imágenes (JPG, PNG)
  audio, // Audio (AAC, WAV, MP3, OGG, FLAC)
  file, // Archivos (Excel, PDF, Word)
}

/// Interfaz abstracta para servicios de IA
///
/// Define el contrato que debe cumplir cualquier implementación
/// de servicio de IA. Esto permite invertir la dependencia:
/// el domain depende de esta abstracción, no de la implementación concreta.
///
/// **Principio de Inversión de Dependencias (SOLID)**
/// - Domain (use cases) depende de IAiService (abstracción)
/// - Data (AiService) implementa IAiService
/// - Flujo: domain ← interfaz ← data (correcto en Clean Architecture)
abstract class IAiService {
  /// Procesa contenido multimodal y extrae tareas
  ///
  /// Parámetros:
  /// - [data]: Bytes del contenido (imagen, audio, archivo)
  /// - [type]: Tipo de contenido a procesar
  /// - [userId]: ID del usuario para contexto
  ///
  /// Retorna: Lista de tareas extraídas del contenido
  ///
  /// Lanza [Exception] si:
  /// - El servicio no está inicializado
  /// - Hay error en la comunicación con la IA
  /// - El contenido no es válido
  /// - Se excede el límite de solicitudes
  Future<List<Task>> processMultimodalContent({
    required Uint8List data,
    required ContentType type,
    required int userId,
  });

  Future<DistributionResult> processMultimodalContentWithDistribution({
    required Uint8List data,
    required ContentType type,
    required List<DetailedProjectDto> existingProjects,
    required int userId,
  });

  Future<void> initialize();

  /// Verifica si el servicio está inicializado y listo para usar
  bool get isInitialized;

  /// Obtiene el número total de solicitudes hechas en la sesión actual
  ///
  /// Útil para monitorear el uso y evitar exceder límites de API
  int get totalRequests;
}
