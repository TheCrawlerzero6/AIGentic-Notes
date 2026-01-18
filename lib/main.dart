import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mi_agenda/core/di/providers.dart';
import 'package:mi_agenda/core/router/routing.dart';
import 'package:mi_agenda/theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/home/data/services/ai_service.dart';
import 'core/data/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();

  // Inicializar Firebase Core como prerequisito para firebase_ai
  try {
    await Firebase.initializeApp();
    debugPrint('Firebase Core inicializado');
  } catch (e) {
    debugPrint('Error al inicializar Firebase: $e');
  }

  // Inicializar servicio de IA sin consumir solicitudes del API
  AiService().initialize().catchError((e) {
    debugPrint('Error al inicializar AiService: $e');
  });

  // Inicializar base de datos SQLite de forma bloqueante
  // try {
  //   await SqliteService.instance.database;
  //   debugPrint('Base de datos inicializada');
  // } catch (e) {
  //   debugPrint('Error al inicializar base de datos: $e');
  // }

  NotificationService()
      .initialize()
      .then((_) async {
        await NotificationService().requestPermissions();
      })
      .catchError((e) {
        debugPrint('Error al inicializar notificaciones: $e');
      });

  runApp(
    MultiProvider(
      providers: [
        Provider<SharedPreferences>.value(value: prefs),
        ...localProviders,
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authCubit = context.read<AuthCubit>();
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'AIGentic-Notes',
      theme: CustomAppTheme.lightTheme,
      darkTheme: CustomAppTheme.darkTheme,

      themeMode: ThemeMode.system,
      // Configuración de localización para DatePicker/TimePicker
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es', 'ES'), Locale('en', 'US')],

      routerConfig: AppRouter.router(authCubit),
    );
  }
}
