import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/habit.dart';

class HabitsRepository {
  HabitsRepository(this._client);

  final SupabaseClient _client;

  Future<List<Habit>> getHabits(String userId) async {
    final response = await _client
        .from('habits')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response.map<Habit>((json) => Habit.fromJson(json)).toList();
  }

  Future<Habit> createHabit({
    required String userId,
    required String name,
    String? path,
  }) async {
    final payload = {
      'user_id': userId,
      'name': name,
      'path': path,
    };

    final inserted = await _client
        .from('habits')
        .insert(payload)
        .select()
        .single();
    return Habit.fromJson(inserted);
  }

  Future<void> updateHabit(Habit habit) async {
    await _client
        .from('habits')
        .update(habit.toJson())
        .eq('id', habit.id);
  }

  Future<void> archiveHabit(int id) async {
    await _client.from('habits').update({'is_active': false}).eq('id', id);
  }
}
