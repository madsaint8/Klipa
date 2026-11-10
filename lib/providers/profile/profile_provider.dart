import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user/profile/user_profile.dart';
import '../../services/profile/profile_repository_service.dart';
import '../auth/auth_provider.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileProvider =
    AsyncNotifierProvider<ProfileNotifier, UserProfile?>(ProfileNotifier.new);

class ProfileNotifier extends AsyncNotifier<UserProfile?> {
  ProfileRepository get _repo => ref.read(profileRepositoryProvider);

  @override
  Future<UserProfile?> build() async {
    final user = await ref.watch(authUserProvider.future);
    if (user == null) return null;

    var disposed = false;
    ref.onDispose(() => disposed = true);

    return _repo.getProfile(
      user.id,
      onRefreshed: (fresh) {
        if (!disposed) state = AsyncData(fresh);
      },
    );
  }

  /// Manual refresh (e.g. pull-to-refresh or a retry button).
  Future<void> refresh() async {
    final user = await ref.read(authUserProvider.future);
    if (user == null) return;

    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _repo.fetchFresh(user.id));
  }

  /// Instant local update, no refetch needed.
  void updateLocal(UserProfile updated) => state = AsyncData(updated);

  /// Uploads a new avatar. Throws on failure so the UI can show a message.
  Future<void> updateAvatar({
    required File file,
    required String ext,
    required String contentType,
  }) async {
    final current = state.hasValue ? state.requireValue : null;
    if (current == null) return;

    final updated = await _repo.updateAvatar(
      profile: current,
      file: file,
      ext: ext,
      contentType: contentType,
    );
    state = AsyncData(updated);
  }
}

/// Clears profile state when the user signs out.
final authListenerProvider = Provider<void>((ref) {
  final sub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.signedOut ||
        data.event == AuthChangeEvent.userDeleted) {
      ref.read(profileRepositoryProvider).clear();
      ref.invalidate(profileProvider);
    }
  });
  ref.onDispose(sub.cancel);
});