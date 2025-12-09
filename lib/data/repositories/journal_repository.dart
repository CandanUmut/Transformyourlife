import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/journal_entry.dart';

class JournalRepository {
  JournalRepository(this._client);

  final SupabaseClient _client;

  Future<List<JournalEntry>> getEntries(String userId) async {
    final response = await _client
        .from('journal_entries')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return response
        .map<JournalEntry>((json) => JournalEntry.fromJson(json))
        .toList();
  }

  Future<JournalEntry> createEntry({
    required String userId,
    String? title,
    String? content,
  }) async {
    final inserted = await _client
        .from('journal_entries')
        .insert({
          'user_id': userId,
          'title': title,
          'content': content,
        })
        .select()
        .single();
    return JournalEntry.fromJson(inserted);
  }

  Future<void> updateEntry(JournalEntry entry) async {
    await _client
        .from('journal_entries')
        .update(entry.toJson())
        .eq('id', entry.id);
  }

  Future<void> deleteEntry(int id) async {
    await _client.from('journal_entries').delete().eq('id', id);
  }
}
