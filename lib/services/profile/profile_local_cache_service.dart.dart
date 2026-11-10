import '../../data/models/user/profile/user_profile.dart';

class ProfileLocalCache {
  static UserProfile? _profile;
  static String? _userId;

  static UserProfile? get(String userId) {
    if (_userId != userId) return null;
    return _profile;
  }

  static void set(String userId, UserProfile profile) {
    _userId = userId;
    _profile = profile;
  }

  static void clear() {
    _profile = null;
    _userId = null;
  }
}
