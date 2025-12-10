import 'package:flutter/services.dart';

/// Small helper to keep haptic usage consistent and subtle.
class HapticsService {
  const HapticsService._();

  static Future<void> tap() async {
    await HapticFeedback.selectionClick();
  }

  static Future<void> success() async {
    await HapticFeedback.lightImpact();
  }

  static Future<void> gentleWarning() async {
    await HapticFeedback.mediumImpact();
  }
}
