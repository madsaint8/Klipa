import 'package:flutter/material.dart';
import '../../portfolio/app_colors.dart';

/// Pill button used across the feature. `filled` = sky gradient (primary),
/// otherwise a quiet tinted pill. Passing `onPressed: null` or `loading: true`
/// disables it, so double-taps can't fire an action twice.
class GlassActionButton extends StatelessWidget {
  const GlassActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
    this.filled = true,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final fg = filled ? Colors.white : AppColors.skyDeep;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled || loading ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: filled ? AppColors.gradient : null,
            color: filled ? null : Colors.white.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(26),
            border: filled
                ? null
                : Border.all(color: Colors.white.withValues(alpha: 0.8)),
            boxShadow: filled
                ? [
                    BoxShadow(
                      color: AppColors.skyDeep.withValues(alpha: 0.25),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
            onTap: enabled ? onPressed : null,
            child: Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: loading
                    ? SizedBox(
                        key: const ValueKey('loading'),
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2.2, color: fg),
                      )
                    : Row(
                        key: const ValueKey('label'),
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 20, color: fg),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}