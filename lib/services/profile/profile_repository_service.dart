import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user/profile/user_profile.dart';
// NOTE: your original import had a doubled ".dart.dart" extension.
// Rename the file to profile_local_cache_service.dart and fix this import.
import 'profile_local_cache_service.dart.dart';
import 'profile_service.dart';

class ProfileRepository {
  static const _bucket = 'profile-pics';

  SupabaseClient get _client => Supabase.instance.client;

  /// Returns the cached profile instantly (if any) and refreshes in the
  /// background, reporting the fresh result through [onRefreshed].
  Future<UserProfile> getProfile(
    String userId, {
    void Function(UserProfile fresh)? onRefreshed,
  }) async {
    final cached = ProfileLocalCache.get(userId);
    if (cached != null) {
      _refreshInBackground(userId, onRefreshed);
      return cached;
    }
    return fetchFresh(userId);
  }

  Future<UserProfile> fetchFresh(String userId) async {
    final fresh = await ProfileService.instance.fetchProfile(userId);
    ProfileLocalCache.set(userId, fresh);
    return fresh;
  }

  Future<void> _refreshInBackground(
    String userId,
    void Function(UserProfile fresh)? onRefreshed,
  ) async {
    try {
      final fresh = await fetchFresh(userId);
      onRefreshed?.call(fresh);
    } catch (_) {
      // Keep showing cached data if the refresh fails.
    }
  }

  /// Uploads the avatar, saves the URL on the profile row, updates the cache,
  /// and returns the updated profile.
  Future<UserProfile> updateAvatar({
    required UserProfile profile,
    required File file,
    required String ext,
    required String contentType,
  }) async {
    final path = '${profile.id}/avatar.$ext';

    await _client.storage.from(_bucket).upload(
          path,
          file,
          fileOptions: FileOptions(upsert: true, contentType: contentType),
        );

    // Cache-bust, since upsert reuses the same URL.
    final url = '${_client.storage.from(_bucket).getPublicUrl(path)}'
        '?t=${DateTime.now().millisecondsSinceEpoch}';

    await _client
        .from('profiles')
        .update({'profile_pic': url}).eq('id', profile.id);

    final updated = profile.copyWith(profilePic: url);
    ProfileLocalCache.set(profile.id, updated);
    return updated;
  }

  void clear() => ProfileLocalCache.clear();
}