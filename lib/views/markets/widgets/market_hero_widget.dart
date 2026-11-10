import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/market_tab_model.dart';
import '../providers/market_tab_provider.dart';
import '../theme/market_theme.dart';

/// Vibrant welcome card with one-tap shortcuts.
class MarketHero extends ConsumerWidget {
  const MarketHero({super.key});

  static const _shortcuts = [
    MarketTab.tokens,
    MarketTab.rwas,
    MarketTab.insurance,
    MarketTab.services,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: MarketTab.discover.gradient,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: MarketColors.skyDeep.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40,
            right: -30,
            child: _Circle(150, Colors.white.withValues(alpha: 0.14)),
          ),
          Positioned(
            bottom: -60,
            left: -20,
            child: _Circle(170, Colors.white.withValues(alpha: 0.08)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Buy, protect & grow\nin one place',
                    style: TextStyle(
                        fontSize: 24,
                        height: 1.15,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 8),
                Text(
                  'Tokens, real-world assets, insurance and everyday services.',
                  style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.white.withValues(alpha: 0.92),
                      height: 1.35),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final t in _shortcuts)
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref.read(marketTabProvider.notifier).select(t);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(t.icon, size: 15, color: Colors.white),
                              const SizedBox(width: 6),
                              Text(t.label,
                                  style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white)),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Circle extends StatelessWidget {
  const _Circle(this.size, this.color);
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );
}
