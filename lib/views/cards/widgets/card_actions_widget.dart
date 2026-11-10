import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../models/bank_card_model.dart';
import '../providers/card_secrets_provider.dart';
import '../providers/card_ui_provider.dart';
import '../providers/cards_provider.dart';
import 'glass_action_button_widget.dart';

/// "Copy card number" + "Show / Hide CVV".
/// UI only: all logic lives in the secrets/flip notifiers.
class CardActions extends ConsumerStatefulWidget {
  const CardActions({super.key, required this.card});

  final BankCard card;

  @override
  ConsumerState<CardActions> createState() => _CardActionsState();
}

class _CardActionsState extends ConsumerState<CardActions> {
  bool _copying = false; // blocks double-taps while the request is running

  Future<void> _copy() async {
    if (_copying) return;
    HapticFeedback.lightImpact();
    setState(() => _copying = true);
    await ref.read(cardSecretsProvider.notifier).copyNumber(widget.card.id);
    if (mounted) setState(() => _copying = false);
  }

  Future<void> _toggleCvv(bool revealed) async {
    HapticFeedback.lightImpact();
    final flip = ref.read(cardFlipProvider.notifier);

    if (revealed) {
      flip.set(false); // also wipes the secrets
      return;
    }
    final ok =
        await ref.read(cardSecretsProvider.notifier).reveal(widget.card.id);
    // Only flip if the user is still looking at the same card.
    if (ok && mounted && ref.read(selectedCardProvider)?.id == widget.card.id) {
      flip.set(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final secretsAsync = ref.watch(cardSecretsProvider);
    final revealed = secretsAsync.value?.cardId == widget.card.id;

    return Row(
      children: [
        Expanded(
          child: GlassActionButton(
            icon: Iconsax.copy,
            label: AppTexts.copyCardNO,
            loading: _copying,
            onPressed: _copy,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GlassActionButton(
            icon: revealed ? Iconsax.eye_slash : Iconsax.eye,
            label: revealed ? AppTexts.hideCvv : AppTexts.showCvv,
            loading: secretsAsync.isLoading,
            filled: false,
            onPressed: () => _toggleCvv(revealed),
          ),
        ),
      ],
    );
  }
}