# 🤖 FIREBASE AI LOGIC - GUÍA DE IMPLEMENTACIÓN

## 📚 ¿Qué es Firebase AI Logic?

Firebase AI Logic es el SDK oficial de Google para integrar **Gemini** (y otros modelos de IA) en apps Flutter de forma **DIRECTA y SEGURA**, sin necesidad de backend propio.

### ✅ **LO QUE YA TENEMOS**
- ✅ Dependencias instaladas (`firebase_core: ^4.3.0`, `firebase_ai: ^3.6.1`)
- ✅ Servicio AI implementado (`lib/data/services/ai_service.dart`)
- ✅ Modelos preparados con métodos `fromJson` para IA

### ⚠️ **LO QUE FALTA (Para Módulo 6)**
- ❌ Configurar Firebase proyecto
- ❌ Ejecutar `flutterfire configure`
- ❌ Descomentar inicialización en `main.dart`
- ❌ Implementar parsing JSON completo en `AiService`

---

## 🔐 SEGURIDAD: ¿Dónde está la API Key?

### ❌ **LO QUE NO DEBES HACER**
```dart
// ⚠️ NUNCA hagas esto:
const apiKey = 'AIzaSy...'; // Hardcoded = INSEGURO
```

### ✅ **LO QUE HACE FIREBASE AI LOGIC**

**Firebase AI Logic maneja las credenciales AUTOMÁTICAMENTE**:

1. **Configuración en Firebase Console** (Paso 1 - Una vez):
   ```
   1. Ir a Firebase Console → AI Logic
   2. Click "Get Started"
   3. Seleccionar "Gemini Developer API" (GRATIS)
   4. Firebase genera API key en la nube
   ```

2. **Configuración local con FlutterFire** (Paso 2):
   ```bash
   flutterfire configure
   ```
   - Genera `lib/firebase_options.dart`
   - Genera `google-services.json` (Android)
   - Genera `GoogleService-Info.plist` (iOS)
   - Estos archivos NO contienen la API key directamente

3. **En runtime** (Automático):
   ```dart
   // Firebase AI usa DefaultFirebaseOptions
   final ai = FirebaseAI.firebaseAI(backend: Backend.googleAI());
   
   // Internamente:
   // 1. Lee firebase_options.dart
   // 2. Conecta con Firebase
   // 3. Firebase autentica tu app con google-services.json
   // 4. Firebase provee acceso a Gemini API SIN exponer la key
   ```

**Resultado**: La API key NUNCA está en tu código. Firebase actúa como proxy seguro.

---

## 🚀 CÓMO FUNCIONA (Arquitectura)

```
┌─────────────┐
│  Tu App     │
│  Flutter    │
└──────┬──────┘
       │ 1. Llama ai.generateContent()
       ↓
┌──────────────────┐
│ Firebase AI SDK  │ (firebase_ai package)
└──────┬───────────┘
       │ 2. Autentica con google-services.json
       ↓
┌─────────────────┐
│ Firebase Cloud  │ (Proxy seguro)
└──────┬──────────┘
       │ 3. Usa API key interna
       ↓
┌─────────────┐
│ Gemini API  │ (Google AI)
└─────────────┘
```

**Ventajas**:
- ✅ API key protegida en Firebase, no en el código
- ✅ Sin backend propio (serverless)
- ✅ Gratis hasta 15 req/min, 1500/día (Gemini Developer API)
- ✅ App Check previene uso no autorizado

---

## 📋 CONFIGURACIÓN PASO A PASO

### **Fase 1: Configurar Firebase (5 minutos)**

#### 1.1 Ir a Firebase Console
```
https://console.firebase.google.com/
```

#### 1.2 Crear/Seleccionar proyecto
- Si NO tienes proyecto: Click "Add project" → Nombre: "Mi-Agenda-Express"
- Si YA tienes proyecto: Selecciónalo

#### 1.3 Habilitar AI Logic
```
1. En el menú izquierdo: "AI Logic" (sección AI)
2. Click "Get started"
3. Seleccionar "Gemini Developer API" ✅ (Gratis)
   - NO seleccionar "Vertex AI Gemini API" (requiere billing)
4. Firebase genera automáticamente la API key
5. ⚠️ NO copies esta key a tu código
```

---

### **Fase 2: Conectar App a Firebase (3 minutos)**

#### 2.1 Instalar FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### 2.2 Ejecutar configuración automática
```bash
cd Mi-Agenda-Express-MAE
flutterfire configure
```

**El CLI te preguntará**:
```
? Select a Firebase project:
  > Mi-Agenda-Express (existing)
  
? Which platforms should your configuration support?
  ✓ android
  ✓ ios
  ✓ web (opcional)
  
✓ Firebase configuration file lib/firebase_options.dart generated.
```

**Archivos generados**:
- ✅ `lib/firebase_options.dart`
- ✅ `android/app/google-services.json`
- ✅ `ios/Runner/GoogleService-Info.plist`

⚠️ **IMPORTANTE**: Agregar a `.gitignore`:
```gitignore
# Firebase
google-services.json
GoogleService-Info.plist
firebase_options.dart  # Opcional - algunos lo comitan
```

---

### **Fase 3: Inicializar Firebase en la App**

#### 3.1 Descomentar en `lib/main.dart`:
```dart
import 'firebase_options.dart'; // ← AGREGAR

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar DB (ya hecho)
  final db = await DatabaseHelper.instance.database;

  // ✅ DESCOMENTAR ESTO:
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ✅ AGREGAR: Inicializar AI Service
  AiService().initialize();

  runApp(const MyApp());
}
```

#### 3.2 Agregar import en main.dart:
```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'data/services/ai_service.dart';
```

---

## 🧪 PRUEBA RÁPIDA (Sin implementar todo el Módulo 6)

### Test 1: Verificar Firebase conectado
```dart
// En cualquier parte del código:
void testFirebase() async {
  try {
    final ai = FirebaseAI.firebaseAI(backend: Backend.googleAI());
    final model = ai.generativeModel(modelName: 'gemini-2.5-flash');
    
    final response = await model.generateContent([
      Content.text('Di "Hola Firebase AI" en español'),
    ]);
    
    print('✅ IA responde: ${response.text}');
  } catch (e) {
    print('❌ Error: $e');
  }
}
```

---

## 📊 CUOTAS Y LÍMITES (Gemini Developer API - Gratis)

| Límite | Valor |
|--------|-------|
| **Requests por minuto** | 15 RPM |
| **Requests por día** | 1,500 RPD |
| **Tokens por minuto** | 1M TPM |
| **Costo** | **GRATIS** ✅ |

**Para MVP escolar**: Más que suficiente (1,500 tareas IA por día).

---

## 🎯 PRÓXIMOS PASOS (Módulo 6 - IA)

### Tareas pendientes:
1. ✅ Configurar Firebase proyecto (esta guía)
2. ✅ Ejecutar `flutterfire configure`
3. ❌ Implementar parsing JSON en `AiService`
4. ❌ Agregar manejo de errores robusto
5. ❌ Implementar UI para captura de voz/imagen
6. ❌ Conectar con `TaskProvider` para guardar en DB

### Archivos a modificar:
- `lib/data/services/ai_service.dart` (completar TODOs)
- `lib/ui/screens/home/home_screen.dart` (botones IA)
- `lib/providers/task_provider.dart` (método `addTaskFromAI()`)

---

## ❓ FAQ

**P: ¿Puedo usar esto sin Firebase Console?**  
R: No. Firebase AI Logic requiere proyecto Firebase activo.

**P: ¿Qué pasa si supero 1,500 requests/día?**  
R: Las requests adicionales fallarán con error de cuota. Para producción, considera Vertex AI (billing).

**P: ¿Necesito App Check?**  
R: No es obligatorio para desarrollo, pero recomendado para producción (previene bots).

**P: ¿Gemini Developer API vs Vertex AI?**  
R: 
- **Developer API**: Gratis, límites menores, ideal para MVP
- **Vertex AI**: Pago, límites mayores, para producción

**P: ¿Los datos se envían a Google?**  
R: Sí, los prompts se envían a Gemini API (Google). Lee [Data Governance](https://firebase.google.com/docs/ai-logic/data-governance).

---

**Estado actual**: ⚠️ Pendiente configuración Firebase  
**Duración estimada**: 10 minutos  
**Siguiente paso**: Ejecutar `flutterfire configure`
