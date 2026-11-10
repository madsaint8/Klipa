import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum CardFeedbackType { success, error, info }

/// One-shot message for the UI to show as a snackbar.
@immutable
class CardFeedback {
  const CardFeedback(this.message, this.type);
  final String message;
  final CardFeedbackType type;
}

/// Lets providers report results/errors without knowing about BuildContext.
/// The screen listens and renders them (see card_screen.dart).
class CardFeedbackNotifier extends Notifier<CardFeedback?> {
  @override
  CardFeedback? build() => null;

  // A new instance each time (no ==) so identical messages still re-trigger.
  void success(String m) => state = CardFeedback(m, CardFeedbackType.success);
  void error(String m) => state = CardFeedback(m, CardFeedbackType.error);
  void info(String m) => state = CardFeedback(m, CardFeedbackType.info);
}

final cardFeedbackProvider =
    NotifierProvider.autoDispose<CardFeedbackNotifier, CardFeedback?>(
  CardFeedbackNotifier.new,
);