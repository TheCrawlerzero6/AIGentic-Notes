import 'package:flutter/material.dart';

class WIPScreen extends StatefulWidget {
  const WIPScreen({super.key});

  @override
  State<WIPScreen> createState() => _WIPScreenState();
}

class _WIPScreenState extends State<WIPScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar tareas del usuario logueado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        automaticallyImplyLeading: false, // Quitar botón atrás
        title: const Text(
          'Pantalla en Proceso',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Work in progress", style: TextStyle(fontSize: 24)),
            Text("Nada que ver aqui jeje", style: TextStyle(fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
