import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../notifications/notifications_screen.dart';
import 'app_colors.dart';
import 'asset_categories.dart';
import 'models/portfolio.dart';
import 'providers/asset_category_provider.dart';
import 'providers/chart_provider.dart';
import 'providers/network_provider.dart';
import 'providers/portfolio_provider.dart';
import 'providers/wallet_provider.dart';
import 'widgets/asset_chart_widget.dart';
import 'widgets/asset_list_widget.dart';
import 'widgets/asset_toggle_widget.dart';
import 'widgets/category_asset_list_widget.dart';
import 'widgets/category_toggle_widget.dart';
import 'widgets/portfolio_empty_widget.dart';
import 'widgets/portfolio_error_widget.dart';
import 'widgets/portfolio_header_widget.dart';
import 'widgets/portfolio_loading_widget.dart';

class PortfolioScreen extends ConsumerWidget {
  final String? avatarUrl;
  final bool hasNotification;
  final VoidCallback? onNotificationTap;
  final VoidCallback? onVisibilityToggle;

  const PortfolioScreen({
    super.key,
    this.avatarUrl,
    this.hasNotification = true,
    this.onNotificationTap,
    this.onVisibilityToggle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final portfolioAsync = ref.watch(portfolioProvider);

    // Keeps network state available for future multi-network support.
    ref.watch(networkProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Image.asset(
          'assets/logos/Klipa_text_logo.png',
          width: 130,
          height: 130,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => const Text(
            'KLIPA',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: AppColors.skyDeep,
            ),
          ),
        ),
        actions: [
          _NotificationButton(
            hasNotification: hasNotification,
            onTap: onNotificationTap,
          ),
          const SizedBox(width: 12),
          _ProfileButton(avatarUrl: avatarUrl),
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.skyDeep,
        onRefresh: () async {
          await ref.read(walletProvider.notifier).refreshBalance();
          await ref.read(portfolioProvider.notifier).refresh();
        },
        child: portfolioAsync.when(
          loading: () => const PortfolioLoading(),
          error: (error, _) => PortfolioError(
            error: error,
            onRetry: () {
              ref.read(walletProvider.notifier).reload();
              ref.read(portfolioProvider.notifier).refresh();
            },
          ),
          data: (portfolio) {
            if (portfolio.assets.isEmpty) return const PortfolioEmpty();
            return _PortfolioBody(
              portfolio: portfolio,
              onVisibilityToggle: onVisibilityToggle,
            );
          },
        ),
      ),
    );
  }
}

class _PortfolioBody extends ConsumerWidget {
  final Portfolio portfolio;
  final VoidCallback? onVisibilityToggle;

  const _PortfolioBody({required this.portfolio, this.onVisibilityToggle});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isBar = ref.watch(chartProvider);
    final category = ref.watch(assetCategoryProvider);
    final hideZero = ref.watch(hideZeroProvider);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PortfolioHeader(onVisibilityToggle: onVisibilityToggle),
          const SizedBox(height: 24),

          // Chart card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: AppDecor.card(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      isBar ? 'Assets Trend' : 'Assets Allocation',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const AssetToggle(),
                  ],
                ),
                const SizedBox(height: 16),
                const AssetChart(),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Category toggle (below the chart)
          const CategoryToggle(),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                category.label,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              Row(
                children: [
                  Checkbox(
                    value: hideZero,
                    activeColor: AppColors.skyDeep,
                    visualDensity: VisualDensity.compact,
                    side: const BorderSide(color: AppColors.sky, width: 1.5),
                    onChanged: (_) =>
                        ref.read(hideZeroProvider.notifier).toggle(),
                  ),
                  const Text('Hide 0 Balances',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.textMuted)),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Iconsax.search_favorite_1,
                        color: AppColors.skyDeep),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: category == AssetCategory.tokens
                ? AssetList(key: const ValueKey('tokens'), assets: portfolio.assets)
                : CategoryAssetList(key: ValueKey(category)),
          ),
        ],
      ),
    );
  }
}

class _NotificationButton extends StatelessWidget {
  final bool hasNotification;
  final VoidCallback? onTap;

  const _NotificationButton({required this.hasNotification, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap ??
              () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  ),
          child: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.skyLight,
              shape: BoxShape.circle,
            ),
            child: const Icon(Iconsax.notification, color: AppColors.skyDeep),
          ),
        ),
        if (hasNotification)
          Positioned(
            top: 2,
            right: 2,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: AppColors.negative,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 1.5),
              ),
            ),
          ),
      ],
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String? avatarUrl;
  const _ProfileButton({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.gradient,
        image: avatarUrl != null
            ? DecorationImage(
                image: NetworkImage(avatarUrl!),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: avatarUrl == null
          ? const Icon(Icons.person, color: Colors.white)
          : null,
    );
  }
}