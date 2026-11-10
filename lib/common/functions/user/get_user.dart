import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<Map<String, dynamic>?> getUser() async {
  final user = supabase.auth.currentUser;
  if (user == null) return null;

  final results = await Future.wait([
    supabase.from('users').select().eq('id', user.id).single(),
    supabase
        .from('profiles')
        .select('full_name, profile_pic, customer_id, updated_at')
        .eq('id', user.id)
        .maybeSingle(),
  ]);

  final userData = results[0] as Map<String, dynamic>;
  final profileData = results[1];

  return {
    ...userData,
    // profile_pic from profiles takes precedence, fallback to users.profile_pic
    // null if neither exists
    'profile_pic': profileData?['profile_pic'] ?? userData['profile_pic'],
    // full_name from profiles takes precedence
    'full_name': profileData?['full_name'] ?? userData['full_name'],
    'customer_id': profileData?['customer_id'],
  };
}


