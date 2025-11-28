// lib/services/notification_service.dart
import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

typedef NotificationCallback = Future<void> Function(
  String payload,
  String actionId,
);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationCallback? onNotificationAction;

  Future<void> init({NotificationCallback? onAction}) async {
    onNotificationAction = onAction;

    // Inicializar zonas horarias (necesario para zonedSchedule)
    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse resp) async {
        final actionId = resp.actionId ?? 'tap';
        final payload = resp.payload ?? '';
        if (onNotificationAction != null) {
          await onNotificationAction!(payload, actionId);
        }
      },
    );

    // Crear canal Android de máxima importancia (necesario para heads-up)
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'mediapp_channel',
      'Recordatorios',
      description: 'Recordatorios de medicamentos',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Programa una notificación (heads-up, prioridad alta).
  /// Nota: el nombre del método coincide con el usado por ScheduleNotificationManager
  Future<void> scheduleFullscreenPersistentNotification({
    required int id,
    required DateTime scheduledDate,
    required String title,
    required String body,
    Map<String, dynamic>? payload,
  }) async {
    final tz.TZDateTime tzDate = tz.TZDateTime.from(scheduledDate, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'mediapp_channel',
      'Recordatorios',
      channelDescription: 'Recordatorios de tomas de medicación',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      ticker: 'Recordatorio',
      // fullScreenIntent intentionally left false — we want heads-up notifications.
      fullScreenIntent: false,
      autoCancel: true,
    );

    final iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );

    final payloadStr = payload != null ? jsonEncode(payload) : '';

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzDate,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payloadStr,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      // NOTA: no incluimos uiLocalNotificationDateInterpretation porque
      // esa opción no existe en la versión que usas.
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
