import 'package:supabase_flutter/supabase_flutter.dart';

import '../../user/profile/user_profile.dart';

class ProfileService {
  ProfileService._();
  static final ProfileService instance = ProfileService._();

  SupabaseClient get _client => Supabase.instance.client;

  Future<UserProfile> fetchProfile(String userId) async {
    final row = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (row != null) return UserProfile.fromJson(row);

    // Self-heal: the signup trigger may have missed this user.
    final created = await _client
        .from('profiles')
        .upsert({
          'id': userId,
          'customer_id': 'PW-${userId.substring(0, 8).toUpperCase()}',
          'full_name':
              (_client.auth.currentUser?.userMetadata?['full_name'] as String?) ??
                  '',
        })
        .select()
        .single();

    return UserProfile.fromJson(created);
  }
}