# 📱 GUÍA DE CONFIGURACIÓN FIREBASE - Mi Agenda Express MVP

## 🎯 OBJETIVO
Configurar Firebase AI Logic para usar Gemini API (IA) en el proyecto Flutter.

---

## ✅ PRERREQUISITOS
- [ ] Tener una cuenta de Google
- [ ] Flutter instalado y funcionando
- [ ] Proyecto Flutter descargado localmente

---

## 📝 PASOS DE CONFIGURACIÓN

### **PASO 1: Crear Proyecto Firebase**

1. Ir a [Firebase Console](https://console.firebase.google.com)
2. Click en "Agregar proyecto" / "Add project"
3. Nombre del proyecto: `mi-agenda-express-mvp`
4. **Deshabilitar** Google Analytics (opcional para MVP)
5. Click en "Crear proyecto"

---

### **PASO 2: Habilitar Firebase AI Logic (Gemini API)**

1. En tu proyecto Firebase, ir a la sección **"AI Logic"** (menú lateral)
2. Click en **"Get Started"**
3. **IMPORTANTE:** Seleccionar **"Gemini Developer API"** (GRATIS)
   - ✅ No requiere tarjeta de crédito
   - ✅ 1,500 requests/día gratis
   - ✅ Ideal para MVP universitario
4. Aceptar términos y condiciones
5. Firebase generará automáticamente una API Key de Gemini

**⚠️ NO COPIES la API key manualmente al código - Firebase la gestiona automáticamente**

---

### **PASO 3: Registrar la App Android**

1. En Firebase Console → "Project Overview" → Click en ícono de Android
2. Llenar el formulario:
   - **Android package name:** `com.example.mi_agenda` 
     (Verificar en `android/app/build.gradle.kts` línea `namespace`)
   - **App nickname:** Mi Agenda Express
   - **SHA-1:** Dejar en blanco (opcional)
3. Click en "Registrar app"
4. **Descargar** el archivo `google-services.json`
5. **Mover** `google-services.json` a:
   ```
   android/app/google-services.json
   ```

---

### **PASO 4: Registrar la App iOS** (Opcional - Solo si tienes Mac)

1. En Firebase Console → Click en ícono de iOS
2. Llenar el formulario:
   - **iOS bundle ID:** `com.example.miAgenda`
     (Verificar en `ios/Runner.xcodeproj`)
   - **App nickname:** Mi Agenda Express
3. Click en "Registrar app"
4. **Descargar** el archivo `GoogleService-Info.plist`
5. **Mover** `GoogleService-Info.plist` a:
   ```
   ios/Runner/GoogleService-Info.plist
   ```

---

### **PASO 5: Configurar FlutterFire CLI** (Recomendado)

Abre una terminal en el directorio del proyecto y ejecuta:

```bash
# 1. Instalar FlutterFire CLI (solo una vez)
dart pub global activate flutterfire_cli

# 2. Configurar Firebase en el proyecto
flutterfire configure
```

**Esto generará automáticamente:**
- `lib/firebase_options.dart` (configuración para todas las plataformas)
- Conectará tu proyecto Flutter con Firebase

**Si aparece un selector de proyecto:**
- Selecciona `mi-agenda-express-mvp`

---

### **PASO 6: Actualizar Configuración de Android**

Abre el archivo: `android/app/build.gradle.kts`

**Busca la línea que dice:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}
```

**Agrégale esta línea al final:**
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ✅ AGREGAR ESTA LÍNEA
}
```

---

**Ahora abre:** `android/build.gradle.kts`

**Busca la sección `dependencies` y agrega:**
```kotlin
dependencies {
    classpath("com.android.tools.build:gradle:8.1.0")
    classpath("org.jetbrains.kotlin:kotlin-gradle-plugin:1.9.0")
    classpath("com.google.gms:google-services:4.4.0")  // ✅ AGREGAR ESTA LÍNEA
}
```

---

### **PASO 7: Descomentar Código en main.dart**

Abre: `lib/main.dart`

**Busca estas líneas y DESCOMÉNTALAS:**
```dart
// TODO: Descomentar cuando configures Firebase
// print('🚀 Inicializando Firebase...');
// await Firebase.initializeApp(
//   options: DefaultFirebaseOptions.currentPlatform,
// );
// print('✅ Firebase inicializado correctamente');
```

**Quedando así:**
```dart
print('🚀 Inicializando Firebase...');
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
print('✅ Firebase inicializado correctamente');
```

---

### **PASO 8: Probar la Configuración**

```bash
# 1. Obtener dependencias
flutter pub get

# 2. Limpiar build anterior
flutter clean

# 3. Ejecutar en Android
flutter run

# O en iOS (si tienes Mac)
flutter run -d iphone
```

**Deberías ver en la consola:**
```
🚀 Inicializando base de datos SQLite...
✅ Base de datos SQLite inicializada correctamente
🚀 Inicializando Firebase...
✅ Firebase inicializado correctamente
```

---

## ⚠️ SOLUCIÓN DE PROBLEMAS COMUNES

### **Error: "No Firebase App"**
✅ Solución: Verifica que `google-services.json` esté en `android/app/`

### **Error: "google-services plugin not found"**
✅ Solución: Verifica que agregaste la línea en `build.gradle.kts`

### **Error: "DefaultFirebaseOptions not found"**
✅ Solución: Ejecuta `flutterfire configure` nuevamente

### **La app compila pero Firebase no funciona**
✅ Solución:
1. `flutter clean`
2. `flutter pub get`
3. Reconstruir la app

---

## 📋 CHECKLIST FINAL

- [ ] Proyecto creado en Firebase Console
- [ ] Gemini Developer API habilitado
- [ ] `google-services.json` en `android/app/`
- [ ] `firebase_options.dart` generado
- [ ] Líneas descomentadas en `main.dart`
- [ ] `flutter pub get` ejecutado
- [ ] App ejecuta sin errores
- [ ] Mensaje "✅ Firebase inicializado" aparece en consola

---

## 🎉 ¡LISTO!

Una vez completados todos los pasos, Firebase estará configurado y listo para usar con Gemini AI en las siguientes fases.

**Próximo paso:** Módulo 3 - Implementar Autenticación Local
