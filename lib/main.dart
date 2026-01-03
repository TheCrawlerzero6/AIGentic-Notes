import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/local/database_helper.dart';
import 'data/services/notification_service.dart';
import 'providers/auth_provider.dart';
import 'providers/task_provider.dart';
import 'ui/screens/auth/login_screen.dart';
import 'ui/screens/home/home_screen.dart';

/// Punto de entrada de la aplicación AIGentic-Notes
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar base de datos SQLite
  try {
    await DatabaseHelper.instance.database;
  } catch (e) {
    debugPrint('Error al inicializar base de datos: $e');
  }

  // Inicializar servicio de notificaciones
  // FASE 5: Solicitar permisos al iniciar la app
  try {
    await NotificationService().initialize();
    await NotificationService().requestPermissions();
  } catch (e) {
    debugPrint('Error al inicializar notificaciones: $e');
  }

  runApp(const MyApp());
}

/// Widget raíz de la aplicación
/// 
/// Configura:
/// - Providers para gestión de estado (Auth, Tasks)
/// - Tema visual centralizado
/// - Rutas de navegación
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'AIGentic-Notes',
        theme: AppTheme.lightTheme,
        
        // Configuración de localización para DatePicker/TimePicker
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'),
          Locale('en', 'US'),
        ],
        
        home: const LoginScreen(),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
        },
      ),
    );
  }
}


