import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/config/theme/colors/app_colors.dart';
import 'package:paywave/views/home_screen/widgets/trending_filter_bottom_sheet.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../../config/theme/constants/app_dimensions.dart';
import '../../../../common/widgets/crypto/crypto_card.dart';
import '../../../providers/crypto/crypto_provider.dart';

//StatefulWidget  ConsumerWidget (Riverpod handles all state) 
class TrendingSection extends ConsumerWidget {
  final String selectedOption;
  final Function(String) onOptionSelected;

  const TrendingSection({
    super.key,
    required this.selectedOption,
    required this.onOptionSelected,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch Riverpod provider instead of local _spotCache map 
    final coinsAsync = ref.watch(trendingCoinsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppTexts.trending,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_horiz),
                onPressed: () {
                  showTrendingFilterBottomSheet(
                    context,
                    selectedOption,       
                    onOptionSelected,
                  );
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingSmall,
          ),
          child: Text(
            selectedOption,               
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 20),

        // ── Changed: replaces the old Container + trendingCoins.map() block ──
        coinsAsync.when(
          // Show skeleton cards while the first load is in progress
          loading: () => _skeletonRow(),

          // Keep showing last good data on error; only show message if empty
          error: (e, _) => Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.paddingSmall,
            ),
            child: Text(
              'Could not load coins. Check your connection.',
              style: TextStyle(color: Colors.red[400], fontSize: 13),
            ),
          ),

          // Coins loaded — build a CryptoCard per coin
          // CryptoCard internally watches chartSpotsProvider + coinColorProvider
          data: (coins) => Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(
                topLeft:
                    Radius.circular(AppDimensions.borderRadiusCircular),
                topRight:
                    Radius.circular(AppDimensions.borderRadiusCircular),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: coins
                      .map((coin) => CryptoCard(
                            key: ValueKey(coin.id),
                            coin: coin,
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Placeholder cards shown while [trendingCoinsProvider] is loading.
  Widget _skeletonRow() => Padding(
        padding: const EdgeInsets.all(2.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(
              3,
              (_) => Container(
                width: 270,
                height: 180,
                margin:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ),
      );
}