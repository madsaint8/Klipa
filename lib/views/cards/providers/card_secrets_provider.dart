import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../models/bank_card_model.dart';
import '../formatters/card_error_mapper.dart';
import 'card_feedback_provider.dart';
import '../formatters/card_limits.dart';
import 'card_repository_provider.dart';

/// Holds the full number + CVV ONLY while revealed.
///   data(null)    -> hidden
///   loading       -> fetching
///   data(secrets) -> visible (auto-hides after [CardLimits.secretsTtl])
///
/// autoDispose: leaving the screen wipes secrets from memory.
class CardSecretsNotifier extends AsyncNotifier<CardSecrets?> {
  Timer? _timer;
  int _epoch = 0; // invalidates in-flight requests when hide() is called

  @override
  FutureOr<CardSecrets?> build() {
    ref.onDispose(() {
      _timer?.cancel();
      _epoch++;
    });
    return null;
  }

  Future<bool> reveal(String cardId) async {
    final epoch = ++_epoch;
    state = const AsyncLoading<CardSecrets?>();
    try {
      final secrets = await ref
          .read(cardRepositoryProvider)
          .fetchSecrets(cardId)
          .timeout(CardLimits.requestTimeout);
      // Ignore stale results (user hid it / left the screen meanwhile).
      if (!ref.mounted || epoch != _epoch) return false;
      state = AsyncData(secrets);
      _timer?.cancel();
      _timer = Timer(CardLimits.secretsTtl, hide);
      return true;
    } catch (e) {
      if (!ref.mounted || epoch != _epoch) return false;
      state = const AsyncData<CardSecrets?>(null);
      ref.read(cardFeedbackProvider.notifier).error(cardErrorMessage(e));
      return false;
    }
  }

  void hide() {
    if (!ref.mounted) return;
    _epoch++;
    _timer?.cancel();
    _timer = null;
    if (state.value != null || state.isLoading) {
      state = const AsyncData<CardSecrets?>(null);
    }
  }

  /// Fetches the number fresh, copies it, and does NOT keep it in state.
  Future<bool> copyNumber(String cardId) async {
    try {
      final secrets = await ref
          .read(cardRepositoryProvider)
          .fetchSecrets(cardId)
          .timeout(CardLimits.requestTimeout);
      await Clipboard.setData(
        ClipboardData(text: secrets.number.replaceAll(' ', '')),
      );
      if (ref.mounted) {
        ref.read(cardFeedbackProvider.notifier).success(AppTexts.cardCopied);
      }
      return true;
    } catch (e) {
      if (ref.mounted) {
        ref.read(cardFeedbackProvider.notifier).error(cardErrorMessage(e));
      }
      return false;
    }
  }
}

final cardSecretsProvider =
    AsyncNotifierProvider.autoDispose<CardSecretsNotifier, CardSecrets?>(
  CardSecretsNotifier.new,
);