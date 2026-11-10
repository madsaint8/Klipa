import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../config/routes/bottom_navigation_bar.dart';
import '../../services/wallet/wallet_services.dart';

class SignupController {
  final fullNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  /// Wallet PIN: encrypts the private key before it is backed up to Supabase.
  /// It is never sent anywhere and cannot be recovered if forgotten.
  final pinController = TextEditingController();
  final confirmPinController = TextEditingController();

  /// Bind this to your button to prevent double taps / show a spinner.
  final isLoading = ValueNotifier<bool>(false);

  final supabase = Supabase.instance.client;

  /// Keep in sync with the minLength used by the PIN dialog in send_screen.dart.
  static const int minPinLength = 8;

  void dispose() {
    fullNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    pinController.dispose();
    confirmPinController.dispose();
    isLoading.dispose();
  }

  // ---------------------------------------------------------------------------
  // Validation
  // ---------------------------------------------------------------------------

  String? _validate({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
    required String pin,
    required String confirmPin,
  }) {
    if (fullName.isEmpty || email.isEmpty || phone.isEmpty) {
      return 'Please fill in all fields.';
    }
    if (!email.contains('@')) return 'Enter a valid email address.';
    if (password.length < 6) return 'Password must be at least 6 characters.';
    if (password != confirmPassword) return 'Passwords do not match.';
    if (pin.length < minPinLength) {
      return 'Choose a wallet PIN of at least $minPinLength characters.';
    }
    if (pin != confirmPin) return 'Wallet PINs do not match.';
    if (pin == password) {
      return 'Your wallet PIN should be different from your password.';
    }
    return null;
  }

  // ---------------------------------------------------------------------------
  // Sign up
  // ---------------------------------------------------------------------------

  /// [onWalletReady] runs after the wallet is created and saved. Use it to make
  /// the wallet provider reload, e.g.:
  ///
  ///   controller.signUp(context,
  ///       onWalletReady: () => ref.read(walletProvider.notifier).reload());
  Future<void> signUp(
    BuildContext context, {
    Future<void> Function()? onWalletReady,
  }) async {
    if (isLoading.value) return;

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();
    final fullName = fullNameController.text.trim();
    final phone = phoneController.text.trim();
    // Do NOT trim the PIN: it must match exactly what is typed at unlock time.
    final pin = pinController.text;
    final confirmPin = confirmPinController.text;

    final problem = _validate(
      fullName: fullName,
      email: email,
      phone: phone,
      password: password,
      confirmPassword: confirmPassword,
      pin: pin,
      confirmPin: confirmPin,
    );
    if (problem != null) {
      _showError(context, problem);
      return;
    }

    isLoading.value = true;
    final walletService = WalletService.instance;
    var localKeyCreated = false;

    try {
      // 1. Auth user ---------------------------------------------------------
      final AuthResponse res = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
        },
      );

      final user = res.user;
      if (user == null) throw const WalletException('User creation failed.');

      // The wallet backup is protected by row-level security, so it needs a
      // live session. With email confirmation turned on there is none yet.
      if (res.session == null) {
        throw const WalletException(
          'Please confirm your email address, then sign in.',
        );
      }

      // User table 
      await supabase.from('users').insert({
        'id': user.id,
        'email': email,
        'full_name': fullName,
        'phone': phone,
      });


      // Wallet: create key, encrypted cloud backup, public address --------
      final wallet = await walletService.createWallet(); // saves key on device
      localKeyCreated = true;
      final walletAddress = wallet['address'] as String;

      await walletService.backupToCloud(pin); // ciphertext only

      await supabase.from('wallets').insert({
        'user_id': user.id,
        'wallet_address': walletAddress,
        'currency': 'ZAR',
      });

      debugPrint('✔ USER CREATED: ${user.id}');
      debugPrint('✔ WALLET ADDRESS: $walletAddress');
      debugPrint('✔ ENCRYPTED BACKUP SAVED');

      // Let the wallet provider pick up the new wallet --------------------
      if (onWalletReady != null) await onWalletReady();

      if (!context.mounted) return;
      await _showSuccessDialog(context, walletAddress);

      if (!context.mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Main()),
      );
    } catch (e) {
      // Remove stray key on this device if signup didn't finish.
      if (localKeyCreated) {
        try {
          await walletService.discardLocalWallet();
        } catch (_) {}
      }
      if (context.mounted) _showError(context, _errorText(e));
    } finally {
      isLoading.value = false;
    }
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------

  String _errorText(Object e) {
    if (e is AuthException) return e.message;
    if (e is PostgrestException) return e.message;
    if (e is WalletException) return e.message;
    return e.toString();
  }

  Future<void> _showSuccessDialog(
    BuildContext context,
    String walletAddress,
  ) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Account created 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your wallet address:'),
            const SizedBox(height: 8),
            SelectableText(
              walletAddress,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Remember your wallet PIN. It unlocks your wallet on a new '
              'device, and it cannot be reset. If you forget it, your funds '
              'cannot be recovered.',
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }

  void _showError(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}