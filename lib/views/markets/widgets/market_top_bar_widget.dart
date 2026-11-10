import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';

import '../logic/market_limits.dart';
import '../providers/market_search_provider.dart';
import '../theme/market_theme.dart';

/// Title + the global search field. One field searches EVERYTHING; the
/// controller stays in sync if the query is changed elsewhere
/// (suggestion chips, clear buttons).
class MarketTopBar extends ConsumerStatefulWidget {
  const MarketTopBar({super.key});

  @override
  ConsumerState<MarketTopBar> createState() => _MarketTopBarState();
}

class _MarketTopBarState extends ConsumerState<MarketTopBar> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focus.addListener(() {
      if (mounted) setState(() => _focused = _focus.hasFocus);
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String>(marketSearchProvider.select((s) => s.raw), (_, raw) {
      if (_ctrl.text != raw) {
        _ctrl.value = TextEditingValue(
          text: raw,
          selection: TextSelection.collapsed(offset: raw.length),
        );
      }
    });
    final hasText = ref.watch(marketSearchProvider.select((s) => s.raw.isNotEmpty));
    final notifier = ref.read(marketSearchProvider.notifier);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Marketplace',
              style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: MarketColors.text,
                  letterSpacing: -0.5)),
          const SizedBox(height: 2),
          const Text('Buy tokens, assets, cover & services',
              style: TextStyle(fontSize: 13.5, color: MarketColors.textSub)),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: _focused ? MarketColors.skyDeep : MarketColors.border,
                      width: _focused ? 1.6 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: MarketColors.skyDeep
                            .withValues(alpha: _focused ? 0.15 : 0.05),
                        blurRadius: 14,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const SizedBox(width: 14),
                      Icon(Iconsax.search_normal,
                          size: 18,
                          color: _focused
                              ? MarketColors.skyDeep
                              : MarketColors.textMuted),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _ctrl,
                          focusNode: _focus,
                          textInputAction: TextInputAction.search,
                          autocorrect: false,
                          inputFormatters: [
                            LengthLimitingTextInputFormatter(
                                MarketLimits.maxQueryLength),
                          ],
                          style: const TextStyle(
                              fontSize: 15, color: MarketColors.text),
                          decoration: const InputDecoration(
                            hintText: 'Search tokens, gold, insurance, airtime…',
                            hintStyle: TextStyle(
                                color: MarketColors.textMuted, fontSize: 14.5),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: notifier.update,
                          onSubmitted: notifier.submit,
                        ),
                      ),
                      if (hasText)
                        GestureDetector(
                          onTap: notifier.clear,
                          behavior: HitTestBehavior.opaque,
                          child: const Padding(
                            padding: EdgeInsets.all(12),
                            child: Icon(Iconsax.close_circle,
                                size: 18, color: MarketColors.textMuted),
                          ),
                        )
                      else
                        const SizedBox(width: 14),
                    ],
                  ),
                ),
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutCubic,
                child: _focused
                    ? TextButton(
                        onPressed: () => _focus.unfocus(),
                        child: const Text('Cancel',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: MarketColors.skyDeep)),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
