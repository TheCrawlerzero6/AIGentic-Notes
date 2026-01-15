import 'package:flutter/material.dart';

class TasksScreen extends StatelessWidget {
  final int projectId;
  const TasksScreen({super.key, required this.projectId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Proyecto $projectId")),
      body: Placeholder(),
    );
  }
}
