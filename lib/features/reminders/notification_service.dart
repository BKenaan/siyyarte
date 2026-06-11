import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:timezone/timezone.dart' as tz;

/// Handles on-device scheduled notifications. These fire even with no internet,
/// which is essential in Lebanon — FCM (server push) is layered on top for
/// announcements and cross-device delivery (see [registerFcm]).
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _channel = AndroidNotificationChannel(
    'garagi_reminders',
    'Maintenance reminders',
    description: 'Upcoming services, insurance and Mécanique reminders',
    importance: Importance.high,
  );

  Future<void> init() async {
    if (_ready || kIsWeb) return; // local notifications aren't supported on web
    tzdata.initializeTimeZones();
    // Without this, tz.local defaults to UTC and reminders fire 2–3h off in
    // Lebanon. Anchor to Beirut (the target market).
    try {
      tz.setLocalLocation(tz.getLocation('Asia/Beirut'));
    } catch (_) {}

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings();
    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: ios),
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    _ready = true;
  }

  Future<void> requestPermissions() async {
    if (kIsWeb) return;
    await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Schedule a one-off reminder. [whenLocal] is interpreted in the device's
  /// local timezone. Past dates are silently skipped.
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime whenLocal,
  }) async {
    if (kIsWeb) return;
    await init();
    final when = tz.TZDateTime.from(whenLocal, tz.local);
    if (when.isBefore(tz.TZDateTime.now(tz.local))) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  /// Registers for FCM push (announcements, cross-device). No-op until Firebase
  /// is configured — call after sign-in when `kUseFirebase` is true.
  Future<void> registerFcm() async {
    // Wired in the Firebase layer; see lib/core/firebase. Kept here so callers
    // have a single notifications entry point.
    debugPrint('FCM registration handled by Firebase layer when enabled.');
  }
}
