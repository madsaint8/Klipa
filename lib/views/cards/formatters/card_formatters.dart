import '../../../config/theme/constants/text_strings.dart';

// formatting helpers.
class CardFormatters {
  CardFormatters._();

  // Live holder name from the logged-in user's profile.
  static String holderName(String? raw) {
    final cleaned =
        (raw ?? '').trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
    return cleaned.isEmpty ? AppTexts.cardHolderFallback : cleaned;
  }

  static String maskedNumber(String last4) => '•••• •••• •••• $last4';

  // "5358149430341234" -> "5358 1494 3034 1234"
  static String groupNumber(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    final out = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) out.write(' ');
      out.write(digits[i]);
    }
    return out.toString();
  }

  /// 12500 -> "R 12,500"
  static String amount(double value) {
    final s = value.round().toString();
    final grouped =
        s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (_) => ',');
    return 'R $grouped';
  }
}