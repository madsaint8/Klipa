import 'package:flutter/material.dart';
import '../../../common/widgets/errors/klipa_error_dialog.dart';
import '../../../config/routes/bottom_navigation_bar.dart';
import '../../../controllers/login_screen_contollers/login_controller.dart';
import '../../../core/errors/app_error.dart';
import '../../../services/auth/auth_service.dart';
import '../../../config/theme/constants/text_strings.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.controller});
  final LoginController controller;

  @override
  _LoginFormState createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final authServices = AuthServices();
  bool _passwordVisible = false;
  bool _isLoading = false;

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  Future<void> login() async {
    final email = widget.controller.emailController.text.trim();
    final password = widget.controller.passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      KlipaErrorDialog.showError(
        context: context,
        title: 'Missing Information',
        message: 'Please enter your email and password.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await authServices.login(email: email, password: password);

      if (!mounted) return;

      Navigator.pop(context);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Main()),
      );
    } catch (e) {
      if (!mounted) return;

      if (e is AppError) {
        KlipaErrorDialog.showError(
          context: context,
          title: e.title,
          message: e.message,
        );
      } else {
        KlipaErrorDialog.showError(
          context: context,
          title: 'Unexpected Error',
          message: 'Something went wrong. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ─── BUILD ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    // Responsive helpers
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmall = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    // Image scales proportionally: 80 % of width on phones, capped at 360 on
    // tablets, and never taller than 35 % of the screen height.
    final imageSize =
        (isTablet ? 360.0 : screenWidth * 0.80).clamp(0.0, screenHeight * 0.35);

    // Horizontal padding grows on wider screens
    final hPadding = isTablet ? screenWidth * 0.20 : 24.0;

    // Minimum tap-target height (WCAG / Material guidelines: 48 dp)
    //const double tapTarget = 48.0;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: hPadding,
            vertical: 24,
          ),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: ConstrainedBox(
            // Ensures the column is at least as tall as the viewport so
            // short-content screens do not feel cramped.
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Hero image ──────────────────────────────────────────
                  Center(
                    child: Image.asset(
                      'assets/images/login/Secure_login.gif',
                      height: imageSize,
                      width: imageSize,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: isSmall ? 12 : 20),

                  // ── Headline ─────────────────────────────────────────────
                  Text(
                    AppTexts.loginMessage,
                    style: TextStyle(
                      fontSize: isSmall ? 20 : (isTablet ? 28 : 24),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppTexts.loginOption1,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: isSmall ? 13 : 14,
                    ),
                  ),
                  SizedBox(height: isSmall ? 20 : 28),

                  // ── Email field ──────────────────────────────────────────
                  TextField(
                    controller: widget.controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      hint: 'Email',
                      prefixIcon: Icons.mail_outline,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // ── Password field ───────────────────────────────────────
                  TextField(
                    controller: widget.controller.passwordController,
                    obscureText: !_passwordVisible,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) {
                      if (widget.controller.isLoginButtonEnabled &&
                          !_isLoading) {
                        login();
                      }
                    },
                    onChanged: (_) => setState(() {}),
                    decoration: _inputDecoration(
                      hint: 'Password',
                      prefixIcon: Icons.lock_outline,
                      suffix: _VisibilityToggle(
                        visible: _passwordVisible,
                        // Wrap in a SizedBox that meets the 48 dp tap target
                        onToggle: () => setState(
                            () => _passwordVisible = !_passwordVisible),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Login button ─────────────────────────────────────────
                  // InkWell gives a full-area ripple; the inner button padding
                  // ensures the hit area is always ≥ 48 dp tall regardless of
                  // text size.
                  SizedBox(
                    width: double.infinity,
                    height: 56, // > 48 dp tap target
                    child: ElevatedButton(
                      onPressed: (widget.controller.isLoginButtonEnabled &&
                              !_isLoading)
                          ? login
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: widget.controller.isLoginButtonEnabled
                            ? Colors.blue
                            : Colors.grey[300],
                        disabledBackgroundColor: Colors.grey[300],
                        // Padding ensures text never crowds the edges
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation:
                            widget.controller.isLoginButtonEnabled ? 2 : 0,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              AppTexts.signIn,
                              style: TextStyle(
                                fontSize: isSmall ? 15 : 16,
                                fontWeight: FontWeight.w600,
                                color: widget.controller.isLoginButtonEnabled
                                    ? Colors.white
                                    : Colors.grey[600],
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ── Sign-up row ──────────────────────────────────────────
                  // GestureDetector replaced with InkWell for proper ripple
                  // feedback and a 48 dp tap target via padding.
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Haven't any account? ",
                          style: TextStyle(fontSize: isSmall ? 13 : 14),
                        ),
                        InkWell(
                          onTap: () => Navigator.pushNamed(context, "/signup"),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            // Padding expands the tap area without changing
                            // the visual footprint of the text.
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 4,
                            ),
                            child: Text(
                              "Sign up",
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.w600,
                                fontSize: isSmall ? 13 : 14,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Push content up when keyboard is open
                  const Spacer(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(prefixIcon),
      suffixIcon: suffix,
      // Consistent content padding guarantees ≥ 48 dp height
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade400),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }
}

// ─── VISIBILITY TOGGLE ────────────────────────────────────────────────────────
// Extracted to a widget so it carries its own 48 × 48 dp tap target correctly.
class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({
    required this.visible,
    required this.onToggle,
  });

  final bool visible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      height: 48,
      child: IconButton(
        // padding: zero because the SizedBox already guarantees the target size
        padding: EdgeInsets.zero,
        icon: Icon(
          visible ? Icons.visibility : Icons.visibility_off,
          color: Colors.grey[600],
        ),
        tooltip: visible ? 'Hide password' : 'Show password',
        onPressed: onToggle,
        splashRadius: 24, // Ripple stays within the icon area
      ),
    );
  }
}
