import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/cubit/task_cubit.dart';
import '../../presentation/cubit/task_state.dart';
import '../widgets/add_task_bottom_sheet.dart';

class TasksScreen extends StatefulWidget {
  final int projectId;
  const TasksScreen({super.key, required this.projectId});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  void _openAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskCubit, TaskState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(
              state is TaskSuccess ? state.selectedProject.title : 'Proyecto',
            ),
          ),
          floatingActionButton: FloatingActionButton(
            backgroundColor: const Color(0xFF6750A4),
            onPressed: _openAddBottomSheet,
            child: const Icon(Icons.add, color: Colors.white),
          ),

          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 4.0,
            ),
            child: _buildBody(state),
          ),
        );
      },
    );
  }

  Widget _buildBody(TaskState state) {
    if (state is TaskLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is TaskSuccess && state.tasks.isNotEmpty) {
      return ListView.separated(
        separatorBuilder: (BuildContext context, int index) {
          return Divider(height: 1, thickness: 0.8);
        },
        itemCount: state.tasks.length,

        itemBuilder: (context, index) {
          final item = state.tasks[index];

          return ListTile(
            title: Text(item.title),
            subtitle: SizedBox(height: 0),
            onTap: () {
              context.push("/tasks/${item.id}");
            },
          );
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

class TaskPlaceholderLine extends StatelessWidget {
  const TaskPlaceholderLine({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: BoxBorder.fromLTRB(
            bottom: BorderSide(color: Colors.grey.withAlpha(100)),
          ),
        ),
      ),
    );
  }
}
