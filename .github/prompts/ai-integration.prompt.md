---
name: gen-ai
description: Implementa el servicio de firebase_ai con Function Calling
tools: [ 'edit' ]
argument-hint: Genera ai_service.dart
---
Actúa como un Ingeniero de IA especializado en el paquete `firebase_ai`.
Genera el código para `lib/data/services/ai_service.dart`.

Requisitos Técnicos:
1. Imports: Usa `import 'package:firebase_ai/firebase_ai.dart';`.
2. Modelo: Inicializa el modelo usando `FirebaseAI.googleAI().generativeModel(...)` (para usar el Free Tier de Gemini Developer API).
   - Usa el modelo `gemini-1.5-flash` para voz y comandos rápidos.
   - Usa `gemini-1.5-pro` para imágenes y archivos.
3. Function Calling (Tools):
   - Define una herramienta usando la clase `Tool` y `FunctionDeclaration`.
   - Nombre de función: `create_task`.
   - Parámetros (Schema): `title` (string), `description` (string), `dueDate` (string ISO8601), `priority` (int).
   - Pasa esta herramienta al constructor del modelo.
4. Métodos:
   - `generateFromVoice(File audioFile)`
   - `generateFromImage(File imageFile)`
   - `generateFromCsv(String csvContent)`
   - Todos deben usar `model.startChat()` para iniciar una sesión que soporte llamadas a función.
5. Seguridad: Añade comentarios recordando inicializar Firebase y App Check en el main.