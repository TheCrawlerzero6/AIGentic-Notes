import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mi_agenda/features/auth/domain/repositories/auth_repository.dart';
import 'package:mi_agenda/features/auth/domain/usecases/login_usecase.dart';
import 'package:mi_agenda/features/auth/domain/usecases/logout_usecase.dart';
import 'package:mi_agenda/features/auth/domain/usecases/register_usercase.dart';
import 'package:mi_agenda/features/auth/domain/usecases/restore_session.dart';
import 'package:mi_agenda/features/tasks/data/datasources/project_local_datasource.dart';
import 'package:mi_agenda/core/services/sqlite_service.dart';
import 'package:mi_agenda/features/tasks/domain/repositories/project_repository.dart';
import 'package:mi_agenda/features/tasks/presentation/cubit/home_cubit.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/datasources/auth_local_datasource.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/auth/presentation/bloc/auth_cubit.dart';
import '../../features/tasks/data/repositories/project_repository.dart';

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
  BlocProvider<AuthCubit>(
    create: (context) => AuthCubit(
      login: context.read<LoginUsecase>(),
      register: context.read<RegisterUsecase>(),
      restoreSession: context.read<RestoreSession>(),
      logout: context.read<LogoutUsecase>(),
    )..checkSession(),
  ),
  Provider<ProjectLocalDatasource>(
    create: (context) =>
        ProjectLocalDatasource(db: context.read<SqliteService>()),
  ),
  Provider<IProjectRepository>(
    create: (context) =>
        ProjectRepository(dataSource: context.read<ProjectLocalDatasource>()),
  ),
  BlocProvider(
    create: (context) =>
        HomeCubit(repository: context.read<IProjectRepository>())
          ..listProjects(),
  ),
];
