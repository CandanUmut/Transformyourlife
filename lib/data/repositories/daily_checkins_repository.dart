import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/daily_checkin.dart';

class DailyCheckinsRepository {
  DailyCheckinsRepository(this._client);

  final SupabaseClient _client;

  String _formatDate(DateTime date) => date.toIso8601String().split('T').first;

  Future<DailyCheckin?> getCheckinForDate(String userId, DateTime date) async {
    final response = await _client
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .eq('date', _formatDate(date))
        .maybeSingle();
    return response != null ? DailyCheckin.fromJson(response) : null;
  }

  Future<List<DailyCheckin>> getCheckinsInRange(
    String userId, {
    required DateTime from,
    required DateTime to,
  }) async {
    final response = await _client
        .from('daily_checkins')
        .select()
        .eq('user_id', userId)
        .gte('date', _formatDate(from))
        .lte('date', _formatDate(to))
        .order('date', ascending: false);
    return response
        .map<DailyCheckin>((json) => DailyCheckin.fromJson(json))
        .toList();
  }

  Future<DailyCheckin> upsertCheckin(DailyCheckin checkin) async {
    final response = await _client
        .from('daily_checkins')
        .upsert(checkin.toJson())
        .select()
        .single();
    return DailyCheckin.fromJson(response);
  }

  Future<int> getCurrentConsistencyStreak(String userId) async {
    final today = DateTime.now();
    final from = today.subtract(const Duration(days: 60));
    final entries = await getCheckinsInRange(userId, from: from, to: today);
    entries.sort((a, b) => a.date.compareTo(b.date));

    int streak = 0;
    DateTime current = DateTime(today.year, today.month, today.day);
    for (var i = entries.length - 1; i >= 0; i--) {
      final entry = entries[i];
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (entryDate == current) {
        streak++;
        current = current.subtract(const Duration(days: 1));
      } else if (entryDate.isBefore(current)) {
        break;
      }
    }
    return streak;
  }

  Future<int> getLongestConsistencyStreak(String userId) async {
    final today = DateTime.now();
    final from = today.subtract(const Duration(days: 180));
    final entries = await getCheckinsInRange(userId, from: from, to: today);
    entries.sort((a, b) => a.date.compareTo(b.date));

    int longest = 0;
    int currentStreak = 0;
    DateTime? lastDate;

    for (final entry in entries) {
      final entryDate = DateTime(entry.date.year, entry.date.month, entry.date.day);
      if (lastDate == null || entryDate.difference(lastDate!).inDays == 1) {
        currentStreak++;
      } else if (entryDate == lastDate) {
        continue;
      } else {
        longest = currentStreak > longest ? currentStreak : longest;
        currentStreak = 1;
      }
      lastDate = entryDate;
    }

    longest = currentStreak > longest ? currentStreak : longest;
    return longest;
  }
}
