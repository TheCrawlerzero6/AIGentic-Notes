import 'package:flutter/material.dart';

class SystemProject {
  final String labelText;
  final IconData icon;
  final double progress;
  final bool isTracked;

  const SystemProject({
    required this.labelText,
    required this.icon,
    required this.progress,
    required this.isTracked,
  });
}
