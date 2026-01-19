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
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;
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
    debugPrint('NotificationService inicializado');
  }

  /// Maneja el tap en una notificación
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notificación presionada: ${response.payload}');
  }

  /// Solicita permisos en Android 13+
  Future<bool> requestPermissions() async {
    debugPrint('Solicitando permisos de notificación...');
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();

    if (androidPlugin != null) {
      final hasPermission = await androidPlugin.areNotificationsEnabled();
      debugPrint('Permisos actuales: ${hasPermission == true ? "concedidos" : "no concedidos"}');
      
      if (hasPermission != true) {
        final granted = await androidPlugin.requestNotificationsPermission();
        debugPrint(granted == true 
            ? 'Permisos de notificación concedidos'
            : 'Permisos de notificación denegados');
        if (granted != true) return false;
      }
      
      // Solicitar permiso de alarmas exactas (Android 12+)
      final canScheduleExact = await androidPlugin.canScheduleExactNotifications();
      debugPrint('Permiso de alarmas exactas: ${canScheduleExact == true ? "concedido" : "no concedido"}');
      
      if (canScheduleExact != true) {
        debugPrint('Solicitando permiso de alarmas exactas...');
        final exactGranted = await androidPlugin.requestExactAlarmsPermission();
        debugPrint(exactGranted == true
            ? 'Permiso de alarmas exactas concedido'
            : 'Permiso de alarmas exactas denegado - las notificaciones pueden no funcionar con la app cerrada');
        return exactGranted ?? false;
      }
      
      return true;
    }

    return true;
  }
  
  /// Muestra notificación inmediata para testing
  Future<void> showTestNotification() async {
    if (!_initialized) {
      await initialize();
    }
    
    const androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'Recordatorios de Tareas',
      channelDescription: 'Notificaciones para recordar tareas pendientes',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
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

    await _notifications.show(
      99999,
      'Test de Notificaciones',
      'Las notificaciones funcionan correctamente',
      notificationDetails,
      payload: 'test',
    );
    
    debugPrint('Notificación de prueba mostrada');
  }

  /// Programa una notificación en fecha/hora específica
  /// 
  /// Retorna el ID de la notificación generada
  /// Lanza excepción si el servicio no está inicializado o la fecha es pasada
  Future<int> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  }) async {
    if (!_initialized) {
      debugPrint('NotificationService no inicializado. Intentando inicializar...');
      try {
        await initialize();
      } catch (e) {
        throw Exception('Error al inicializar NotificationService: $e');
      }
    }

    // Validar que la fecha no sea pasada
    final now = DateTime.now();
    if (scheduledDate.isBefore(now)) {
      debugPrint('Advertencia: Intentando programar notificación en fecha pasada: $scheduledDate vs ahora: $now');
      throw Exception('No se puede programar notificación en fecha pasada');
    }

    // Generar ID único basado en timestamp
    final notificationId = DateTime.now().millisecondsSinceEpoch.remainder(100000);
    
    debugPrint('Programando notificación #$notificationId para $scheduledDate (ahora: $now)');

    const androidDetails = AndroidNotificationDetails(
      'tasks_channel',
      'Recordatorios de Tareas',
      channelDescription: 'Notificaciones para recordar tareas pendientes',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: true,
      enableVibration: true,
      showWhen: true,
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

    try {
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

      debugPrint('Notificación programada #$notificationId para $scheduledDate');
      
      // Verificar que se programó correctamente
      final pending = await getPendingNotifications();
      debugPrint('Total de notificaciones pendientes: ${pending.length}');
      
      return notificationId;
    } catch (e) {
      debugPrint('Error al programar notificación: $e');
      rethrow;
    }
  }

  /// Cancela una notificación por su ID
  Future<void> cancelNotification(int notificationId) async {
    await _notifications.cancel(notificationId);
    debugPrint('Notificación #$notificationId cancelada');
  }

  /// Cancela todas las notificaciones pendientes
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
    debugPrint('Todas las notificaciones canceladas');
  }

  /// Obtiene lista de notificaciones pendientes (debug)
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _notifications.pendingNotificationRequests();
  }
}
