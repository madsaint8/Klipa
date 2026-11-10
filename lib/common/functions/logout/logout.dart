import 'package:flutter/material.dart';
import '../../../services/auth/auth_service.dart';
import '../../../views/account_setup/welcome_screen.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({super.key});

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  bool biometricsEnabled = true;
  bool notificationsEnabled = true;
  bool isLoggingOut = false;

  final authService = AuthServices();

  Future<void> logout() async {
    setState(() => isLoggingOut = true);
    try {
      await authService.logout();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoggingOut = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
