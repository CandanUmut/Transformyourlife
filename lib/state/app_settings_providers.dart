import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/notifications_service.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError();
});

final deviceIdProvider = Provider<String>((ref) {
  throw UnimplementedError();
});

final notificationsServiceProvider = Provider<NotificationsService>((ref) {
  throw UnimplementedError();
});

class AppLocaleNotifier extends StateNotifier<Locale> {
  AppLocaleNotifier(this._prefs) : super(const Locale('en')) {
    final saved = _prefs.getString(_prefsKey);
    if (saved != null) {
      state = Locale(saved);
    }
  }

  final SharedPreferences _prefs;
  static const _prefsKey = 'app_locale';

  void setLocale(Locale locale) {
    state = locale;
    _prefs.setString(_prefsKey, locale.languageCode);
  }
}

final appLocaleProvider = StateNotifierProvider<AppLocaleNotifier, Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AppLocaleNotifier(prefs);
});

final notificationToggleProvider = StateProvider<bool>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getBool('notifications_enabled') ?? false;
});

final reminderTimeProvider = StateProvider<TimeOfDay>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final hour = prefs.getInt('reminder_hour') ?? 21;
  final minute = prefs.getInt('reminder_minute') ?? 0;
  return TimeOfDay(hour: hour, minute: minute);
});
