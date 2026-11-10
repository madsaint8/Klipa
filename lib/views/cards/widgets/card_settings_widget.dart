import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../models/bank_card_model.dart';
import '../providers/card_feedback_provider.dart';
import '../providers/cards_provider.dart';
import 'glass_container_widget.dart';
import 'section_header_widge.dart';
import 'settings_tile_widget.dart';

/// Manage-card panels. Every switch is bound to the cards notifier
/// (optimistic update + automatic rollback on failure).
class CardSettings extends ConsumerWidget {
  const CardSettings({super.key, required this.card});

  final BankCard card;

  void _toggle(WidgetRef ref, CardSetting setting, bool value) {
    HapticFeedback.selectionClick();
    ref.read(cardsProvider.notifier).updateSetting(card.id, setting, value);
  }

  Future<void> _confirmTerminate(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppTexts.terminateConfirmTitle),
        content: const Text(AppTexts.terminateConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(AppTexts.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(AppTexts.terminate),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(cardsProvider.notifier).terminateCard(card.id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    void comingSoon() =>
        ref.read(cardFeedbackProvider.notifier).info(AppTexts.comingSoon);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: AppTexts.headingTitle),
        _Panel(children: [
          SettingsTile(
            title: AppTexts.onlineTitle,
            subtitle: AppTexts.onlineSubTitle,
            switchValue: card.onlinePurchases,
            onSwitchChanged: (v) =>
                _toggle(ref, CardSetting.onlinePurchases, v),
          ),
          SettingsTile(
            title: AppTexts.internationalTitle,
            subtitle: AppTexts.internationalSubTitle,
            switchValue: card.internationalTransactions,
            onSwitchChanged: (v) =>
                _toggle(ref, CardSetting.internationalTransactions, v),
          ),
          SettingsTile(title: AppTexts.limitsTitle, onTap: comingSoon),
          SettingsTile(title: AppTexts.limitsSubTitle, onTap: comingSoon),
        ]),
        const SizedBox(height: 20),
        const SectionHeader(title: AppTexts.transact),
        _Panel(children: [
          SettingsTile(
            title: AppTexts.tapToPayTitle,
            switchValue: card.tapToPay,
            onSwitchChanged: (v) => _toggle(ref, CardSetting.tapToPay, v),
          ),
          SettingsTile(
            title: AppTexts.stopCard,
            switchValue: card.isFrozen,
            onSwitchChanged: (v) => _toggle(ref, CardSetting.stopCard, v),
          ),
          if (card.kind == CardKind.virtual)
            SettingsTile(
              title: AppTexts.terminateCard,
              isDestructive: true,
              onTap: () => _confirmTerminate(context, ref),
            ),
        ]),
      ],
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Colors.white.withValues(alpha: 0.7),
              ),
            children[i],
          ],
        ],
      ),
    );
  }
}