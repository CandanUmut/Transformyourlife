import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/models/profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile> getOrCreateProfile(String deviceId) async {
    final response = await _client
        .from('profiles')
        .select()
        .eq('id', deviceId)
        .maybeSingle();

    if (response != null) {
      return Profile.fromJson(response);
    }

    final newProfile = Profile(id: deviceId, paths: const []);
    final inserted = await _client.from('profiles').insert(newProfile.toJson())
        .select()
        .single();
    return Profile.fromJson(inserted);
  }

  Future<void> updateProfile(Profile profile) async {
    await _client
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }
}
