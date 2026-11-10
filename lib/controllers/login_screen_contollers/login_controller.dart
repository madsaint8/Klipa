import 'package:flutter/material.dart';

class LoginController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Enable Login button only when inputs are valid
  bool get isLoginButtonEnabled =>
      emailController.text.isNotEmpty &&
      passwordController.text.length >= 6;

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
  }
}
