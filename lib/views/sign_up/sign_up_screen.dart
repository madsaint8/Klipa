import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/common/widgets/text_field/custom_text.dart';
import 'package:paywave/views/login/login_features/country_dropdown.dart';
import 'package:paywave/views/portfolio/providers/wallet_provider.dart';
import '../../common/widgets/buttons/custom_button.dart';
import '../../controllers/signup_screen_controllers/signup_controller.dart';
import '../../config/theme/constants/text_strings.dart';
import 'widgets/input_textfield_widget.dart';
import 'widgets/password_textfield_widget.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key, required this.controller});
  final SignupController controller;

  @override
  ConsumerState<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends ConsumerState<SignUpScreen> {
  bool showPassword = false;
  bool showConfirmPassword = false;
  bool showPin = false;
  bool showConfirmPin = false;

  final FocusNode _phoneFocusNode = FocusNode();

  String selectedCountryCode = '+27';
  String selectedCountryFlag = '🇿🇦';

  SignupController get _c => widget.controller;

  @override
  void initState() {
    super.initState();
    // Rebuild the live "criteria" indicators as the user types.
    _c.passwordController.addListener(_onTextChanged);
    _c.pinController.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _c.passwordController.removeListener(_onTextChanged);
    _c.pinController.removeListener(_onTextChanged);
    _phoneFocusNode.dispose();
    _c.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    await _c.signUp(
      context,
      // Makes the wallet provider reload once the wallet exists.
      onWalletReady: () => ref.read(walletProvider.notifier).reload(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = _c.passwordController.text;
    final pin = _c.pinController.text;

    final hasMinLength = password.length >= 6;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(password);
    final hasLower = RegExp(r'[a-z]').hasMatch(password);
    final pinLongEnough = pin.length >= SignupController.minPinLength;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sign Up',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  width: 500,
                  height: 180,
                  child: Center(
                    child: Image.asset(
                      'assets/images/login/personal-info.png',
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Join us today and unlock a smarter, more secure way to manage your money.',
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 20),

                // Full name
                InputTextField(
                  controller: _c.fullNameController,
                  hintText: 'Full Name',
                  icon: Icons.person_outline,
                ),
                const SizedBox(height: 16),

                // Email
                InputTextField(
                  controller: _c.emailController,
                  hintText: 'myemail@example.com',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),

                // Phone
                Row(
                  children: [
                    CountryDropdown(
                      initialCode: selectedCountryCode,
                      initialFlag: selectedCountryFlag,
                      onCountryChanged: (code, flag) {
                        setState(() {
                          selectedCountryCode = code;
                          selectedCountryFlag = flag;
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: CustomTextField(
                        controller: _c.phoneController,
                        focusNode: _phoneFocusNode,
                        hintText: AppTexts.phoneNo,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Password
                PasswordTextField(
                  controller: _c.passwordController,
                  hintText: 'Password',
                  isVisible: showPassword,
                  toggleVisibility: () =>
                      setState(() => showPassword = !showPassword),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    _criteria('Min 6 characters', hasMinLength),
                    _criteria('Uppercase', hasUpper),
                    _criteria('Lowercase', hasLower),
                  ],
                ),
                const SizedBox(height: 16),

                // Confirm password
                PasswordTextField(
                  controller: _c.confirmPasswordController,
                  hintText: 'Confirm Password',
                  isVisible: showConfirmPassword,
                  toggleVisibility: () => setState(
                      () => showConfirmPassword = !showConfirmPassword),
                ),
                const SizedBox(height: 24),

                // Wallet PIN
                const Text(
                  'Wallet PIN',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline,
                          size: 18, color: Colors.blue),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This PIN encrypts your wallet key so you can restore '
                          'it on a new device. Use something different from your '
                          'password. It cannot be reset, and if you forget it '
                          'your funds cannot be recovered.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                PasswordTextField(
                  controller: _c.pinController,
                  hintText: 'Wallet PIN',
                  isVisible: showPin,
                  toggleVisibility: () => setState(() => showPin = !showPin),
                ),
                const SizedBox(height: 8),
                _criteria(
                  'Min ${SignupController.minPinLength} characters',
                  pinLongEnough,
                ),
                const SizedBox(height: 12),
                PasswordTextField(
                  controller: _c.confirmPinController,
                  hintText: 'Confirm Wallet PIN',
                  isVisible: showConfirmPin,
                  toggleVisibility: () =>
                      setState(() => showConfirmPin = !showConfirmPin),
                ),
                const SizedBox(height: 20),

                // Terms
                Text.rich(
                  TextSpan(
                    text:
                        "By clicking the 'Create Account', you agree to the ",
                    style:
                        TextStyle(color: Colors.grey.shade700, fontSize: 12),
                    children: const [
                      TextSpan(
                        text: 'Terms of Service',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                      TextSpan(text: ' and '),
                      TextSpan(
                        text: 'Privacy Policy',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Create account (spinner while the wallet is being set up)
                ValueListenableBuilder<bool>(
                  valueListenable: _c.isLoading,
                  builder: (_, loading, __) {
                    if (loading) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    return CustomButton(
                      text: AppTexts.createAccount,
                      onPressed: _submit,
                    );
                  },
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _criteria(String label, bool met) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check,
          size: 16,
          color: met ? Colors.blue : Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: met ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 12),
      ],
    );
  }
}


