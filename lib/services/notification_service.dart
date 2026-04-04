import 'dart:convert';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

typedef NotificationCallback =
    Future<void> Function(String payload, String actionId);

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  NotificationCallback? onNotificationAction;

  Future<void> init({NotificationCallback? onAction}) async {
    onNotificationAction = onAction;

    tzdata.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();

    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

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
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(channel);
  }

  /// 🔥 NOTIFICACIÓN PERSISTENTE TIPO APPLE HEALTH
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
      fullScreenIntent: false,

      // 🔥 NO SE CIERRA HASTA ACCIÓN
      autoCancel: false,
      ongoing: true,

      actions: <AndroidNotificationAction>[
        const AndroidNotificationAction(
          'EVIDENCE',
          'Tomar dosis',
          showsUserInterface: true,
        ),
        const AndroidNotificationAction(
          'SKIP',
          'Omitir',
          showsUserInterface: true,
        ),
      ],
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
    );
  }

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
  }

  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
