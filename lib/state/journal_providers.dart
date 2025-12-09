import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/journal_entry.dart';
import '../data/repositories/journal_repository.dart';
import '../supabase_client.dart';
import 'profile_providers.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return JournalRepository(client);
});

final journalEntriesProvider = FutureProvider<List<JournalEntry>>((ref) async {
  final repo = ref.watch(journalRepositoryProvider);
  final profile = await ref.watch(profileProvider.future);
  return repo.getEntries(profile.id);
});
