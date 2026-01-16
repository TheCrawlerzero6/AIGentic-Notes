import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
          return Column();
        },
      ),
    );
  }
}
