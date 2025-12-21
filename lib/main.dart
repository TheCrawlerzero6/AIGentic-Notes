import 'package:mi_agenda/Login/login_view.dart';
import 'package:mi_agenda/Home/home_view.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mi Agenda Express',

      // 👇 Pantalla inicial
      home: const LoginView(),

      // (opcional) rutas si luego quieres usar Navigator.pushNamed
      routes: {
        '/login': (context) => const LoginView(),
        '/home': (context) => const HomeView(),
      },
    );
  }
}


