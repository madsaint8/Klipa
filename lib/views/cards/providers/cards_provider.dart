import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../config/theme/constants/text_strings.dart';
import '../formatters/card_error_mapper.dart';
import '../formatters/card_limits.dart';
import '../models/bank_card_model.dart';

import 'card_feedback_provider.dart';
import 'card_repository_provider.dart';
import 'card_ui_provider.dart';

final cardsProvider =
    AsyncNotifierProvider<CardsNotifier, List<BankCard>>(CardsNotifier.new);

class CardsNotifier extends AsyncNotifier<List<BankCard>> {
  /// In-flight operations. Makes double-taps / rapid toggling harmless.
  final Set<String> _pending = <String>{};

  @override
  Future<List<BankCard>> build() => ref
      .read(cardRepositoryProvider)
      .fetchCards()
      .timeout(CardLimits.requestTimeout);

  /// Pull-to-refresh. Failures keep the old data and show a snackbar.
  Future<void> refresh() async {
    ref.invalidateSelf();
    try {
      await future;
    } catch (e) {
      if (ref.mounted) {
        ref.read(cardFeedbackProvider.notifier).error(cardErrorMessage(e));
      }
    }
  }

  /// Optimistic toggle: UI flips instantly, rolls back ONLY that field if the
  /// server rejects it (other concurrent edits are left untouched).
  Future<void> updateSetting(
      String cardId, CardSetting setting, bool value) async {
    final key = '$cardId:${setting.name}';
    if (!_pending.add(key)) return;
    try {
      final cards = state.value;
      final i = cards?.indexWhere((c) => c.id == cardId) ?? -1;
      if (cards == null || i < 0 || setting.read(cards[i]) == value) return;

      _replace(cardId, (c) => setting.apply(c, value));
      try {
        final saved = await ref
            .read(cardRepositoryProvider)
            .updateSetting(cardId, setting, value)
            .timeout(CardLimits.requestTimeout);
        if (!ref.mounted) return;
        // Trust the server's value for this one field only.
        _replace(cardId, (c) => setting.apply(c, setting.read(saved)));
      } catch (e) {
        if (!ref.mounted) return;
        _replace(cardId, (c) => setting.apply(c, !value)); // rollback
        ref.read(cardFeedbackProvider.notifier).error(cardErrorMessage(e));
      }
    } finally {
      _pending.remove(key);
    }
  }

  Future<bool> createVirtualCard({
    required String label,
    required double spendingLimit,
  }) async {
    if (!_pending.add('create')) return false;
    final feedback = ref.read(cardFeedbackProvider.notifier);
    try {
      final current = state.value ?? const <BankCard>[];
      if (current.where((c) => c.kind == CardKind.virtual).length >=
          CardLimits.maxVirtualCards) {
        feedback.error(AppTexts.virtualLimitReached);
        return false;
      }
      final card = await ref
          .read(cardRepositoryProvider)
          .createVirtualCard(label: label.trim(), spendingLimit: spendingLimit)
          .timeout(CardLimits.requestTimeout);
      if (!ref.mounted) return false;
      state = AsyncData([...(state.value ?? current), card]);
      ref.read(cardKindProvider.notifier).select(CardKind.virtual);
      ref.read(selectedCardIdProvider.notifier).select(card.id);
      feedback.success(AppTexts.virtualCardCreated);
      return true;
    } catch (e) {
      if (ref.mounted) feedback.error(cardErrorMessage(e));
      return false;
    } finally {
      _pending.remove('create');
    }
  }

  Future<bool> terminateCard(String cardId) async {
    if (!_pending.add('terminate:$cardId')) return false;
    final feedback = ref.read(cardFeedbackProvider.notifier);
    try {
      await ref
          .read(cardRepositoryProvider)
          .terminateCard(cardId)
          .timeout(CardLimits.requestTimeout);
      if (!ref.mounted) return false;
      ref.read(cardFlipProvider.notifier).set(false);
      state = AsyncData([
        for (final c in state.value ?? const <BankCard>[])
          if (c.id != cardId) c,
      ]);
      feedback.success(AppTexts.cardTerminated);
      return true;
    } catch (e) {
      if (ref.mounted) feedback.error(cardErrorMessage(e));
      return false;
    } finally {
      _pending.remove('terminate:$cardId');
    }
  }

  void _replace(String id, BankCard Function(BankCard) update) {
    final cards = state.value;
    if (cards == null) return;
    state = AsyncData([for (final c in cards) c.id == id ? update(c) : c]);
  }
}

/// Cards of the currently selected kind (Physical / Virtual).
final visibleCardsProvider = Provider.autoDispose<List<BankCard>>((ref) {
  final kind = ref.watch(cardKindProvider);
  final cards = ref.watch(cardsProvider).value ?? const <BankCard>[];
  return cards.where((c) => c.kind == kind).toList(growable: false);
});

/// The card currently on screen. Falls back to the first card if the
/// selection was terminated / belongs to the other kind.
final selectedCardProvider = Provider.autoDispose<BankCard?>((ref) {
  final visible = ref.watch(visibleCardsProvider);
  if (visible.isEmpty) return null;
  final id = ref.watch(selectedCardIdProvider);
  return visible.firstWhere((c) => c.id == id, orElse: () => visible.first);
});