import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/profile/profile_provider.dart';

final authListenerProvider = Provider<void>((ref) {
  final client = Supabase.instance.client;

  client.auth.onAuthStateChange.listen((event) {
    if (event.event == AuthChangeEvent.signedOut ||
        event.event == AuthChangeEvent.userDeleted) {
      ref.invalidate(profileProvider);
    }
  });
});