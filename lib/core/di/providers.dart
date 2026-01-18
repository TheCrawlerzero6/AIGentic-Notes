import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/auth/domain/repositories/auth_repository.dart';
import 'package:mi_agenda/features/auth/domain/usecases/login_usecase.dart';
import 'package:mi_agenda/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mi_agenda/features/auth/domain/usecases/register_usercase.dart';
import 'package:mi_agenda/features/auth/domain/usecases/restore_session.dart';
import 'package:mi_agenda/features/home/data/datasources/project_local_datasource.dart';
import 'package:mi_agenda/core/data/services/sqlite_service.dart';
import 'package:mi_agenda/features/tasks/data/datasources/task_local_datasource.dart';
import 'package:mi_agenda/features/tasks/data/repositories/task_repository.dart';
import 'package:mi_agenda/features/home/data/services/ai_service.dart';
import 'package:mi_agenda/core/domain/repositories/project_repository.dart';
import 'package:mi_agenda/core/domain/repositories/task_repository.dart';
import 'package:mi_agenda/features/home/domain/usecases/process_ai_audio.dart';
import 'package:mi_agenda/features/home/domain/usecases/process_ai_image.dart';
import 'package:mi_agenda/features/home/domain/usecases/process_ai_distribution.dart';
import 'package:mi_agenda/features/home/presentation/cubit/home_cubit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/home/data/repositories/project_repository.dart';

// import 'ui/screens/home/home_screen.dart';
final localProviders = [
  Provider<SqliteService>.value(value: SqliteService.instance),
  Provider<AuthLocalDatasource>(
    create: (context) => AuthLocalDatasource(
      db: context.read<SqliteService>(),
      prefs: context.read<SharedPreferences>(),
    ),
  ),
  Provider<IAuthRepository>(
    create: (context) =>
        AuthRepository(datasource: context.read<AuthLocalDatasource>()),
  ),
  Provider<LoginUsecase>(
    create: (context) => LoginUsecase(context.read<IAuthRepository>()),
  ),
  Provider<RegisterUsecase>(
    create: (context) => RegisterUsecase(context.read<IAuthRepository>()),
  ),
  Provider<RestoreSession>(
    create: (context) => RestoreSession(context.read<IAuthRepository>()),
  ),
  Provider<LogoutUsecase>(
    create: (context) => LogoutUsecase(context.read<IAuthRepository>()),
  ),
  Provider<ProjectLocalDatasource>(
    create: (context) =>
        ProjectLocalDatasource(db: context.read<SqliteService>()),
  ),
  Provider<TaskLocalDatasource>(
    create: (context) => TaskLocalDatasource(db: context.read<SqliteService>()),
  ),
  Provider<IProjectRepository>(
    create: (context) =>
        ProjectRepository(dataSource: context.read<ProjectLocalDatasource>()),
  ),
  Provider<ITaskRepository>(
    create: (context) =>
        TaskRepository(dataSource: context.read<TaskLocalDatasource>()),
  ),

  BlocProvider<AuthCubit>(
    create: (context) => AuthCubit(
      login: context.read<LoginUsecase>(),
      register: context.read<RegisterUsecase>(),
      restoreSession: context.read<RestoreSession>(),
      logout: context.read<LogoutUsecase>(),
      taskRepository: context.read<ITaskRepository>(),
    )..checkSession(),
  ),
  Provider<AiService>(create: (_) => AiService()),
  Provider<ProcessAiImageUseCase>(
    create: (context) => ProcessAiImageUseCase(
      aiService: context.read<AiService>(),
      taskRepository: context.read<ITaskRepository>(),
    ),
  ),
  Provider<ProcessAiAudioUseCase>(
    create: (context) => ProcessAiAudioUseCase(
      aiService: context.read<AiService>(),
      taskRepository: context.read<ITaskRepository>(),
    ),
  ),
  Provider<ProcessAiDistributionUseCase>(
    create: (context) => ProcessAiDistributionUseCase(
      aiService: context.read<AiService>(),
      taskRepository: context.read<ITaskRepository>(),
      projectRepository: context.read<IProjectRepository>(),
    ),
  ),
  BlocProvider(
    create: (context) => HomeCubit(
      repository: context.read<IProjectRepository>(),
      authCubit: context.read<AuthCubit>(),
      processImageUseCase: context.read<ProcessAiImageUseCase>(),
      processAudioUseCase: context.read<ProcessAiAudioUseCase>(),
      processDistributionUseCase: context.read<ProcessAiDistributionUseCase>(),
    )..listProjects(),
  ),
];
