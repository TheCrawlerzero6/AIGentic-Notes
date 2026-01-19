import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_agenda/features/tasks/presentation/widgets/task_item_tile.dart';
import '../../presentation/cubit/task_cubit.dart';
import '../../presentation/cubit/task_state.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/task_placeholder_line.dart';

enum _ProjectMenuOption { delete }

class TasksScreen extends StatefulWidget {
  final int projectId;
  const TasksScreen({super.key, required this.projectId});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<TaskCubit>().listTasks();
  }

  @override
  void didPopNext() {
    context.read<TaskCubit>().listTasks();
  }

  void _openAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return AddTaskBottomSheet(
          onAdd: (title, dueDate) async {
            try {
              await context.read<TaskCubit>().createTask(title, dueDate);

              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Tarea creada exitosamente',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Error creando tarea: ${e.toString()}",
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            }
            // }
          },
        );
      },
    );
  }

  void _confirmDeleteProject(BuildContext parentContext) {
    showDialog(
      context: parentContext,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar proyecto'),
        content: const Text(
          '¿Estás seguro de que deseas eliminar este proyecto?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              await parentContext.read<TaskCubit>().deleteProject(() {
                Navigator.pop(context);
                parentContext.pushReplacement('/home');
              });
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;

            context.pushReplacement("/home");
          },
          child: Scaffold(
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  context.pushReplacement("/home");
                },
              ),

              title: Text(
                state is TaskSuccess ? state.selectedProject.title : 'Proyecto',
              ),
              actions: [
                PopupMenuButton<_ProjectMenuOption>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    switch (value) {
                      case _ProjectMenuOption.delete:
                        _confirmDeleteProject(context);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: _ProjectMenuOption.delete,
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red, size: 20),
                          SizedBox(width: 8),
                          Text('Eliminar proyecto'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              backgroundColor: const Color(0xFF6750A4),
              onPressed: _openAddBottomSheet,
              child: const Icon(Icons.add, color: Colors.white),
            ),

            body: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12.0,
                vertical: 4.0,
              ),
              child: _buildBody(state),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(TaskState state) {
    if (state is TaskLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is TaskSuccess && state.tasks.isNotEmpty) {
      return ListView.builder(
        itemCount: state.tasks.length < 10 ? 10 : state.tasks.length,

        itemBuilder: (context, index) {
          if (index < state.tasks.length) {
            final item = state.tasks[index];
            void toggleItem() async {
              await context.read<TaskCubit>().toggleTask(item.id!);
            }

            return TaskItemTile(task: item, onToggle: toggleItem);
          } else {
            return const TaskPlaceholderLine();
          }
        },
      );
    } else if (state is TaskError) {
      return Center(child: Text(state.message));
    } else {
      return ListView.builder(
        itemCount: 10,

        itemBuilder: (context, index) {
          return const TaskPlaceholderLine();
        },
      );
    }
  }
}
