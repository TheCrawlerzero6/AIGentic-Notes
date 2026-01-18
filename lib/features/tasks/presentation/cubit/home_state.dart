import 'package:flutter/material.dart';

import '../../domain/dtos/project_dtos.dart';
import '../../domain/entities/system_project.dart';


abstract class HomeState {
  final List<SystemProject> menuItems = [
    const SystemProject(
      labelText: 'Para Hoy',
      icon: Icons.access_time_filled,
      progress: 0.7,
      route: '/projects/today',
      isTracked: true,
    ),
    const SystemProject(
      labelText: 'Agenda',
      route: '/projects/agenda',
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
  final List<DetailedProjectDto> projects;
  HomeSuccess({required this.projects});
}

class HomeError extends HomeState {
  final String message;
  HomeError({required this.message});
}
