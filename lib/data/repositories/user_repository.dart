import '../models/user/user_model.dart';

class UserRepository {
  Future<UserModel?> getUser() async {
    try {
      final data = await getUser();
      if (data != null) {
        return UserModel.fromJson(data as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}