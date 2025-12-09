import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/habit.dart';
import '../data/repositories/habits_repository.dart';
import '../supabase_client.dart';
import 'profile_providers.dart';

final habitsRepositoryProvider = Provider<HabitsRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return HabitsRepository(client);
});

final habitsProvider = FutureProvider<List<Habit>>((ref) async {
  final repo = ref.watch(habitsRepositoryProvider);
  final profile = await ref.watch(profileProvider.future);
  return repo.getHabits(profile.id);
});
