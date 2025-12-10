import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Minimal local notification wrapper for the daily reminder.
class NotificationsService {
  NotificationsService() : _plugin = FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _plugin.initialize(settings);
  }

  Future<void> scheduleDailyReminder({
    required TimeOfDay time,
    required bool enabled,
    String? body,
  }) async {
    if (!enabled) {
      await _plugin.cancel(_reminderId);
      return;
    }

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        'daily_reminder',
        'Daily reminder',
        channelDescription: 'Gentle daily reminder to check in',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.showDailyAtTime(
      _reminderId,
      'Transform',
      body ?? 'Check in with yourself – today is still open.',
      Time(time.hour, time.minute, 0),
      details,
      androidAllowWhileIdle: true,
    );
  }

  static const _reminderId = 101;
}
