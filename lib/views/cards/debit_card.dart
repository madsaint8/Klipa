import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/theme/constants/text_strings.dart';
import '../portfolio/app_colors.dart';
import 'widgets/card_actions_widget.dart';
import 'widgets/card_empty_widget.dart';
import 'widgets/card_error_widget.dart';
import 'providers/card_feedback_provider.dart';
import 'widgets/card_kind_toggle_widget.dart';
import 'providers/card_secrets_provider.dart';
import 'widgets/card_selector_widget.dart';
import 'widgets/card_settings_widget.dart';
import 'widgets/card_skeleton_widget.dart';
import 'widgets/card_switcher_widget.dart';
import 'card_theme.dart';
import 'providers/card_ui_provider.dart';
import 'providers/cards_provider.dart';
import 'widgets/flip_card_widget.dart';
import 'widgets/glass_backdrop_widget.dart';


/// Debit / virtual cards screen. Replaces the old `CardPage`.
/// This file only wires providers to widgets — no business logic.
class CardScreen extends ConsumerStatefulWidget {
  const CardScreen({super.key});

  @override
  ConsumerState<CardScreen> createState() => _CardScreenState();
}

class _CardScreenState extends ConsumerState<CardScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Security: when the app is backgrounded (app switcher screenshots!),
  /// turn the card face-up-front and wipe the number/CVV from memory.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) return;
    ref.read(cardSecretsProvider.notifier).hide();
    ref.read(cardFlipProvider.notifier).set(false);
  }

  void _showFeedback(CardFeedback feedback) {
    final color = switch (feedback.type) {
      CardFeedbackType.error => AppColors.negative,
      CardFeedbackType.success => AppColors.positive,
      CardFeedbackType.info => AppColors.skyDeep,
    };
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(feedback.message),
          backgroundColor: color,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<CardFeedback?>(cardFeedbackProvider, (_, next) {
      if (next != null) _showFeedback(next);
    });

    final cardsAsync = ref.watch(cardsProvider);

    // Stale data stays visible during refresh; error only when nothing loaded.
    final Widget body = cardsAsync.hasValue
        ? const _CardContent(key: ValueKey('content'))
        : cardsAsync.hasError
            ? CardError(
                key: const ValueKey('error'),
                onRetry: () => ref.read(cardsProvider.notifier).refresh(),
              )
            : const CardSkeleton(key: ValueKey('loading'));

    return GlassBackdrop(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          title: const Text(
            AppTexts.cardsTitle,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        body: SafeArea(top: false, child: CardSwitcher(child: body)),
      ),
    );
  }
}

class _CardContent extends ConsumerWidget {
  const _CardContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kind = ref.watch(cardKindProvider);
    final card = ref.watch(selectedCardProvider);

    return RefreshIndicator(
      color: AppColors.skyDeep,
      onRefresh: () => ref.read(cardsProvider.notifier).refresh(),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                // Centred + width-capped so tablets/landscape look intentional.
                constraints: const BoxConstraints(
                    maxWidth: BankCardTheme.maxContentWidth),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
                  child: Column(
                    children: [
                      const CardKindToggle(),
                      const SizedBox(height: 24),
                      CardSwitcher(
                        child: card == null
                            ? CardEmpty(key: ValueKey('empty-$kind'), kind: kind)
                            // Keyed by id: fresh flip state for each card.
                            : FlipCard(key: ValueKey(card.id), card: card),
                      ),
                      const SizedBox(height: 16),
                      const CardSelector(),
                      if (card != null) ...[
                        const SizedBox(height: 20),
                        CardActions(key: ValueKey('actions-${card.id}'), card: card),
                        const SizedBox(height: 24),
                        CardSwitcher(
                          child: CardSettings(
                              key: ValueKey('settings-${card.id}'), card: card),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}