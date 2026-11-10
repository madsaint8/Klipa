import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/auth/auth_service.dart';

final authUserProvider = StreamProvider<User?>((ref) {
  final supabase = Supabase.instance.client;
  return supabase.auth.onAuthStateChange.map(
    (event) => event.session?.user,
  );
});

final authServiceProvider = Provider<AuthServices>((ref) {
  return AuthServices();
});

/// Streams Supabase auth changes globally
final authStateProvider = StreamProvider<AuthState>((ref) {
  final service = ref.read(authServiceProvider);
  return service.authStateChanges;
});

/// Current user derived from auth stream
final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (state) => state.session?.user,
    loading: () => null,
    error: (_, __) => null,
  );
});
