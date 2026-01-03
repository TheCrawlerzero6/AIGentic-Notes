---
name: setup-arch
description: Reestructura el proyecto actual a la arquitectura Clean Simplificada
tools: [ 'edit' ]
argument-hint: Ejecutar sin argumentos para reestructurar todo el proyecto
---
Actúa como un Arquitecto de Software experto en Flutter.
Tu objetivo es refactorizar la estructura de archivos actual del proyecto para cumplir con la arquitectura propuesta.

Instrucciones:
1. Analiza los archivos actuales en `lib/`.
2. Mueve (o genera) los archivos necesarios para cumplir con esta estructura:
   - `lib/core/theme/` (Para colores y estilos)
   - `lib/data/local/` (Para database_helper)
   - `lib/data/models/` (Para clases Task y User)
   - `lib/data/services/` (Para ai_service y notification_service)
   - `lib/providers/` (Para AuthProvider y TaskProvider)
   - `lib/ui/auth/`, `lib/ui/home/`, `lib/ui/input/` (Para las pantallas)
3. Si un archivo no existe, genéralo con el código base necesario.
4. Actualiza los `imports` en `main.dart` para reflejar las nuevas rutas.