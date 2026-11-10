import 'package:flutter/material.dart';
import '../card_theme.dart';

/// Pulsing placeholder shown while cards load (no extra packages needed).
class CardSkeleton extends StatefulWidget {
  const CardSkeleton({super.key});

  @override
  State<CardSkeleton> createState() => _CardSkeletonState();
}

class _CardSkeletonState extends State<CardSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Widget _block({double? height, double radius = 20, double? aspect}) {
    Widget box = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: SizedBox(width: double.infinity, height: height),
    );
    if (aspect != null) box = AspectRatio(aspectRatio: aspect, child: box);
    return box;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints:
            const BoxConstraints(maxWidth: BankCardTheme.maxContentWidth),
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.45, end: 1).animate(_pulse),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              children: [
                _block(height: 52, radius: 20),
                const SizedBox(height: 24),
                _block(radius: BankCardTheme.radius, aspect: BankCardTheme.aspectRatio),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(child: _block(height: 52, radius: 26)),
                  const SizedBox(width: 12),
                  Expanded(child: _block(height: 52, radius: 26)),
                ]),
                const SizedBox(height: 24),
                _block(height: 220),
              ],
            ),
          ),
        ),
      ),
    );
  }
}