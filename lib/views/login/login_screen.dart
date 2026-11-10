import 'package:flutter/material.dart';
import '../../controllers/login_screen_contollers/login_controller.dart';
import 'login_features/login_form.dart';

class LoginScreen extends StatelessWidget {
  final LoginController controller;

  const LoginScreen({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: LoginForm(controller: controller),
          ),
        ),
      ),
    );
  }
}
