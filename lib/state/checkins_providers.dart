import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/daily_checkin.dart';
import '../data/repositories/daily_checkins_repository.dart';
import '../supabase_client.dart';
import 'habits_providers.dart';
import 'profile_providers.dart';

final dailyCheckinsRepositoryProvider =
    Provider<DailyCheckinsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return DailyCheckinsRepository(client);
});

final todayCheckinProvider = FutureProvider<DailyCheckin?>((ref) async {
  final repo = ref.watch(dailyCheckinsRepositoryProvider);
  final profile = await ref.watch(profileProvider.future);
  final today = DateTime.now();
  final date = DateTime(today.year, today.month, today.day);
  return repo.getCheckinForDate(profile.id, date);
});

final streaksProvider = FutureProvider<Map<String, int>>((ref) async {
  final repo = ref.watch(dailyCheckinsRepositoryProvider);
  final profile = await ref.watch(profileProvider.future);
  final current = await repo.getCurrentConsistencyStreak(profile.id);
  final best = await repo.getLongestConsistencyStreak(profile.id);
  return {
    'current': current,
    'best': best,
  };
});

final todayHabitCompletionProvider = FutureProvider<double>((ref) async {
  final habits = await ref.watch(habitsProvider.future);
  final checkin = await ref.watch(todayCheckinProvider.future);
  if (habits.isEmpty) return 0;
  final completed = checkin?.completedHabitIds.length ?? 0;
  return completed / habits.length;
});
