import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../models/bank_card_model.dart';
import '../formatters/card_formatters.dart';
import '../providers/card_holder_provider.dart';
import '../providers/card_secrets_provider.dart';
import 'card_surface_widget.dart';

/// Back face. Shows the full number + CVV only while the secrets provider
/// holds them for THIS card; otherwise masked placeholders.
class CardBack extends ConsumerWidget {
  const CardBack({super.key, required this.card});

  final BankCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holder = ref.watch(cardHolderNameProvider);
    final secretsAsync = ref.watch(cardSecretsProvider);
    final secrets = secretsAsync.value;
    final revealed = secrets != null && secrets.cardId == card.id;
    final loading = secretsAsync.isLoading;

    final number = revealed
        ? CardFormatters.groupNumber(secrets.number)
        : CardFormatters.maskedNumber(card.last4);
    final cvv = revealed ? secrets.cvv : (loading ? '•••' : '***');

    return CardSurface(
      kind: card.kind,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 22),
          Container(height: 40, color: Colors.black.withValues(alpha: 0.85)),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.white.withValues(alpha: 0.92),
                    child: Text(
                      holder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                          color: Colors.black87),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  width: 56,
                  height: 38,
                  alignment: Alignment.center,
                  color: Colors.white,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Text(
                      cvv,
                      key: ValueKey(cvv),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                          letterSpacing: 1.5,
                          color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              '${AppTexts.signature}  •  ${AppTexts.cvvLabel}',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 9),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 19,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}