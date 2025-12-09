import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/models/profile.dart';
import '../data/repositories/profile_repository.dart';
import '../supabase_client.dart';
import 'app_settings_providers.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return ProfileRepository(client);
});

final profileProvider = FutureProvider<Profile>((ref) async {
  final repo = ref.watch(profileRepositoryProvider);
  final deviceId = ref.watch(deviceIdProvider);
  return repo.getOrCreateProfile(deviceId);
});
