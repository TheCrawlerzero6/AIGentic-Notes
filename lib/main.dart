import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:mi_agenda/theme.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'data/local/database_helper.dart';
import 'data/services/notification_service.dart';
import 'data/services/ai_service.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home/home_screen.dart';

/// Punto de entrada de la aplicación AIGentic-Notes
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
  try {
    await DatabaseHelper.instance.database;
    debugPrint('Base de datos inicializada');
  } catch (e) {
    debugPrint('Error al inicializar base de datos: $e');
  }

  // Inicializar servicio de notificaciones de forma no bloqueante
  NotificationService()
      .initialize()
      .then((_) async {
        await NotificationService().requestPermissions();
      })
      .catchError((e) {
        debugPrint('Error al inicializar notificaciones: $e');
      });

  runApp(const MyApp());
}

/// Widget raíz de la aplicación
///
/// Configura:
/// - Providers para gestión de estado (Auth, Tasks)
/// - Tema visual centralizado
/// - Rutas de navegación
/// - Restaura sesión automáticamente al iniciar
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          return MaterialApp(
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

            home: FutureBuilder<bool>(
              future: authProvider.checkSession(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                final hasSession = snapshot.data ?? false;
                return hasSession ? const HomeScreen() : const LoginScreen();
              },
            ),
            routes: {
              '/login': (context) => const LoginScreen(),
              '/home': (context) => const HomeScreen(),
            },
          );
        },
      ),
    );
  }
}
