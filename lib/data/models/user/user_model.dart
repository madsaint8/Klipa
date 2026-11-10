class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? profileImage;
  final String? phoneNumber;

  UserModel({
    required this.id,
    required this.phoneNumber,
    required this.fullName,
    required this.email,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      phoneNumber: json['phone_number'],
      fullName: json['full_name'] ?? 'User',
      email: json['email'] ?? '',
      profileImage: json['profile_image'],
    );
  }
}