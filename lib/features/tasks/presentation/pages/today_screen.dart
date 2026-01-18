import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/system_cubit.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/system_state.dart';
import '../../domain/entities/task.dart';
import '../widgets/task_item_tile.dart';
import '../widgets/task_placeholder_line.dart';

class TodayScreen extends StatefulWidget {
  const TodayScreen({super.key});

  @override
  State<TodayScreen> createState() => _TodayScreenState();
}

class _TodayScreenState extends State<TodayScreen> with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<SystemCubit>().listTasks();
  }

  @override
  void didPopNext() {
    context.read<SystemCubit>().listTasks();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemCubit, SystemState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('Para Hoy')),

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
    final now = DateTime.now();

    bool todayTasks(Task task) {
      final d = task.dueDate;
      if (d == null) return false;
      return d.year == now.year && d.month == now.month && d.day == now.day;
    }

    if (state is SystemLoading) {
      return Center(child: CircularProgressIndicator());
    } else if (state is SystemSuccess &&
        state.tasks.where(todayTasks).isNotEmpty) {
      final todayTasksList = state.tasks.where(todayTasks).toList();
      return ListView.builder(
        itemCount: todayTasksList.length < 10 ? 10 : todayTasksList.length,

        itemBuilder: (context, index) {
          if (index < todayTasksList.length) {
            final item = todayTasksList[index];
            void toggleItem() async {
              await context.read<SystemCubit>().toggleTask(item.id!);
            }

            return TaskItemTile(task: item, onToggle: toggleItem);
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
