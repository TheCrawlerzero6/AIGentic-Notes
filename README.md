### Arquitectura Clean w/ Bloc + Cubit
 https://dev.to/alaminkarno/building-a-scalable-folder-structure-in-flutter-using-clean-architecture-bloccubit-530c

# AIGentic-Notes

**Agenda Inteligente Local-First con Procesamiento de IA en la Nube**

Aplicación móvil multiplataforma desarrollada en Flutter que combina el poder del almacenamiento local con capacidades de inteligencia artificial. Los datos del usuario permanecen en el dispositivo mediante SQLite, mientras que el procesamiento multimodal de IA se realiza en la nube usando Google Gemini API.

## Tabla de Contenidos

- [Descripción General](#descripción-general)
- [Características Principales](#características-principales)
- [Stack Tecnológico](#stack-tecnológico)
- [Arquitectura del Proyecto](#arquitectura-del-proyecto)
- [Estructura de Carpetas](#estructura-de-carpetas)
- [Base de Datos](#base-de-datos)
- [Sistemas de Creación de Tareas](#sistemas-de-creación-de-tareas)
- [Configuración del Proyecto](#configuración-del-proyecto)
- [Ejecución](#ejecución)
- [Flujos de Trabajo Críticos](#flujos-de-trabajo-críticos)
- [Reglas de Negocio](#reglas-de-negocio)
- [Limitaciones y Consideraciones](#limitaciones-y-consideraciones)

---

## Descripción General

AIGentic-Notes es un MVP (Producto Mínimo Viable) universitario que demuestra cómo integrar servicios de IA generativa en aplicaciones móviles manteniendo la privacidad del usuario. La aplicación permite crear tareas mediante cuatro métodos diferentes:

1. **Manual**: Formulario tradicional con campos de texto
2. **Imagen (OCR)**: Escaneo de texto escrito a mano o impreso
3. **Audio**: Transcripción de voz a texto con procesamiento de lenguaje natural
4. **Archivo**: Carga de archivos Excel con tareas estructuradas (próximamente)

### Principios de Diseño

**Local-First**: Todos los datos personales se almacenan exclusivamente en el dispositivo del usuario usando SQLite. No se envían datos sensibles a servidores externos.

**IA en la Nube**: Solo se envían imágenes, audio o archivos temporales al API de Google Gemini para procesamiento. La IA devuelve datos estructurados que se almacenan localmente.

**Privacidad Total**: No hay backend propio. No se requiere cuenta de usuario externa ni sincronización en la nube.

---

## Características Principales

### Gestión de Tareas
- Creación multimodal de tareas (manual, imagen, audio, archivo)
- Edición y eliminación de tareas existentes
- Estados: Pendiente y Completada
- Niveles de prioridad: Baja (1), Media (2), Alta (3)
- Trazabilidad por tipo de origen (`source_type`)

### Sistema de Notificaciones
- Notificaciones locales programadas basadas en la fecha de vencimiento
- Cancelación automática al completar una tarea
- Reprogramación al descompletar si la fecha es futura
- Manejo de zonas horarias con el paquete `timezone`

### Autenticación Local
- Registro e inicio de sesión sin conexión a internet
- Contraseñas hasheadas con SHA-256
- Persistencia de sesión usando SharedPreferences
- Aislamiento de datos por usuario

### Procesamiento con IA
- **OCR de Imágenes**: Extracción de tareas desde texto en fotos
- **Transcripción de Audio**: Conversión de comandos de voz a tareas estructuradas
- **Análisis Semántico**: La IA infiere título, descripción, fecha de vencimiento y prioridad
- **Validación de Respuestas**: JSON Schema estricto para garantizar formato consistente

### Dashboard Inteligente
- Visualización de tareas pendientes
- Filtrado automático de tareas completadas antiguas (Regla de 48 horas)
- Indicadores visuales de prioridad con código de colores
- Preview de tiempo restante hasta vencimiento

---

## Stack Tecnológico

### Framework y Lenguaje
- **Flutter 3.9.2+**: Framework multiplataforma (iOS, Android, Web, Desktop)
- **Dart 3.9.2+**: Lenguaje de programación

### Gestión de Estado
- **Provider 6.1.0**: Patrón Observer reactivo para gestión de estado

### Base de Datos
- **sqflite 2.3.0**: SQLite embebido para almacenamiento local
- **path_provider 2.1.0**: Acceso a rutas del sistema de archivos

### Inteligencia Artificial
- **firebase_core 4.3.0**: SDK base de Firebase (prerequisito)
- **firebase_ai 3.6.1**: Cliente unificado para Google Gemini API
- **Modelo**: `gemini-2.5-flash` (límite gratuito: 20 solicitudes/día)

### Notificaciones
- **flutter_local_notifications 18.0.0**: Notificaciones programadas
- **timezone 0.9.0**: Manejo de zonas horarias

### Seguridad
- **crypto 3.0.3**: Hashing de contraseñas con SHA-256
- **shared_preferences 2.2.2**: Almacenamiento seguro de sesión

### Inputs Multimodales
- **image_picker 1.1.2**: Captura/selección de imágenes
- **file_picker 8.0.0**: Selección de archivos del sistema
- **excel 4.0.3**: Lectura de archivos Excel (en desarrollo)
- **flutter_sound 9.2.13**: Grabación de audio multiplataforma
- **permission_handler 11.0.0**: Gestión de permisos de micrófono y almacenamiento
- **image 4.1.0**: Compresión de imágenes

### Utilidades
- **intl 0.20.2**: Formateo de fechas y localización
- **flutter_localizations**: Soporte de español en DatePicker/TimePicker
- **cupertino_icons 1.0.8**: Iconos de iOS
- **flutter_svg 2.2.3**: Soporte para gráficos vectoriales

### Desarrollo
- **flutter_test**: Framework de testing
- **flutter_lints 5.0.0**: Reglas de linting de Dart
- **sqflite_common_ffi 2.3.0**: Testing de SQLite sin emulador
- **flutter_launcher_icons 0.14.1**: Generación automática de íconos

---

## Arquitectura del Proyecto

La aplicación sigue una arquitectura Clean Simplificada adaptada para MVPs, separando responsabilidades en capas lógicas:

```
┌─────────────────────────────────────────┐
│          UI Layer (Screens)             │
│  - Login/Register                       │
│  - Home Dashboard                       │
│  - Task Detail                          │
│  - Profile                              │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│       Providers (State Management)      │
│  - AuthProvider: Sesión y autenticación │
│  - TaskProvider: CRUD de tareas         │
└────────────┬────────────────────────────┘
             │
             ▼
┌─────────────────────────────────────────┐
│          Data Layer                     │
│  ┌───────────────────────────────────┐  │
│  │  Services (Business Logic)        │  │
│  │  - AiService: Procesamiento IA    │  │
│  │  - NotificationService: Alertas   │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Local (Persistence)              │  │
│  │  - DatabaseHelper: SQLite CRUD    │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │  Models (Entities)                │  │
│  │  - TaskModel: Entidad de tarea    │  │
│  │  - UserModel: Entidad de usuario  │  │
│  └───────────────────────────────────┘  │
└─────────────────────────────────────────┘
```

### Flujo de Datos

1. **UI → Provider**: El usuario interactúa con un widget (ej: botón "Crear Tarea")
2. **Provider → Services**: El provider llama al servicio correspondiente (ej: `AiService.processImage()`)
3. **Service → External API**: El servicio envía datos al API de Gemini (solo para IA)
4. **Service → Database**: El servicio guarda/lee datos locales vía `DatabaseHelper`
5. **Provider notifica a UI**: `notifyListeners()` actualiza automáticamente la vista

---

## Estructura de Carpetas

```
lib/
├── main.dart                          # Punto de entrada de la aplicación
│
├── config/                            # Configuración global
│   └── feature_flags.dart             # Banderas de características experimentales
│
├── core/                              # Utilidades compartidas
│   ├── constants/
│   │   └── app_constants.dart         # Constantes globales (nombres de tablas, etc.)
│   ├── theme/
│   │   └── app_theme.dart             # Tema visual centralizado (colores, tipografía)
│   └── utils/
│       └── validators.dart            # Validadores de formularios
│
├── data/                              # Capa de datos
│   ├── local/                         # Persistencia local
│   │   └── database_helper.dart       # Singleton de SQLite (CRUD)
│   │
│   ├── models/                        # Entidades de negocio
│   │   ├── task_model.dart            # Modelo de tarea con métodos toMap/fromMap
│   │   └── user_model.dart            # Modelo de usuario
│   │
│   └── services/                      # Servicios de negocio
│       ├── ai_service.dart            # Cliente de Firebase AI (Gemini)
│       ├── notification_service.dart  # Programación de notificaciones locales
│       └── speech_service.dart        # Placeholder para síntesis de voz
│
├── providers/                         # Gestión de estado reactiva
│   ├── auth_provider.dart             # Estado de autenticación y sesión
│   └── task_provider.dart             # Estado de tareas y orquestación de CRUD
│
└── ui/                                # Capa de presentación
    ├── screens/                       # Pantallas completas
    │   ├── auth/
    │   │   ├── login_screen.dart      # Pantalla de inicio de sesión
    │   │   └── register_screen.dart   # Pantalla de registro
    │   ├── home/
    │   │   ├── home_screen.dart       # Dashboard principal con lista de tareas
    │   │   └── task_detail_screen.dart # Detalle y edición de tarea
    │   └── profile/
    │       └── profile_screen.dart    # Perfil de usuario y logout
    │
    ├── widgets/                       # Componentes reutilizables
    │   ├── add_task_bottom_sheet.dart # Modal de creación de tareas
    │   ├── ai_options_widget.dart     # Selector de método de IA (imagen/audio/archivo)
    │   ├── audio_recorder_widget.dart # Grabador de audio con controles
    │   ├── file_picker_widget.dart    # Selector de archivos Excel
    │   ├── image_scanner_widget.dart  # Captura/selección de imágenes
    │   ├── priority_indicator.dart    # Indicador visual de prioridad
    │   └── time_picker_spinner.dart   # Selector de hora estilo iOS
    │
    └── shared/                        # Widgets compartidos genéricos
        └── custom_button.dart         # Botón personalizado
```

### Justificación de la Estructura

**`config/`**: Separa configuraciones experimentales del código de negocio. Los feature flags permiten activar/desactivar funcionalidades sin modificar código productivo.

**`core/`**: Centraliza utilidades reutilizables que no dependen de la lógica de negocio. Los temas y constantes aquí facilitan el mantenimiento.

**`data/`**: Encapsula toda la lógica de acceso a datos. La separación entre `local/` (SQLite), `models/` (entidades) y `services/` (lógica compleja) permite cambiar implementaciones sin afectar la UI.

**`providers/`**: Actúan como intermediarios entre UI y datos. Mantienen el estado de la aplicación y notifican cambios a los widgets suscritos.

**`ui/`**: Separación entre `screens/` (rutas completas) y `widgets/` (componentes reutilizables) mejora la modularidad y testing.

---

## Base de Datos

### Esquema SQLite

La aplicación usa SQLite local con dos tablas principales:

#### Tabla `users`

| Columna        | Tipo    | Restricciones                  | Descripción                          |
|----------------|---------|--------------------------------|--------------------------------------|
| id             | INTEGER | PRIMARY KEY AUTOINCREMENT      | Identificador único del usuario      |
| username       | TEXT    | NOT NULL UNIQUE                | Nombre de usuario (único)            |
| password_hash  | TEXT    | NOT NULL                       | Hash SHA-256 de la contraseña        |
| createdAt     | TEXT    | NOT NULL                       | Timestamp ISO8601 de creación        |

#### Tabla `tasks`

| Columna          | Tipo    | Restricciones                     | Descripción                                    |
|------------------|---------|-----------------------------------|------------------------------------------------|
| id               | INTEGER | PRIMARY KEY AUTOINCREMENT         | Identificador único de la tarea                |
| user_id          | INTEGER | NOT NULL, FOREIGN KEY → users(id) | Propietario de la tarea                        |
| title            | TEXT    | NOT NULL                          | Título corto de la tarea                       |
| description      | TEXT    | NULL                              | Descripción detallada opcional                 |
| due_date         | TEXT    | NOT NULL                          | Fecha de vencimiento (ISO8601)                 |
| is_completed     | INTEGER | NOT NULL DEFAULT 0                | Estado: 0 = pendiente, 1 = completada          |
| completed_at     | TEXT    | NULL                              | Timestamp de completado (ISO8601)              |
| notification_id  | INTEGER | NULL                              | ID para gestionar notificaciones               |
| source_type      | TEXT    | NOT NULL                          | Origen: 'manual', 'voice', 'image', 'file'     |
| priority         | INTEGER | NOT NULL DEFAULT 2                | Prioridad: 1 = Baja, 2 = Media, 3 = Alta       |

### Operaciones CRUD

Las operaciones de base de datos están centralizadas en `DatabaseHelper`:

```dart
// Crear tarea
final taskId = await DatabaseHelper.instance.insertTask(newTask);

// Leer tareas de usuario (con filtro de 48 horas)
final tasks = await DatabaseHelper.instance.getDashboardTasks(userId);

// Actualizar tarea
await DatabaseHelper.instance.updateTask(updatedTask);

// Eliminar tarea
await DatabaseHelper.instance.deleteTask(taskId);
```

---

## Sistemas de Creación de Tareas

La aplicación ofrece cuatro métodos para crear tareas, cada uno optimizado para diferentes escenarios de uso:

### 1. Creación Manual

**Descripción**: Formulario tradicional con campos de texto, selectores de fecha/hora y nivel de prioridad.

**Flujo**:
1. Usuario presiona botón flotante `+` en el dashboard
2. Se abre `AddTaskBottomSheet` con formulario vacío
3. Usuario completa campos: título, descripción, fecha, hora, prioridad
4. Sistema valida campos obligatorios (título, fecha)
5. Se crea `TaskModel` con `source_type: 'manual'`
6. `TaskProvider` inserta en SQLite y programa notificación

**Ventajas**:
- Control total sobre los datos
- Sin consumo de API
- Sin permisos especiales

**Archivo**: `lib/ui/widgets/add_task_bottom_sheet.dart`

---

### 2. Creación por Imagen (OCR)

**Descripción**: Escaneo de texto escrito a mano o impreso mediante la cámara o galería de fotos.

**Flujo**:
1. Usuario presiona "Llenar con IA" → "Escanear Imagen"
2. Se abre `ImagePicker` (cámara o galería)
3. Usuario captura/selecciona imagen
4. La imagen se comprime y convierte a bytes (Uint8List)
5. `AiService.processImage()` envía bytes al API de Gemini con prompt específico
6. Gemini analiza el texto en la imagen usando visión multimodal
7. IA devuelve JSON con estructura: `{tasks: [{title, description, due_date, priority}]}`
8. Sistema parsea JSON y autocompleta campos del formulario
9. Usuario revisa/edita antes de confirmar

**Tecnologías**:
- `image_picker`: Captura/selección de imágenes
- `image`: Compresión para reducir tamaño
- Gemini Vision API: OCR multilingüe

**Prompt de IA**:
```
Analiza esta imagen y extrae la tarea, recordatorio o evento visible.
Devuelve UN SOLO objeto JSON con:
{
  "tasks": [{
    "title": "Título corto",
    "description": "Descripción detallada",
    "due_date": "2026-01-15T14:30:00" o null,
    "priority": 1-3
  }]
}
```

**Ejemplo de Uso**:
- Usuario toma foto de nota adhesiva: "Reunión con cliente - Viernes 3pm"
- IA infiere: `title: "Reunión con cliente"`, `due_date: "2026-01-10T15:00:00"`, `priority: 2`

**Archivo**: `lib/data/services/ai_service.dart` → `_processImage()`

---

### 3. Creación por Audio (Transcripción)

**Descripción**: Grabación de comandos de voz que se transcriben y analizan para crear tareas.

**Flujo**:
1. Usuario presiona "Llenar con IA" → "Grabar Audio"
2. Se abre `AudioRecorderWidget` con botón de grabación
3. Sistema solicita permiso de micrófono
4. Usuario graba hasta 60 segundos (límite configurable)
5. Audio se guarda en formato AAC (mejor compresión)
6. `AiService.processAudio()` envía bytes al API de Gemini
7. Gemini transcribe audio y extrae estructura de tarea
8. Sistema autocompleta formulario con datos extraídos

**Tecnologías**:
- `flutter_sound`: Grabación multiplataforma
- `permission_handler`: Solicitud de permiso de micrófono
- Gemini Audio API: Transcripción automática

**Prompt de IA**:
```
Transcribe este audio y extrae la tarea mencionada.
Devuelve JSON con: title, description, due_date, priority.
Infiere prioridad del tono y palabras clave ("urgente", "importante").
```

**Ejemplo de Uso**:
- Usuario dice: "Recordarme comprar leche mañana a las 6 de la tarde"
- IA genera: `title: "Comprar leche"`, `due_date: "2026-01-04T18:00:00"`, `priority: 1`

**Archivo**: `lib/data/services/ai_service.dart` → `_processAudio()`

---

### 4. Creación por Archivo Excel (En Desarrollo)

**Descripción**: Carga masiva de tareas desde archivos Excel estructurados.

**Estado**: Placeholder implementado, lógica pendiente.

**Flujo Planificado**:
1. Usuario presiona "Llenar con IA" → "Cargar Excel"
2. Se abre `FilePicker` con filtro de archivos `.xlsx`
3. Usuario selecciona archivo
4. Sistema lee filas con columnas predefinidas: `Tarea`, `Descripción`, `Fecha`, `Prioridad`
5. `AiService.processFile()` parsea el archivo
6. Se crean múltiples tareas en lote

**Tecnologías Previstas**:
- `file_picker`: Selección de archivos
- `excel`: Lectura de hojas de cálculo

**Archivo**: `lib/data/services/ai_service.dart` → `processFileToTasks()` (stub)

---

## Configuración del Proyecto

### Prerequisitos

- **Flutter SDK**: 3.9.2 o superior
- **Dart SDK**: 3.9.2 o superior
- **Android Studio** o **VS Code** con extensiones de Flutter
- **Dispositivo físico** o **emulador** (Android/iOS)
- **Cuenta de Google Cloud** (para API de Gemini)

### 1. Clonar el Repositorio

```bash
git clone <URL_DEL_REPOSITORIO>
cd Mi-Agenda-Express-MAE
```

### 2. Instalar Dependencias

```bash
flutter pub get
```

### 3. Configurar Firebase

#### A. Crear Proyecto en Firebase Console

1. Accede a [Firebase Console](https://console.firebase.google.com/)
2. Crea un nuevo proyecto (ej: "AIGentic-Notes")
3. Deshabilita Google Analytics (opcional para MVP)

#### B. Registrar App Android

1. En Firebase Console → Configuración del proyecto → Agregar app → Android
2. Paquete de Android: `com.example.mi_agenda`
3. Descarga `google-services.json`
4. Copia el archivo a `android/app/google-services.json`

#### C. Obtener API Key de Gemini

1. Accede a [Google AI Studio](https://aistudio.google.com/apikey)
2. Crea una nueva API Key
3. **IMPORTANTE**: Mantén la API Key privada, nunca la subas a GitHub

#### D. Configurar API Key en el Proyecto

Crea el archivo `lib/core/constants/api_keys.dart`:

```dart
class ApiKeys {
  static const String geminiApiKey = 'TU_API_KEY_AQUÍ';
}
```

**Nota**: Este archivo debe estar en `.gitignore` para evitar exposición.

### 4. Configurar Permisos

#### Android (`android/app/src/main/AndroidManifest.xml`)

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.RECORD_AUDIO" />
<uses-permission android:name="android.permission.CAMERA" />
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

#### iOS (`ios/Runner/Info.plist`)

```xml
<key>NSCameraUsageDescription</key>
<string>Se requiere acceso a la cámara para escanear tareas</string>
<key>NSMicrophoneUsageDescription</key>
<string>Se requiere acceso al micrófono para grabar tareas por voz</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>Se requiere acceso a la galería para seleccionar imágenes</string>
```

---

## Ejecución

### Modo Debug (Desarrollo)

```bash
flutter run
```

### Ejecutar en Dispositivo Específico

```bash
# Listar dispositivos disponibles
flutter devices

# Ejecutar en dispositivo específico
flutter run -d <device_id>
```

### Ejecutar Tests Unitarios

```bash
flutter test
```

### Build para Producción

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Google Play)
flutter build appbundle --release

# iOS (requiere Mac con Xcode)
flutter build ios --release
```

---

## Flujos de Trabajo Críticos

### Flujo 1: Registro e Inicio de Sesión

```
Usuario Nuevo
    ↓
[RegisterScreen]
    ↓
Ingresa username y password
    ↓
AuthProvider.register()
    ↓
Hash SHA-256 de password
    ↓
DatabaseHelper.insertUser()
    ↓
Guardar user_id en SharedPreferences
    ↓
Navegar a HomeScreen
```

### Flujo 2: Creación de Tarea Manual

```
Usuario en HomeScreen
    ↓
Presiona botón flotante "+"
    ↓
[AddTaskBottomSheet] se abre
    ↓
Usuario completa formulario
    ↓
Valida campos obligatorios
    ↓
Crea TaskModel con sourceType: 'manual'
    ↓
TaskProvider.createTask()
    ├── DatabaseHelper.insertTask() → SQLite
    └── NotificationService.schedule() → Alerta local
    ↓
notifyListeners() → UI se actualiza
    ↓
BottomSheet se cierra con SnackBar de éxito
```

### Flujo 3: Creación de Tarea por IA (Imagen)

```
Usuario presiona "Llenar con IA"
    ↓
[AIOptionsWidget] muestra opciones
    ↓
Usuario selecciona "Escanear Imagen"
    ↓
ImagePicker.pickImage() → Cámara/Galería
    ↓
Usuario captura/selecciona imagen
    ↓
Imagen se comprime a 800x800px
    ↓
AiService.processImage(bytes)
    ├── Registra solicitud (contador)
    ├── Crea Content con DataPart (image/jpeg)
    └── Envía a Gemini con prompt específico
    ↓
Gemini API procesa imagen
    ↓
Respuesta JSON: {tasks: [{title, description, due_date, priority}]}
    ↓
AiService parsea JSON y crea TaskModel
    ↓
Autocompleta formulario en AddTaskBottomSheet
    ↓
Usuario revisa/edita datos
    ↓
Confirma creación → TaskProvider.createTask()
```

### Flujo 4: Completar/Descompletar Tarea

```
Usuario marca tarea como completada
    ↓
TaskProvider.toggleTaskCompletion(task)
    ↓
¿Tarea actualmente pendiente?
    ├── SÍ: 
    │   ├── Set is_completed = 1
    │   ├── Set completed_at = DateTime.now()
    │   └── NotificationService.cancel(notification_id)
    └── NO:
        ├── Set is_completed = 0
        ├── Set completed_at = null
        └── ¿due_date es futuro?
            ├── SÍ: NotificationService.schedule()
            └── NO: No reprogramar
    ↓
DatabaseHelper.updateTask()
    ↓
loadTasks() → Refresca lista
    ↓
notifyListeners() → UI actualizada
```

### Flujo 5: Sistema de Notificaciones

```
[Creación de Tarea]
    ↓
Se genera notification_id aleatorio
    ↓
NotificationService.schedule(id, title, dueDate)
    ↓
Convierte dueDate a TZDateTime (timezone)
    ↓
FlutterLocalNotifications.zonedSchedule()
    ↓
Notificación programada en sistema operativo
    ↓
---[Al llegar due_date]---
    ↓
Sistema muestra notificación local
    ↓
Usuario toca notificación
    ↓
App abre (onNotificationTap)
    ↓
[Opcional] Navega a Task Detail
```

---

## Reglas de Negocio

### Regla 1: Visibilidad de Tareas Completadas (48 Horas)

**Descripción**: Las tareas completadas solo son visibles en el dashboard durante 48 horas después de ser marcadas como completadas. Después de este período, se ocultan automáticamente para evitar saturar la vista.

**Implementación**:
```sql
SELECT * FROM tasks 
WHERE user_id = ? 
  AND (
    is_completed = 0 
    OR (is_completed = 1 AND julianday('now') - julianday(completed_at) <= 2)
  )
ORDER BY due_date ASC
```

**Justificación**: Mantiene el dashboard limpio y enfocado en tareas activas, mientras permite al usuario ver logros recientes.

### Regla 2: Ciclo de Vida de Notificaciones

**Al Crear Tarea**:
- Se genera `notification_id` aleatorio único
- Se programa notificación local para `due_date`
- La notificación persiste hasta que se cancele manualmente

**Al Completar Tarea**:
- Se cancela la notificación usando `notification_id`
- Se actualiza `is_completed = 1` y `completed_at = DateTime.now()`

**Al Descompletar Tarea**:
- Si `due_date` es futuro: se reprograma la notificación
- Si `due_date` es pasado: no se programa notificación

### Regla 3: Validación de Campos Obligatorios

**Título**:
- Mínimo 1 carácter
- Máximo 100 caracteres (recomendado)
- No puede ser solo espacios en blanco

**Fecha de Vencimiento**:
- Debe ser fecha futura
- Formato ISO8601: `YYYY-MM-DDTHH:mm:ss`
- Si no se especifica hora, se asume 23:59 del día seleccionado

**Prioridad**:
- Valores válidos: 1 (Baja), 2 (Media), 3 (Alta)
- Por defecto: 2 (Media)

### Regla 4: Límite de API de IA

**Límite**: 20 solicitudes por día (Free Tier de gemini-2.5-flash)

**Monitoreo**:
- `AiService` cuenta solicitudes en sesión actual
- Registra timestamps de solicitudes en ventana de 60 segundos
- Logs de consumo de tokens (entrada/salida/total)

**Mitigación**:
- Eliminar llamadas innecesarias (ej: `testConnection()` removido)
- Advertencia al usuario al alcanzar 18/20 solicitudes
- Mensaje de error claro al superar cuota

### Regla 5: Aislamiento de Datos por Usuario

**Principio**: Cada usuario solo puede acceder a sus propias tareas.

**Implementación**:
- Todas las consultas de tareas filtran por `user_id`
- Foreign Key `tasks.user_id → users.id` con `ON DELETE CASCADE`
- Al eliminar usuario, se eliminan automáticamente todas sus tareas

---

## Limitaciones y Consideraciones

### Limitaciones Técnicas

1. **Cuota de API Gratuita**: Límite de 20 solicitudes diarias para procesamiento de IA. Exceder el límite requiere esperar 24 horas o migrar a plan de pago.

2. **Procesamiento Local Limitado**: SQLite no soporta búsqueda de texto completo avanzada (FTS5 requiere configuración adicional).

3. **Sin Sincronización en la Nube**: Los datos solo existen en el dispositivo. Perder el dispositivo implica pérdida de datos.

4. **Notificaciones en iOS**: Requiere certificado de desarrollo y aprovación de Apple para producción.

5. **Precisión de IA Variable**: El OCR y transcripción dependen de la calidad del input (iluminación, ruido de fondo, claridad de escritura).

### Consideraciones de Privacidad

- **Datos Sensibles**: Nunca envíes contraseñas, datos financieros o información médica a través de IA.
- **API Key**: La API Key está hardcodeada en el cliente. Para producción, implementar proxy backend.
- **Logs de Desarrollo**: Los `debugPrint()` pueden exponer datos en consola. Deshabilitar en release.

### Escalabilidad Futura

Para convertir este MVP en producto completo, considerar:

1. **Backend Propio**: API REST para sincronización multi-dispositivo
2. **Autenticación OAuth**: Login con Google/Apple
3. **Plan de Pago de IA**: Migrar a Vertex AI o contratar cuota mayor
4. **Offline First**: Implementar cola de sincronización con Hive/Isar
5. **Testing**: Aumentar cobertura de tests unitarios y de integración
6. **CI/CD**: Pipeline automatizado con GitHub Actions

---

## Contribuciones

Este es un proyecto académico. Las contribuciones son bienvenidas para propósitos educativos.

### Cómo Contribuir

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agrega nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

---

## Licencia

Este proyecto está bajo la licencia MIT. Consulta el archivo `LICENSE` para más detalles.

---

## Contacto y Soporte

Para dudas o reportes de bugs, abre un issue en el repositorio.

**Desarrollado como MVP Universitario - 2026**
