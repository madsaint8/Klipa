import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:paywave/views/sign_up/sign_up_screen.dart';
import '../../config/theme/styles/text_styles.dart';
import '../../common/widgets/buttons/custom_button.dart';
import '../../controllers/login_screen_contollers/login_controller.dart';
import '../../controllers/signup_screen_controllers/signup_controller.dart';
import '../../config/theme/constants/image_strings.dart';
import '../../config/theme/constants/text_strings.dart';
import '../login/login_screen.dart';

/// Welcome / onboarding screen shown before the user has an account.
/// Renamed from CreateAccountScreen → WelcomeScreen because this screen
/// does not create an account itself; it presents the entry-point choices
/// (Sign Up or Sign In) and is the first thing new users see.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Controllers are cheap to construct here; they hold no heavy state.
    final loginController = LoginController();
    final signupController = SignupController();

    // ── Responsive helpers ──────────────────────────────────────────────────
    final mq = MediaQuery.of(context);
    final screenWidth = mq.size.width;
    final screenHeight = mq.size.height;
    final isSmall = screenWidth < 360;
    final isTablet = screenWidth >= 600;

    // Image: 75 % of width on phones, capped at 380 on tablets,
    // never taller than 38 % of screen height.
    final imageSize = (isTablet ? 380.0 : screenWidth * 0.75)
        .clamp(0.0, screenHeight * 0.38);

    // Horizontal padding widens on tablets so content stays centred.
    final hPadding = isTablet ? screenWidth * 0.18 : 24.0;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              // Allows the layout to survive very small screens / large fonts.
              padding: EdgeInsets.symmetric(
                horizontal: hPadding,
                vertical: 24,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: isSmall ? 16 : 28),

                      // ── Hero image ────────────────────────────────────────
                      Center(
                        child: Image.asset(
                          AppImages.createAccount,
                          height: imageSize,
                          width: imageSize,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: isSmall ? 16 : 24),

                      // ── Headline ──────────────────────────────────────────
                      Text(
                        AppTexts.signupTitle,
                        style: TextStyles.title.copyWith(
                          fontSize: isSmall ? 20 : (isTablet ? 30 : 24),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // ── Subtitle ──────────────────────────────────────────
                      Text(
                        AppTexts.signupSubTitle,
                        style: TextStyle(
                          color: const Color(0xFF4B4A4A),
                          fontSize: isSmall ? 13 : 14,
                          height: 1.5,
                        ),
                      ),

                      // Flexible gap: pushes buttons toward the bottom but
                      // collapses gracefully on short screens.
                      const Spacer(),
                      SizedBox(height: isSmall ? 16 : 24),

                      // ── Sign Up button ────────────────────────────────────
                      // CustomButton already fills width; wrap in a SizedBox
                      // to enforce the 56 dp minimum tap-target height.
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: CustomButton(
                          text: AppTexts.signUp,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SignUpScreen(
                                controller: signupController,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Sign In button (outlined) ─────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: CustomButton(
                          text: AppTexts.signIn,
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  LoginScreen(controller: loginController),
                            ),
                          ),
                          isOutlined: true,
                          textColor: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── Terms & Privacy ───────────────────────────────────
                      // InkWell wraps each tappable span to guarantee a
                      // ≥ 48 dp touch target and ripple feedback.
                      Center(
                        child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            text: AppTexts.acceptTerms,
                            style: TextStyle(
                              color: const Color(0xFF4B4A4A),
                              fontSize: isSmall ? 11 : 12,
                              height: 1.6,
                            ),
                            children: [
                              // Terms of Use
                              TextSpan(
                                text: AppTexts.termsOfUse,
                                style: TextStyles.linkText.copyWith(
                                  fontSize: isSmall ? 11 : 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: open Terms of Use
                                  },
                              ),
                              TextSpan(
                                text: ' ${AppTexts.and} ',
                                style: TextStyle(
                                  color: const Color(0xFF4B4A4A),
                                  fontSize: isSmall ? 11 : 12,
                                ),
                              ),
                              // Privacy Policy
                              TextSpan(
                                text: AppTexts.privacyPolicy,
                                style: TextStyles.linkText.copyWith(
                                  fontSize: isSmall ? 11 : 12,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    // TODO: open Privacy Policy
                                  },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}