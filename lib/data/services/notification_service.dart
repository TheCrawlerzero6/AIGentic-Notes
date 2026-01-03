import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

/// Servicio de notificaciones locales para alertas de tareas
/// 
/// Gestiona:
/// - Inicialización del sistema de notificaciones
/// - Programación de alertas en fecha/hora específica
/// - Cancelación de notificaciones
/// - Permisos en Android/iOS
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  /// Inicializa el servicio de notificaciones
  /// Debe llamarse en main() antes de runApp()
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar zonas horarias
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Lima')); // Ajusta según tu zona

    // Configuración Android
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración iOS
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('✅ NotificationService inicializado');
  }

  /// Maneja el tap en una notificación
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('🔔 Notificación presionada: ${response.payload}');
    // TODO FASE 6: Navegar a TaskDetailScreen con task ID del payload
  }

  /// Solicita permisos en Android 13+
  Future<bool> requestPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      debugPrint(granted == true 
          ? '✅ Permisos de notificación concedidos'
          : '❌ Permisos de notificación denegados');
      return granted ?? false;
    }

    return true; // iOS/otras plataformas
  }

  /// Programa una notificación en fecha/hora específica
  /// 
  /// Retorna el ID de la notificación generada
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) {
      throw Exception('NotificationService no inicializado. Llama initialize() primero.');
    }

    // Generar ID único basado en timestamp
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);

    const androidDetails = AndroidNotificationDetails(
      'tasks_channel', // ID del canal
      'Recordatorios de Tareas', // Nombre del canal
      channelDescription: 'Notificaciones para recordar tareas pendientes',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notifications.zonedSchedule(
      notificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint('🔔 Notificación programada #$notificationId para $scheduledDate');
    return notificationId;
  }

  /// Cancela una notificación por su ID
  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
    debugPrint('🚫 Notificación #$notificationId cancelada');
  }

  /// Cancela todas las notificaciones pendientes
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('🚫 Todas las notificaciones canceladas');
  }

  /// Obtiene lista de notificaciones pendientes (debug)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
