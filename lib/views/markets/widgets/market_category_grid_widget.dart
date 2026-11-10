import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/market_tab_model.dart';
import '../providers/market_tab_provider.dart';
import '../theme/market_theme.dart';

/// Colourful tiles that jump to a section. Column count adapts to width.
class MarketCategoryGrid extends ConsumerWidget {
  const MarketCategoryGrid({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tabs = MarketTab.catalogTabs;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tabs.length,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 190,
        mainAxisExtent: 88,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, i) {
        final tab = tabs[i];
        return Semantics(
          button: true,
          label: tab.label,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              ref.read(marketTabProvider.notifier).select(tab);
            },
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: tab.gradient,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: tab.accent.withValues(alpha: 0.28),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(tab.icon, color: Colors.white, size: 24),
                  Text(tab.label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
