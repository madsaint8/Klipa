import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/market_tab_model.dart';
import '../providers/market_search_provider.dart';
import '../providers/market_sources_provider.dart';
import '../providers/market_tab_provider.dart';
import '../theme/market_theme.dart';

/// Scrollable section chips. The active chip glows in its section's
/// gradient and auto-scrolls into view. While searching, each chip shows how
/// many results it holds, so users see at a glance where matches are.
class MarketTabBar extends ConsumerStatefulWidget {
  const MarketTabBar({super.key});

  @override
  ConsumerState<MarketTabBar> createState() => _MarketTabBarState();
}

class _MarketTabBarState extends ConsumerState<MarketTabBar> {
  final _keys = {for (final t in MarketTab.values) t: GlobalKey()};

  @override
  Widget build(BuildContext context) {
    ref.listen<MarketTab>(marketTabProvider, (_, tab) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final ctx = _keys[tab]?.currentContext;
        if (ctx != null && ctx.mounted) {
          Scrollable.ensureVisible(
            ctx,
            duration: MarketTheme.switchDuration,
            curve: Curves.easeOutCubic,
            alignment: 0.5,
          );
        }
      });
    });

    final selected = ref.watch(marketTabProvider);
    final counts = ref.watch(marketTabCountsProvider);
    final searching =
        ref.watch(marketSearchProvider.select((s) => s.isActive));

    return SizedBox(
      height: 54,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            for (final tab in MarketTab.values)
              Padding(
                key: _keys[tab],
                padding: const EdgeInsets.only(right: 8),
                child: _TabChip(
                  tab: tab,
                  active: tab == selected,
                  count: searching ? counts[tab] : null,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    ref.read(marketTabProvider.notifier).select(tab);
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.tab,
    required this.active,
    required this.count,
    required this.onTap,
  });

  final MarketTab tab;
  final bool active;
  final int? count; // null = not searching
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Colors.white : MarketColors.textSub;
    final dim = count == 0 && !active;

    return Semantics(
      button: true,
      selected: active,
      label: tab.label,
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: dim ? 0.45 : 1,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              gradient: active ? tab.gradient : null,
              color: active ? null : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: active ? null : Border.all(color: MarketColors.border),
              boxShadow: active
                  ? [
                      BoxShadow(
                        color: tab.accent.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              children: [
                Icon(tab.icon, size: 16, color: fg),
                const SizedBox(width: 6),
                Text(tab.label,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: fg)),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withValues(alpha: 0.28)
                          : MarketColors.tag,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text('$count',
                        style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: active ? Colors.white : MarketColors.textSub)),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
