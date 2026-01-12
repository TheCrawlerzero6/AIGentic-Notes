import 'package:flutter/material.dart';
import 'package:mi_agenda/ui/widgets/user_app_bar.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/task_provider.dart';
import '../../../data/models/task_model.dart';
import '../../widgets/add_task_bottom_sheet.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final sampleTask = TaskModel(
    userId: 1,
    title: "Investigar mucho",
    description: "ASndjan jansdjasndjsa",
    dueDate: "2026-01-15T18:00:00Z",
    sourceType: "manual",
    priority: 2,
  );
  final List<MenuItem> items = [
    const MenuItem(
      labelText: 'Para Hoy',
      icon: Icons.access_time_filled,
      progress: 0.7,
      isTracked: true,
    ),
    const MenuItem(
      labelText: 'Agenda',
      icon: Icons.calendar_month,
      progress: 0.4,
      isTracked: false,
    ),
  ];

  final List<MenuItem> userTasks = [
    const MenuItem(
      labelText: 'Sprints Trabajo',
      icon: Icons.list,
      progress: 0.7,
      isTracked: true,
    ),
    const MenuItem(
      labelText: 'Tareas Espol',
      icon: Icons.list,
      progress: 0.4,
      isTracked: true,
    ),
  ];
  @override
  void initState() {
    super.initState();

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

      appBar: UserAppBar(context),

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];

                  return ListTile(
                    title: item.buildTitle(context),
                    subtitle: item.buildSubtitle(context),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TaskDetailScreen(task: sampleTask),
                        ),
                      );
                    },
                  );
                },
              ),
              Divider(),
              SizedBox(height: 8),
              Expanded(
                child: ListView.builder(
                  itemCount: userTasks.length,
                  itemBuilder: (context, index) {
                    final item = userTasks[index];

                    return ListTile(
                      title: item.buildTitle(context),
                      subtitle: item.buildSubtitle(context),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => TaskDetailScreen(task: sampleTask),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String labelText;
  final IconData icon;
  final double progress;
  final bool isTracked;

  const MenuItem({
    required this.labelText,
    required this.icon,
    required this.progress,
    required this.isTracked,
  });
  Widget buildTitle(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(4), // 👈 padding interno
          decoration: BoxDecoration(
            color: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.2), // 👈 20% opacidad
            borderRadius: BorderRadius.circular(6), // 👈 bordes redondeados
          ),
          child: Center(
            child: Icon(
              icon,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            labelText,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
        ),
        if (isTracked)
          Row(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "${(progress * 100).toStringAsFixed(0)}%",
                style: Theme.of(context).textTheme.bodySmall,
              ),
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  value: progress,

                  backgroundColor: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.1),
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget buildSubtitle(BuildContext context) {
    return SizedBox(height: 0);
  }
}
