import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/home_state.dart';
import 'package:mi_agenda/features/tasks/presentation/widgets/add_project_bottom_sheet.dart';
import 'package:mi_agenda/features/tasks/presentation/widgets/user_app_bar.dart';

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

                      return ListTile(
                        title: Text(item.labelText),
                        subtitle: SizedBox(height: 0),
                        onTap: () {
                          debugPrint("TAPPED");
                        },
                      );
                    },
                  ),
                  Divider(),
                  SizedBox(height: 8),
                  if (state is HomeLoading)
                    Center(child: CircularProgressIndicator())
                  else if (state is HomeSuccess && state.projects.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: state.projects.length,
                        itemBuilder: (context, index) {
                          final item = state.projects[index];

                          return ListTile(
                            title: Text(item.title),
                            subtitle: SizedBox(height: 0),
                            onTap: () {
                              context.push("/projects/${item.id}");
                            },
                          );
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
