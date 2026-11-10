import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/bank_card_model.dart';
import 'card_secrets_provider.dart';

/// Physical / Virtual toggle.
class CardKindNotifier extends Notifier<CardKind> {
  @override
  CardKind build() => CardKind.physical;

  void select(CardKind kind) {
    if (kind == state) return;
    state = kind;
    ref.read(cardFlipProvider.notifier).set(false); // always show a front
  }
}

final cardKindProvider =
    NotifierProvider.autoDispose<CardKindNotifier, CardKind>(
  CardKindNotifier.new,
);

/// Which card of the current kind is selected (null = first one).
class SelectedCardIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void select(String id) {
    if (id == state) return;
    state = id;
    ref.read(cardFlipProvider.notifier).set(false);
  }
}

final selectedCardIdProvider =
    NotifierProvider.autoDispose<SelectedCardIdNotifier, String?>(
  SelectedCardIdNotifier.new,
);

/// true = back face showing. Buttons and gestures both drive the card
/// through this single source of truth.
class CardFlipNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void set(bool showBack) {
    if (state == showBack) return;
    state = showBack;
    // Never leave the CVV/number in memory behind a face-down card.
    if (!showBack) ref.read(cardSecretsProvider.notifier).hide();
  }

  void toggle() => set(!state);
}

final cardFlipProvider = NotifierProvider.autoDispose<CardFlipNotifier, bool>(
  CardFlipNotifier.new,
);