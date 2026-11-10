import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../common/widgets/loading/loading_indicator.dart';
import '../../config/routes/bottom_navigation_bar.dart';
import '../../views/account_setup/welcome_screen.dart';
import '../auth/controllers/auth_controller.dart';


class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Check authentication status when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthController>().checkAuthStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        // Show loading while checking auth status
        if (authController.isCheckingAuth) {
          return const Scaffold(
            body: AppLoadingIndicator(),
          );
        }
        
        // const AuthGate();
        // Navigate based on authentication status
        if (authController.isAuthenticated) {
          return const Main();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
