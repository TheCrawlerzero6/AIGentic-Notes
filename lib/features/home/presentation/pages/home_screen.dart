import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../widgets/add_project_bottom_sheet.dart';
import '../widgets/user_app_bar.dart';

import 'package:mi_agenda/core/domain/entities/system_project.dart';
import '../../../../core/domain/dtos/project_dtos.dart';
import '../../domain/repositories/i_ai_service.dart';
import '../cubit/home_cubit.dart';
import '../widgets/ai_options_widget.dart';
import '../widgets/audio_recorder_widget.dart';
import '../widgets/file_picker_widget.dart';
import '../cubit/home_state.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  void _showAudioRecorder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      isDismissible: false, // No cerrar accidentalmente durante grabación
      enableDrag: false,
      builder: (context) => AudioRecorderWidget(
        onAudioRecorded: (bytes) =>
            context.read<HomeCubit>().processWithAI(bytes, ContentType.audio),
      ),
    );
  }

  void _openAddBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return AddProjectBottomSheet(
          onAdd: (title) async {
            try {
              await context.read<HomeCubit>().createProject(title);

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

  void _showFilePlaceholder() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => const FilePickerWidget(),
    );
  }

  void _showAIOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => AIOptionsWidget(
        onImageSelected: (bytes) =>
            context.read<HomeCubit>().processWithAI(bytes, ContentType.image),
        onAudioSelected: _showAudioRecorder,
        onFileSelected: _showFilePlaceholder,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: UserAppBar(context, user: context.read<HomeCubit>().currentUser!),

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

                  ListTile(
                    minTileHeight: 56,
                    leading: SizedBox(
                      width: 26,
                      height: 26,
                      child: Icon(
                        Icons.add,
                        size: 26,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    title: Text(
                      "Nuevo Proyecto",
                      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    subtitle: null,
                    trailing: IconButton(
                      onPressed: _showAIOptions,

                      icon: Icon(
                        Icons.cloud_download_outlined,
                        size: 32,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    onTap: _openAddBottomSheet,
                  ),
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
      context.push(listItem.route);
    },
  );
}

Widget getMenuTile({
  required BuildContext context,
  required DetailedProjectDto listItem,
  IconData icon = Icons.list,
  Color color = const Color(0xFF6255F5),
}) {
  final progress = listItem.tasks.isNotEmpty
      ? listItem.tasks.where((task) => task.isCompleted).length /
            listItem.tasks.length
      : 0.0;
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
      spacing: 4,
      children: [
        Text(
          "${(progress * 100).toStringAsFixed(0)}%",
          style: Theme.of(context).textTheme.bodySmall,
        ),
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(value: progress, color: color),
        ),
      ],
    ),
    title: Text(listItem.title),
    subtitle: null,
    onTap: () {
      context.push("/projects/${listItem.id}");
    },
  );
}
