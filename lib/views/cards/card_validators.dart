import '../../config/theme/constants/text_strings.dart';
import 'formatters/card_formatters.dart';
import 'formatters/card_limits.dart';

/// Form validation for the virtual-card sheet.
class CardValidators {
  CardValidators._();

  static String? label(String? value) {
    final v = (value ?? '').trim();
    if (v.isEmpty) return AppTexts.labelRequired;
    if (v.length > CardLimits.maxLabelLength) {
      return AppTexts.labelTooLong;
    }
    return null;
  }

  static double? parseLimit(String? value) =>
      double.tryParse((value ?? '').replaceAll(',', '').trim());

  static String? limit(String? value) {
    final n = parseLimit(value);
    if (n == null || !n.isFinite) return AppTexts.limitInvalid;
    if (n < CardLimits.minSpendingLimit || n > CardLimits.maxSpendingLimit) {
      return 'Enter an amount between '
          '${CardFormatters.amount(CardLimits.minSpendingLimit)} and '
          '${CardFormatters.amount(CardLimits.maxSpendingLimit)}';
    }
    return null;
  }
}