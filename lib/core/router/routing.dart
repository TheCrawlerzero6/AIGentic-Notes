import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mi_agenda/core/domain/repositories/project_repository.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/detail_cubit.dart';
import 'package:mi_agenda/features/tasks/presentation/pages/agenda_screen.dart';
import 'package:mi_agenda/features/tasks/presentation/pages/task_detail_screen.dart';
import 'package:mi_agenda/features/tasks/presentation/pages/today_screen.dart';
import 'package:mi_agenda/features/home/presentation/pages/wip_screen.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/cubit/auth_state.dart';
import '../../features/auth/presentation/pages/login_screen.dart';
import '../../features/auth/presentation/pages/profile_screen.dart';
import '../../features/auth/presentation/pages/register_screen.dart';
import '../../features/home/domain/usecases/process_ai_audio.dart';
import '../../features/home/domain/usecases/process_ai_distribution.dart';
import '../../features/home/domain/usecases/process_ai_image.dart';
import '../../features/home/presentation/cubit/home_cubit.dart';
import '../domain/repositories/task_repository.dart';
import '../../features/tasks/presentation/cubit/system_cubit.dart';
import '../../features/tasks/presentation/cubit/task_cubit.dart';
import '../../features/home/presentation/pages/home_screen.dart';
import '../../features/tasks/presentation/pages/tasks_screen.dart';

class AppRouter {
  static GoRouter router(AuthCubit authCubit) {
    return GoRouter(
      initialLocation: '/login',

      refreshListenable: GoRouterRefreshStream(authCubit.stream),

      redirect: (context, state) {
        final authState = authCubit.state;
        final isLoggingIn = state.uri.toString() == '/login';
        final isRegister = state.uri.toString() == '/register';

        final isAuthenticated = authState is AuthAuthenticated;

        if (!isAuthenticated && state.uri.toString() == '/home') {
          return '/login';
        }

        if (isAuthenticated && (isLoggingIn || isRegister)) {
          return '/home';
        }

        return null;
      },

      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
        GoRoute(
          path: '/projects/today',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => SystemCubit(
                repository: context.read<ITaskRepository>(),
                projectRepository: context.read<IProjectRepository>(),
                authCubit: context.read<AuthCubit>(),
              )..listTasks(),
              child: TodayScreen(),
            );
          },
        ),
        GoRoute(
          path: '/projects/agenda',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => SystemCubit(
                repository: context.read<ITaskRepository>(),
                projectRepository: context.read<IProjectRepository>(),
                authCubit: context.read<AuthCubit>(),
              )..listTasks(),
              child: AgendaScreen(),
            );
          },
        ),

        GoRoute(
          path: '/projects/:projectId',
          builder: (context, state) {
            final projectId = int.parse(state.pathParameters['projectId']!);
            return BlocProvider(
              create: (context) => TaskCubit(
                repository: context.read<ITaskRepository>(),
                projectRepository: context.read<IProjectRepository>(),
                authCubit: context.read<AuthCubit>(),
                projectId: projectId,
              )..listTasks(),
              child: TasksScreen(projectId: projectId),
            );
          },
        ),
        GoRoute(
          path: '/tasks/:taskId',
          builder: (context, state) {
            final taskId = int.parse(state.pathParameters['taskId']!);

            return BlocProvider(
              create: (context) => DetailCubit(
                repository: context.read<ITaskRepository>(),
                projectRepository: context.read<IProjectRepository>(),
                taskId: taskId,
              )..getTaskDetail(),
              child: TaskDetailScreen(taskId: taskId),
            );
          },
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) {
            return BlocProvider(
              create: (context) => HomeCubit(
                repository: context.read<IProjectRepository>(),
                authCubit: context.read<AuthCubit>(),
                processImageUseCase: context.read<ProcessAiImageUseCase>(),
                processAudioUseCase: context.read<ProcessAiAudioUseCase>(),
                processDistributionUseCase: context
                    .read<ProcessAiDistributionUseCase>(),
              )..listProjects(),
              child: HomeScreen(),
            );
          },
        ),
        GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
        GoRoute(path: '/search', builder: (_, __) => const WIPScreen()),
      ],
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) => notifyListeners());
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
