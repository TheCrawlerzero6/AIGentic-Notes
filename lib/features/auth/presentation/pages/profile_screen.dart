import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_agenda/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:provider/provider.dart';

import '../../../../core/data/services/notification_service.dart';

/// Pantalla de perfil de usuario
///
/// Muestra información del usuario logueado y opciones:
/// - Nombre de usuario
/// - Email (cuando se implemente)
/// - Estadísticas básicas (cuando se implemente)
/// - Cerrar sesión con confirmación
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  /// Muestra diálogo de confirmación de logout
  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      await context.read<AuthCubit>().signOut();
      if (context.mounted) {
        context.go("/login");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.read<AuthCubit>().currentUser;

    final completedCount = context.read<AuthCubit>().completedTasks;
    final pendingCount = context.read<AuthCubit>().pendingTasks;
    
    int streak = 0;
    final now = DateTime.now();
    final completedTasks = [];
    if (completedTasks.isNotEmpty) {
      completedTasks.sort(
        (a, b) => DateTime.parse(
          b.completedAt!,
        ).compareTo(DateTime.parse(a.completedAt!)),
      );
      DateTime checkDate = DateTime(now.year, now.month, now.day);

      for (var task in completedTasks) {
        final completedDate = DateTime.parse(task.completedAt!);
        final taskDay = DateTime(
          completedDate.year,
          completedDate.month,
          completedDate.day,
        );

        if (taskDay.isAtSameMomentAs(checkDate) ||
            taskDay.isBefore(checkDate)) {
          if (checkDate.difference(taskDay).inDays <= 1) {
            streak++;
            checkDate = taskDay.subtract(const Duration(days: 1));
          } else {
            break;
          }
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mi Perfil',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: const Color(0xFF6750A4),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    currentUser?.username?.substring(0, 1).toUpperCase() ?? 'U',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Username
              Text(
                currentUser?.username ?? 'Usuario',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 4),

              // Fecha de creación
              if (currentUser?.createdAt != null)
                Text(
                  'Miembro desde ${currentUser!.createdAt.day}/${currentUser.createdAt.month}/${currentUser.createdAt.year}',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),

              const SizedBox(height: 40),

              // Sección estadísticas (datos reales)
              _StatCard(
                icon: Icons.check_circle,
                title: 'Tareas Completadas',
                value: completedCount.toString(),
                color: Colors.green,
              ),

              const SizedBox(height: 12),

              _StatCard(
                icon: Icons.pending_actions,
                title: 'Tareas Pendientes',
                value: pendingCount.toString(),
                color: Colors.orange,
              ),

              const SizedBox(height: 12),

              _StatCard(
                icon: Icons.local_fire_department,
                title: 'Racha de Días',
                value: streak.toString(),
                color: Colors.red,
              ),

              const SizedBox(height: 40),

              // Botón test notificaciones
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF6750A4),
                    side: const BorderSide(color: Color(0xFF6750A4)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    try {
                      await NotificationService().showTestNotification();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Notificación de prueba enviada'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.notifications_active),
                  label: const Text(
                    'Test Notificación',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // Botón cerrar sesión
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade500.withAlpha(60),
                    foregroundColor: Colors.red.shade700,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => _confirmLogout(context),
                  icon: const Icon(Icons.logout),
                  label: const Text(
                    'Cerrar Sesión',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Versión de la app
              const Text(
                'AIGentic-Notes v1.0.0',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget de tarjeta de estadística
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
