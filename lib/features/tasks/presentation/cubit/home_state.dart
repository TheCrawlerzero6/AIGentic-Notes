import 'package:flutter/material.dart';

import '../../domain/entities/system_project.dart';

import '../../domain/entities/project.dart';

abstract class HomeState {
  final List<SystemProject> menuItems = [
    const SystemProject(
      labelText: 'Para Hoy',
      icon: Icons.access_time_filled,
      progress: 0.7,
      isTracked: true,
    ),
    const SystemProject(
      labelText: 'Agenda',
      icon: Icons.calendar_month,
      progress: 0.4,
      isTracked: false,
    ),
  ];
  HomeState();
}

class HomeInitial extends HomeState {
  HomeInitial();
}

class HomeLoading extends HomeState {
  HomeLoading();
}

class HomeSuccess extends HomeState {
  final List<Project> projects;
  HomeSuccess({required this.projects});
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
