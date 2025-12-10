import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import 'app.dart';
import 'core/config.dart';
import 'state/app_settings_providers.dart';
import 'services/notifications_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final deviceId = await _ensureDeviceId(prefs);
  final notifications = NotificationsService();
  await notifications.initialize();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        deviceIdProvider.overrideWithValue(deviceId),
        notificationsServiceProvider.overrideWithValue(notifications),
      ],
      child: const TransformApp(),
    ),
  );
}

Future<String> _ensureDeviceId(SharedPreferences prefs) async {
  const key = 'device_id';
  final existing = prefs.getString(key);
  if (existing != null && existing.isNotEmpty) {
    return existing;
  }

  final id = const Uuid().v4();
  await prefs.setString(key, id);
  return id;
}
