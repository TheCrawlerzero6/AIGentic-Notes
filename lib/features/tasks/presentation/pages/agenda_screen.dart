import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/system_cubit.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/system_state.dart';
import 'package:mi_agenda/features/tasks/presentation/widgets/task_item_tile.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SystemCubit, SystemState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text('Agenda')),

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
