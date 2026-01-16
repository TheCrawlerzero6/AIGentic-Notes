import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/cubit/task_cubit.dart';
import '../../presentation/cubit/task_state.dart';

class TasksScreen extends StatelessWidget {
  final int projectId;
  const TasksScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Proyecto $projectId")),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state is TaskLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is TaskSuccess && state.tasks.isNotEmpty) {
            return ListView.builder(
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
            return Center(child: Text("No se han creado tareas aún"));
          }
        },
      ),
    );
  }
}
