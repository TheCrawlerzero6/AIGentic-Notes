import 'package:flutter/material.dart';

/// Widget que muestra un indicador visual de prioridad
/// 
/// Uso:
/// ```dart
/// PriorityIndicator(priority: 3) // Alta = rojo con flecha arriba
/// PriorityIndicator(priority: 2) // Media = amarillo con línea
/// PriorityIndicator(priority: 1) // Baja = verde con flecha abajo
/// ```
class PriorityIndicator extends StatelessWidget {
  /// Nivel de prioridad: 1=Baja, 2=Media, 3=Alta
  final int priority;

  /// Tamaño del ícono
  final double size;

  const PriorityIndicator({
    super.key,
    required this.priority,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final config = _getPriorityConfig();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: config.color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: config.color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Icon(
        config.icon,
        color: config.color,
        size: size * 0.6,
      ),
    );
  }

  /// Obtiene configuración de color e ícono según prioridad
  _PriorityConfig _getPriorityConfig() {
    switch (priority) {
      case 3: // Alta
        return _PriorityConfig(
          color: Colors.red.shade600,
          icon: Icons.arrow_upward,
        );
      case 2: // Media
        return _PriorityConfig(
          color: Colors.orange.shade600,
          icon: Icons.remove,
        );
      case 1: // Baja
      default:
        return _PriorityConfig(
          color: Colors.green.shade600,
          icon: Icons.arrow_downward,
        );
    }
  }
}

/// Configuración de prioridad (color + ícono)
class _PriorityConfig {
  final Color color;
  final IconData icon;

  _PriorityConfig({required this.color, required this.icon});
}

/// Función helper para obtener texto de prioridad
String getPriorityText(int priority) {
  switch (priority) {
    case 3:
      return 'Alta';
    case 2:
      return 'Media';
    case 1:
    default:
      return 'Baja';
  }
}

/// Función helper para obtener color de prioridad
Color getPriorityColor(int priority) {
  switch (priority) {
    case 3:
      return Colors.red.shade600;
    case 2:
      return Colors.orange.shade600;
    case 1:
    default:
      return Colors.green.shade600;
  }
}
