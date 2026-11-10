import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'theme/market_theme.dart';
import 'widgets/market_pager_widget.dart';
import 'widgets/market_tab_bar_widget.dart';
import 'widgets/market_top_bar_widget.dart';

/// Marketplace screen. Only layout lives here — search, tabs and data are all
/// driven by Riverpod providers (see providers/).
class MarketsScreen extends StatelessWidget {
  const MarketsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: MarketColors.background,
        body: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFDDF2FF), MarketColors.background],
              stops: [0, 0.35],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                MarketTopBar(),
                MarketTabBar(),
                SizedBox(height: 4),
                Expanded(child: MarketPager()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
