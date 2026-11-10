/*
    AUTH GATE - Continuously listens for auth state changes.
    ----------------------------------------------------------------------

    Unauthenticated ==> Create Account Screen
    Authenticated   ==> Home Screen
*/

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/routes/bottom_navigation_bar.dart';
import '../../views/account_setup/welcome_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: Supabase.instance.client.auth.onAuthStateChange,
      builder: (context, snapshot) {
        // Show loading indicator while waiting for connection
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Error state
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('Auth error: ${snapshot.error}')),
          );
        }

        // Extract session from the tuple (event, session)
        final authResponse = snapshot.data;
        final session = authResponse?.session;

        if (session != null) {
          return const Main();
        } else {
          return const WelcomeScreen();
        }
      },
    );
  }
}
