import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'checkins_providers.dart';
import 'profile_providers.dart';

class BadgeDefinition {
  const BadgeDefinition(this.id, this.label);
  final String id;
  final String label;
}

const badgeCatalog = <BadgeDefinition>[
  BadgeDefinition('first_checkin', 'First check-in'),
  BadgeDefinition('streak_7', '7-day streak'),
  BadgeDefinition('streak_30', '30-day streak'),
];

final badgesProvider = FutureProvider<List<String>>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  return prefs.getStringList('earned_badges') ?? <String>[];
});

final badgeEvaluatorProvider = FutureProvider<List<String>>((ref) async {
  final prefs = ref.watch(sharedPreferencesProvider);
  final earned = prefs.getStringList('earned_badges') ?? <String>[];
  final checkin = await ref.watch(todayCheckinProvider.future);
  final streaks = await ref.watch(streaksProvider.future);
  final toAdd = <String>[];

  if (checkin != null) {
    toAdd.add('first_checkin');
  }
  if ((streaks['current'] ?? 0) >= 7) {
    toAdd.add('streak_7');
  }
  if ((streaks['current'] ?? 0) >= 30) {
    toAdd.add('streak_30');
  }

  final unique = {...earned, ...toAdd}.toList();
  await prefs.setStringList('earned_badges', unique);
  return unique;
});

final profileBadgesProvider = FutureProvider<List<String>>((ref) async {
  await ref.watch(profileProvider.future);
  return ref.watch(badgeEvaluatorProvider.future);
});
