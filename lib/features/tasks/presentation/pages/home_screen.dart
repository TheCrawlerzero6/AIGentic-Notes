import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_agenda/features/tasks/domain/entities/system_project.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/home_state.dart';
import 'package:mi_agenda/features/tasks/presentation/widgets/add_project_bottom_sheet.dart';
import 'package:mi_agenda/features/tasks/presentation/widgets/user_app_bar.dart';

import '../../domain/entities/project.dart';
import '../cubit/home_cubit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _openAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return AddProjectBottomSheet(
          onAdd: (title, description, dueDate, priority) async {
            try {
              await context.read<HomeCubit>().createTask(
                title,
                description,
                dueDate,
                priority,
              );

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
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF6750A4),
        onPressed: _openAddBottomSheet,
        child: const Icon(Icons.add, color: Colors.white),
      ),

      appBar: UserAppBar(context),

      body: BlocBuilder<HomeCubit, HomeState>(
        builder: (context, state) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  ListView.builder(
                    shrinkWrap: true,
                    itemCount: state.menuItems.length,
                    itemBuilder: (context, index) {
                      final item = state.menuItems[index];
                      if (index == 0) {
                        return getSystemTile(
                          context: context,
                          listItem: item,
                          icon: Icons.timer,
                          color: Color.fromARGB(255, 98, 85, 245),
                        );
                      } else if (index == 1) {
                        return getSystemTile(
                          context: context,
                          listItem: item,
                          icon: Icons.calendar_month,
                          color: Color.fromARGB(255, 171, 120, 218),
                        );
                      } else {
                        return getSystemTile(context: context, listItem: item);
                      }
                    },
                  ),
                  Divider(),
                  if (state is HomeLoading)
                    Center(child: CircularProgressIndicator())
                  else if (state is HomeSuccess && state.projects.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.projects.length,
                        itemBuilder: (context, index) {
                          final item = state.projects[index];

                          return getMenuTile(context: context, listItem: item);
                        },
                      ),
                    )
                  else if (state is HomeError)
                    Center(child: Text(state.message))
                  else
                    Center(child: Text("No se han creado proyectos aún")),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

Widget getSystemTile({
  required BuildContext context,
  required SystemProject listItem,
  IconData icon = Icons.list,
  Color color = const Color(0xFF6255F5),
}) {
  return ListTile(
    minTileHeight: 56,
    leading: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withAlpha(60),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(icon, size: 20, color: color),
    ),
    title: Text(listItem.labelText),
    subtitle: null,
    onTap: () {
      debugPrint("tapped system project");
      // context.push("/projects/${listItem.labelText}");
    },
  );
}

Widget getMenuTile({
  required BuildContext context,
  required Project listItem,
  IconData icon = Icons.list,
  Color color = const Color(0xFF6255F5),
}) {
  final progress = 0.5;
  return ListTile(
    minTileHeight: 56,
    leading: Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: color.withAlpha(60),
        borderRadius: BorderRadius.circular(4),
      ),

      child: Icon(icon, size: 20, color: color),
    ),
    trailing: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "${(progress * 100).toStringAsFixed(0)}%",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(value: progress, color: color)),
      ],
    ),
    title: Text(listItem.title),
    subtitle: null,
    onTap: () {
      context.push("/projects/${listItem.id}");
    },
  );
}
