import 'package:flutter/material.dart';
import 'package:paywave/services/wallet/wallet_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/errors/app_error.dart';
import '../../core/errors/error_mapper.dart';

class AuthServices {
  final SupabaseClient _supabase = Supabase.instance.client;
  final supabase = Supabase.instance.client;
  final wallet = WalletService.instance;

  //======================
  // Sign up method
  //======================
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final walletData = await wallet.createWallet();

      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'address': walletData['address'],
          'privateKey': walletData['privateKey'],
        },
      );

      return response.user != null;
    } catch (e) {
      debugPrint('Sign up error: $e');
      rethrow;
    }
  }

  // Get current user email
  String? getCurrentUserEmail() {
    try {
      final user = _supabase.auth.currentUser;
      return user?.email;
    } catch (error) {
      debugPrint('Get email error: $error');
      return null;
    }
  }

  //====================================
  // Check if user is logged in
  //====================================
  Future<bool> isUserLoggedIn() async {
    try {
      final session = _supabase.auth.currentSession;
      final user = _supabase.auth.currentUser;

      if (session != null && user != null) {
        final now = DateTime.now();
        final expiresAt = session.expiresAt;

        if (expiresAt != null &&
            now.isBefore(DateTime.fromMillisecondsSinceEpoch(expiresAt * 1000))) {
          return true;
        }
      }

      return false;
    } catch (e) {
      debugPrint('Check auth status error: $e');
      return false;
    }
  }

  //======================
  // Get current user
  //======================
  User? getCurrentUser() {
    try {
      return _supabase.auth.currentUser;
    } catch (e) {
      debugPrint('Get current user error: $e');
      return null;
    }
  }

  //======================
  // Login method
  //======================
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      if (email.isEmpty || password.isEmpty) {
        throw const AppError(
          type: AppErrorType.validation,
          title: 'Missing Information',
          message: 'Please enter your email and password.',
        );
      }

      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final privateKey = response.user!.userMetadata?['privateKey'];

        if (privateKey != null) {
          await wallet.importWallet(privateKey);
        }

        return true;
      }

      return false;
    } catch (e) {
      throw ErrorMapper.map(e);
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await wallet.logout();
      await supabase.auth.signOut();
    } catch (e) {
      debugPrint('Logout error: $e');
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      debugPrint('Reset password error: $e');
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    String? name,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (metadata != null) updates.addAll(metadata);

      await supabase.auth.updateUser(
        UserAttributes(data: updates),
      );
    } catch (e) {
      debugPrint('Update profile error: $e');
      rethrow;
    }
  }

  // Listen to auth state changes
  Stream<AuthState> get authStateChanges {
    return supabase.auth.onAuthStateChange;
  }
}