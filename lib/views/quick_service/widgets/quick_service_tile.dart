import 'package:flutter/material.dart';
import '../models/quick_service_model.dart';
import 'glass_container.dart';
import '../sky_theme.dart';

/// A service tile: glass card, gradient icon badge, single-line label.
class QuickServiceTile extends StatelessWidget {
  const QuickServiceTile({super.key, required this.service});

  final QuickServiceModel service;

  @override
  Widget build(BuildContext context) => GlassActionTile(
        icon: service.icon,
        label: service.label,
        onTap: () => Navigator.pushNamed(context, service.routeName),
      );
}

/// Generic glass tile, also used for the "More" / "Less" controls.
///
/// The icon badge scales with the tile width and the label scales *down* to
/// fit on one line (never wraps), so every tile has the same height on every
/// screen size and text-scale setting.
class GlassActionTile extends StatelessWidget {
  const GlassActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.filled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  /// true = solid sky-blue gradient badge; false = pale glass badge.
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return MediaQuery.withClampedTextScaling(
      maxScaleFactor: 1.2,
      child: GlassContainer(
        borderRadius: 18,
        blur: 12,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        child: LayoutBuilder(
          builder: (context, c) {
            final d = (c.maxWidth * 0.66).clamp(34.0, 48.0);
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: d,
                  height: d,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(d * 0.32),
                    gradient: filled ? SkyTheme.iconGradient : null,
                    color: filled ? null : Colors.white.withValues(alpha: 0.7),
                    boxShadow: filled
                        ? [
                            BoxShadow(
                              color: SkyTheme.sky500.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: d * 0.52,
                    color: filled ? Colors.white : SkyTheme.sky600,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: SkyTheme.ink,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}