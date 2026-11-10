import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../models/bank_card_model.dart';
import '../formatters/card_formatters.dart';
import '../providers/card_holder_provider.dart';
import 'card_surface_widget.dart';

/// Front face (laid out at BankCardTheme.designWidth; scaled by FlipCard).
/// The holder name is read from the logged-in user's profile, live.
class CardFront extends ConsumerWidget {
  const CardFront({super.key, required this.card});

  final BankCard card;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final holder = ref.watch(cardHolderNameProvider);

    return CardSurface(
      kind: card.kind,
      frozen: card.isFrozen,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    holder,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Image.asset(
                  'assets/images/payWave.png',
                  height: 30,
                  errorBuilder: (_, __, ___) => const Icon(
                      Icons.contactless_rounded,
                      color: Colors.white,
                      size: 28),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Image.asset(
              'assets/images/chip.png',
              height: 30,
              errorBuilder: (_, __, ___) => Container(
                width: 42,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE082),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ),
            const Spacer(),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                CardFormatters.maskedNumber(card.last4),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(AppTexts.validThru,
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.7),
                            fontSize: 8,
                            letterSpacing: 1)),
                    Text(card.expiry,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(width: 16),
                _Badge(card.kind == CardKind.virtual
                    ? AppTexts.virtualBadge
                    : AppTexts.debitBadge),
                const Spacer(),
                _BrandLogo(card.brand),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.white.withValues(alpha: 0.5)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 1)),
      );
}

class _BrandLogo extends StatelessWidget {
  const _BrandLogo(this.brand);
  final CardBrand brand;

  @override
  Widget build(BuildContext context) {
    if (brand == CardBrand.visa) {
      return const Text('VISA',
          style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w900));
    }
    return Image.asset(
      'assets/images/Mastercard.png',
      height: 26,
      errorBuilder: (_, __, ___) => const Text('Mastercard',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
    );
  }
}