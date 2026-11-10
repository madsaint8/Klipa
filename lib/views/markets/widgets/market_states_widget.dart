import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';

import '../theme/market_theme.dart';
import 'market_button_widget.dart';

/// Pulsing placeholder rows (one controller drives all of them).
class MarketSkeletonRows extends StatefulWidget {
  const MarketSkeletonRows({super.key, this.count = 6, this.padded = true});

  final int count;
  final bool padded;

  @override
  State<MarketSkeletonRows> createState() => _MarketSkeletonRowsState();
}

class _MarketSkeletonRowsState extends State<MarketSkeletonRows>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Widget _bar(double w, double h) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: MarketColors.border,
          borderRadius: BorderRadius.circular(6),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1).animate(_pulse),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: widget.padded ? 16 : 0),
        child: Column(
          children: [
            for (var i = 0; i < widget.count; i++)
              Container(
                height: 84,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                decoration: MarketTheme.card(),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: MarketColors.border,
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [_bar(130, 13), const SizedBox(height: 8), _bar(90, 10)],
                      ),
                    ),
                    _bar(56, 14),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Failure state with retry. Never shows raw exception text.
class MarketError extends StatelessWidget {
  const MarketError({super.key, required this.label, required this.onRetry});

  final String label;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Iconsax.warning_2, size: 44, color: MarketColors.negative),
            const SizedBox(height: 14),
            Text("Couldn't load $label",
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: MarketColors.text)),
            const SizedBox(height: 6),
            const Text('Check your connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: MarketColors.textSub)),
            const SizedBox(height: 18),
            SizedBox(
              width: 180,
              child: MarketButton(
                label: 'Try again',
                icon: Iconsax.refresh,
                onPressed: onRetry,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty state, optionally with tappable suggestions.
class MarketEmpty extends StatelessWidget {
  const MarketEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.suggestions = const [],
    this.onSuggestion,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestion;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: const BoxDecoration(
                  color: MarketColors.skyLight, shape: BoxShape.circle),
              child: Icon(icon, size: 32, color: MarketColors.skyDeep),
            ),
            const SizedBox(height: 16),
            Text(title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: MarketColors.text)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 13, color: MarketColors.textSub, height: 1.4)),
            if (suggestions.isNotEmpty && onSuggestion != null) ...[
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final s in suggestions)
                    ActionChip(
                      label: Text(s),
                      onPressed: () => onSuggestion!(s),
                      backgroundColor: MarketColors.skyLight,
                      side: BorderSide.none,
                      labelStyle: const TextStyle(
                          color: MarketColors.skyDeep,
                          fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
