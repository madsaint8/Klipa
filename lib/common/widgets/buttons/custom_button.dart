import 'package:flutter/material.dart';
import '../../../config/theme/colors/app_colors.dart';
import '../../../config/theme/constants/app_sizes.dart';

/// A reusable button that supports filled and outlined variants.
///
/// Improvements over the original:
/// - Tap target is always ≥ 48 dp (WCAG / Material guideline) even when a
///   caller passes a small [height].
/// - [textColor] is correctly honoured on the outlined variant.
/// - An optional [icon] can be placed leading the label.
/// - [isLoading] shows a spinner and disables interaction while async work
///   is in progress.
/// - Font size scales down slightly on very narrow screens so the label
///   never overflows.
/// - The unused [style] parameter has been removed from the constructor
///   signature (it was accepted but silently ignored in the original).
class CustomButton extends StatelessWidget {
  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isOutlined = false,
    this.backgroundColor = AppColors.buttonPrimary,
    this.textColor = Colors.white,
    this.icon,
    this.isLoading = false,
    this.height,
  });

  final String text;

  /// Called when the button is tapped. Pass [null] to disable the button.
  final VoidCallback? onPressed;

  final bool isOutlined;
  final Color backgroundColor;

  /// Label colour.
  /// - Filled variant: defaults to [Colors.white].
  /// - Outlined variant: defaults to [backgroundColor] if not overridden.
  final Color textColor;

  /// Optional leading icon shown before the label.
  final IconData? icon;

  /// When [true] the button shows a [CircularProgressIndicator] and ignores
  /// taps — useful while an async operation is running.
  final bool isLoading;

  /// Override the button height. Falls back to [AppSizes.defaultButtonHeight].
  /// The rendered height is always at least 48 dp.
  final double? height;

  @override
  Widget build(BuildContext context) {
    // Responsive font size: slightly smaller on narrow screens.
    final screenWidth = MediaQuery.of(context).size.width;
    final fontSize = screenWidth < 360 ? 14.0 : 16.0;

    // Effective tap-target height: never below 48 dp.
    final effectiveHeight =
        (height ?? AppSizes.defaultButtonHeight).clamp(48.0, double.infinity);

    // Outlined variant uses backgroundColor as its border/text colour unless
    // the caller has explicitly supplied a textColor other than the default.
    final outlinedTextColor =
        (textColor == Colors.white) ? backgroundColor : textColor;

    // Shared child widget (label ± icon ± spinner).
    Widget buttonChild = isLoading
        ? SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: isOutlined ? outlinedTextColor : textColor,
            ),
          )
        : icon != null
            ? Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: fontSize + 2,
                    color: isOutlined ? outlinedTextColor : textColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    text,
                    style: TextStyle(
                      color: isOutlined ? outlinedTextColor : textColor,
                      fontSize: fontSize,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Text(
                text,
                style: TextStyle(
                  color: isOutlined ? outlinedTextColor : textColor,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
              );

    // Shared shape used by both variants.
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
    );

    return SizedBox(
      width: double.infinity,
      height: effectiveHeight,
      child: isOutlined
          ? OutlinedButton(
              onPressed: isLoading ? null : onPressed,
              style: OutlinedButton.styleFrom(
                shape: shape,
                side: BorderSide(
                  // Dim the border when disabled so the visual state is clear.
                  color: onPressed == null
                      ? Colors.grey.shade400
                      : backgroundColor,
                ),
                // Padding ensures the label never hugs the edges on narrow
                // screens and keeps the interior tap area generous.
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: buttonChild,
            )
          : ElevatedButton(
              onPressed: isLoading ? null : onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: onPressed == null
                    ? Colors.grey.shade300
                    : backgroundColor,
                disabledBackgroundColor: Colors.grey.shade300,
                elevation: onPressed == null ? 0 : 2,
                shape: shape,
                padding: const EdgeInsets.symmetric(horizontal: 24),
              ),
              child: buttonChild,
            ),
    );
  }
}