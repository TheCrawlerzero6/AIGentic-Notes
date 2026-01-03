import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../data/models/task_model.dart';
import '../../widgets/add_task_bottom_sheet.dart';
import '../../widgets/priority_indicator.dart';
import '../profile/profile_screen.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar tareas del usuario logueado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      final taskProvider = context.read<TaskProvider>();
      if (authProvider.currentUser != null) {
        taskProvider.loadTasks(authProvider.currentUser!.id!);
      }
    });
  }

  void _openAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return AddTaskBottomSheet(
          onAdd: (title, description, dueDate, priority) async {
            final authProvider = context.read<AuthProvider>();
            final taskProvider = context.read<TaskProvider>();
            
            if (authProvider.currentUser != null) {
              final newTask = TaskModel(
                userId: authProvider.currentUser!.id!,
                title: title,
                description: description,
                dueDate: dueDate.toIso8601String(),
                priority: priority,
                sourceType: 'manual',
              );
              
              await taskProvider.createTask(newTask);
              
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tarea creada exitosamente'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6750A4),
        onPressed: _openAddBottomSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        automaticallyImplyLeading: false, // Quitar botón atrás
        title: const Text(
          'Mis Tareas del Día',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        actions: [
          // Botón perfil para cerrar sesión
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, size: 28),
            tooltip: 'Perfil',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()),
              );
            },
          ),
        ],
      ),

      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 90),
          children: [
            const Text(
              'Próximas Tareas',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 16),

            // Lista dinámica con Consumer de TaskProvider
            Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.isLoading) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.all(40),
                      child: CircularProgressIndicator(),
                    ),
                  );
                }

                if (taskProvider.tasks.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Icon(Icons.inbox_outlined, size: 80, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'No hay tareas aún',
                          style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Presiona + para crear tu primera tarea',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  );
                }

                return Column(
                  children: taskProvider.tasks.map((task) {
                    final dueDate = DateTime.parse(task.dueDate);
                    final now = DateTime.now();
                    final difference = dueDate.difference(now);
                    
                    String timeLabel;
                    if (difference.inMinutes < 0) {
                      final absDiff = difference.abs();
                      if (absDiff.inDays > 0) {
                        timeLabel = 'Vencida hace ${absDiff.inDays}d';
                      } else if (absDiff.inHours > 0) {
                        timeLabel = 'Vencida hace ${absDiff.inHours}h';
                      } else {
                        timeLabel = 'Vencida hace ${absDiff.inMinutes}m';
                      }
                    } else if (difference.inMinutes < 60) {
                      timeLabel = 'Vence en ${difference.inMinutes}m';
                    } else if (difference.inHours < 24) {
                      timeLabel = 'Vence en ${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
                    } else {
                      timeLabel = 'Vence en ${difference.inDays}d ${difference.inHours.remainder(24)}h';
                    }

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Dismissible(
                        key: Key('task_${task.id}'),
                        direction: DismissDirection.endToStart,
                        confirmDismiss: (direction) async {
                          return await showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Eliminar Tarea'),
                              content: Text('¿Deseas eliminar "${task.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx, true),
                                  style: TextButton.styleFrom(foregroundColor: Colors.red),
                                  child: const Text('Eliminar'),
                                ),
                              ],
                            ),
                          );
                        },
                        onDismissed: (direction) {
                          taskProvider.deleteTask(task.id!);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${task.title} eliminada'),
                              backgroundColor: Colors.red.shade400,
                            ),
                          );
                        },
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            color: Colors.red.shade400,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.delete, color: Colors.white, size: 32),
                        ),
                        child: _TaskItem(
                          task: task,
                          title: task.title,
                          subtitle: task.description,
                          time: timeLabel,
                          priority: task.priority,
                          isCompleted: task.isCompleted == 1,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TaskDetailScreen(task: task),
                              ),
                            );
                          },
                          onToggleComplete: () {
                            taskProvider.toggleComplete(task.id!);
                          },
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskItem extends StatelessWidget {
  final TaskModel task;
  final String title;
  final String subtitle;
  final String time;
  final int priority;
  final bool isCompleted;
  final VoidCallback onTap;
  final VoidCallback onToggleComplete;

  const _TaskItem({
    required this.task,
    required this.title,
    required this.subtitle,
    required this.time,
    required this.priority,
    required this.isCompleted,
    required this.onTap,
    required this.onToggleComplete,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isCompleted ? Colors.grey.shade100 : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // Checkbox para completar
            Checkbox(
              value: isCompleted,
              onChanged: (_) => onToggleComplete(),
              shape: const CircleBorder(),
              activeColor: const Color(0xFF6750A4),
            ),
            const SizedBox(width: 8),
            PriorityIndicator(
              priority: priority,
              size: 70,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      decoration: isCompleted ? TextDecoration.lineThrough : null,
                      color: isCompleted ? Colors.grey : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isCompleted ? Colors.grey.shade500 : Colors.black87,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 6),
                      Text(time, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}
