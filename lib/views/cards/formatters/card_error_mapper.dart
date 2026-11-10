import 'dart:async';
import '../../../config/theme/constants/text_strings.dart';
import '../repository/card_repository.dart';

/// Turns any thrown object into a message that is safe to show the user.
/// Raw exception text (which might contain sensitive data) is never surfaced.
String cardErrorMessage(Object error) {
  if (error is CardRepositoryException) return error.message;
  if (error is TimeoutException) return AppTexts.requestTimedOut;
  return AppTexts.genericError;
}