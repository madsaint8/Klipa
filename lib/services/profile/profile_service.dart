import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user/profile/user_profile.dart';

class ProfileService {
  ProfileService._();
  static final instance = ProfileService._();

  final _supabase = Supabase.instance.client;

  Future<UserProfile> fetchProfile(String userId) async {
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('id', userId)
        .single();

    return UserProfile.fromJson(data);
  }
}
