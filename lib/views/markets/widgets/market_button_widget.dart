import 'package:flutter/material.dart';

import '../theme/market_theme.dart';

/// Primary pill button. `onPressed: null` or `loading: true` disables it, so
/// a double tap can't trigger an action twice.
class MarketButton extends StatelessWidget {
  const MarketButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.gradient = MarketColors.gradient,
    this.filled = true,
  });

  final String label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final bool loading;
  final Gradient gradient;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final fg = filled ? Colors.white : MarketColors.skyDeep;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: enabled || loading ? 1 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: Ink(
          height: 52,
          decoration: BoxDecoration(
            gradient: filled ? gradient : null,
            color: filled ? null : MarketColors.skyLight,
            borderRadius: BorderRadius.circular(26),
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
                          if (icon != null) ...[
                            Icon(icon, size: 20, color: fg),
                            const SizedBox(width: 8),
                          ],
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: fg,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
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
