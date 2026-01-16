import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
              horizontal: 12.0,
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
      return ListView.builder(
        itemCount: state.tasks.length < 10 ? 10 : 2,

        itemBuilder: (context, index) {
          if (index < state.tasks.length) {
            final item = state.tasks[index];
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Material(
                color: Colors.grey.withAlpha(100),
                borderRadius: BorderRadius.circular(2),
                child: ListTile(
                  leading: Radio<bool>(
                    value: item.isCompleted,
                    toggleable: true,
                  ),
                  minTileHeight: 64,
                  title: Text(item.title),
                  subtitle: item.dueDate != null
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 2,
                          children: [
                            Icon(Icons.calendar_month_rounded, size: 12),
                            Text(
                              DateFormat(
                                "EEE, d 'de' MMM",
                                'es',
                              ).format(item.dueDate!),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                            SizedBox(width: 2,),
                            Icon(Icons.access_time_filled, size: 12),
                            Text(
                              DateFormat('HH:mm').format(item.dueDate!),
                              style: Theme.of(context).textTheme.bodySmall!
                                  .copyWith(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        )
                      : null,
                  trailing: IconButton(
                    onPressed: () => {},
                    icon: Icon(Icons.favorite_outline),
                  ),
                  onTap: () {
                    context.push("/tasks/${item.id}");
                  },
                ),
              ),
            );
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

class TaskPlaceholderLine extends StatelessWidget {
  const TaskPlaceholderLine({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: BoxBorder.fromLTRB(
              bottom: BorderSide(color: Colors.grey.withAlpha(20), width: 1.5),
            ),
          ),
        ),
      ),
    );
  }
}
