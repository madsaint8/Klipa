import 'package:flutter/material.dart';
import '../data/models/user/profile/profile_data_model.dart';

class ProfileViewModel with ChangeNotifier {
  final ProfileData _profileData = ProfileData(
    name: 'Mpho Mbele',
    status: 'Software Developer',
    email: 'mmbele@cut.ac.za',
    phoneNumber: '051 507 4382',
    surname: '051 507 4382',
    userId: '051 507 4382',
    userName: '051 507 4382',
  
  );
 
  String get name => _profileData.name;
  String get userName => _profileData.userName;
  String get email => _profileData.email;
  String get status => _profileData.status;
  String get phoneNumber => _profileData.phoneNumber;
  
 
  void updateName(String newUserName) {
    _profileData.userName = newUserName;
    notifyListeners();
  }
 
  void updateRole(String newStatus) {
    _profileData.status = newStatus;
    notifyListeners();
  }
 
  void updateEmail(String newEmail) {
    _profileData.email = newEmail;
    notifyListeners();
  }
 
  void updatePhoneNumber(String newPhoneNumber) {
    _profileData.phoneNumber = newPhoneNumber;
    notifyListeners();
  }
 
  
}