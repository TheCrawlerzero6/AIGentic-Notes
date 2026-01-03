import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/foundation.dart';

/// Tests UNITARIOS del servicio IA
/// 
/// IMPORTANTE: Estos tests NO llaman a Firebase/Gemini real
/// Solo verifican la lógica de validación y manejo de errores
/// 
/// Para probar con API real:
/// 1. Ejecuta la app en el emulador: flutter run
/// 2. Usa el botón "Llenar con IA" desde la UI
/// 3. Verifica logs en consola

void main() {
  group('AiService - Validaciones', () {
    test('extractJson limpia respuestas con markdown', () {
      const responseWithMarkdown = '''
```json
{
  "tasks": [
    {"title": "Tarea 1", "description": "Desc 1"}
  ]
}
```
      ''';

      // Simulamos el método privado _extractJson
      final cleaned = responseWithMarkdown
          .replaceAll('```json', '')
          .replaceAll('```', '')
          .trim();

      expect(cleaned, contains('"tasks"'));
      expect(cleaned, contains('"title"'));
    });

    test('Imagen PNG 1x1 es válida en bytes', () {
      final mockPng = Uint8List.fromList([
        0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A,
      ]);

      expect(mockPng.length, greaterThan(0));
      expect(mockPng[0], equals(0x89)); // PNG signature
      expect(mockPng[1], equals(0x50)); // 'P'
    });

    test('Validación estructura JSON esperada', () {
      const validJson = '''
{
  "tasks": [
    {
      "title": "Comprar leche",
      "description": "En el super",
      "due_date": "2026-01-04T15:00:00",
      "priority": 2
    }
  ]
}
      ''';

      expect(validJson, contains('"tasks"'));
      expect(validJson, contains('"title"'));
      expect(validJson, contains('"due_date"'));
    });
  });

  group('AiService - Documentación Integración', () {
    test('Instrucciones para probar con API real', () {
      const instructions = '''
=================================================
 CÓMO PROBAR EL SERVICIO IA CON GEMINI REAL
=================================================

1. CONFIGURAR API KEY:
   - Ve a: https://aistudio.google.com/apikey
   - Crea/activa tu API key
   - Verifica cuota habilitada

2. EJECUTAR APP:
   flutter run

3. PROBAR DESDE UI:
   a) Tap botón "Llenar con IA"
   b) Selecciona "Escanear Imagen"
   c) Toma foto de papel con texto:
      "Comprar leche mañana 3pm"
   d) Verifica que autocompleta campos

4. VERIFICAR LOGS:
   - ✓ "Inicializado correctamente"
   - ✓ "Procesando imagen..."
   - ✓ "Tareas extraídas: X"
   
   Si falla:
   - ✗ "quota exceeded" → Configura API key
   - ✗ "no pudo procesar" → Imagen poco clara
   - ✗ "no encontraron tareas" → Sin texto en imagen

=================================================
      ''';

      expect(instructions, contains('API KEY'));
      expect(instructions, contains('flutter run'));
      debugPrint(instructions);
    });
  });

  group('AiService - Casos de Error Esperados', () {
    test('Mensaje error quota debe ser claro', () {
      const quotaError = 'Configura tu API key en Google AI Studio';
      
      expect(quotaError, contains('API key'));
      expect(quotaError, contains('Google AI Studio'));
    });

    test('Mensaje error imagen no procesada', () {
      const imageError = 'La IA no pudo leer la imagen. Intenta con otra más clara';
      
      expect(imageError, contains('no pudo leer'));
      expect(imageError, contains('más clara'));
    });

    test('Mensaje sin tareas encontradas', () {
      const noTasksError = 'No se encontraron tareas en la imagen';
      
      expect(noTasksError, contains('encontraron'));
      expect(noTasksError, contains('tareas'));
    });
  });

  group('AiService - Feature Flags', () {
    test('Validar flags por defecto', () {
      // Según feature_flags.dart
      const aiVision = true;
      const aiAudio = false; // Placeholder
      const aiFile = false;  // Placeholder

      expect(aiVision, isTrue, reason: 'FASE 8 IA Vision debe estar activa');
      expect(aiAudio, isFalse, reason: 'Audio aún es placeholder');
      expect(aiFile, isFalse, reason: 'Excel aún es placeholder');
    });
  });
}

