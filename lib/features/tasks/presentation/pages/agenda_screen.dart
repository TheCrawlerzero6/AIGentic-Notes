import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/system_cubit.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/system_state.dart';
import 'package:mi_agenda/features/tasks/presentation/widgets/task_item_tile.dart';
import '../widgets/add_task_bottom_sheet.dart';
import '../widgets/task_placeholder_line.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<SystemCubit>().listTasks();
  }

  @override
  void didPopNext() {
    context.read<SystemCubit>().listTasks();
  }

  void _openAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (modalContext) {
        return AddTaskBottomSheet(
          onAdd: (title, dueDate) async {
            try {
              await context.read<SystemCubit>().createTask(title, dueDate);

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
    return BlocBuilder<SystemCubit, SystemState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('Agenda')),
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
        );
      },
    );
  }

  Widget _buildBody(SystemState state) {
    if (state is SystemLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is SystemSuccess && state.tasks.isNotEmpty) {
      return ListView.builder(
        itemCount: state.tasks.length < 10 ? 10 : state.tasks.length,

        itemBuilder: (context, index) {
          if (index < state.tasks.length) {
            final item = state.tasks[index];
            return TaskItemTile(task: item);
          } else {
            return const TaskPlaceholderLine();
          }
        },
      );
    } else if (state is SystemError) {
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
