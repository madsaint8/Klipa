import 'package:flutter/foundation.dart';

/// Physical (plastic) vs virtual (disposable, online-only) cards.
enum CardKind { physical, virtual }

enum CardBrand { mastercard, visa }

enum CardStatus { active, frozen }

/// A card as the UI sees it.
///
/// SECURITY: the full card number and CVV are intentionally NOT part of this
/// model. They are fetched on demand as [CardSecrets] and kept in memory only
/// while revealed (see card_secrets_provider.dart).
@immutable
class BankCard {
  const BankCard({
    required this.id,
    required this.kind,
    required this.brand,
    required this.last4,
    required this.expiry,
    required this.label,
    this.status = CardStatus.active,
    this.onlinePurchases = true,
    this.internationalTransactions = false,
    this.tapToPay = true,
    this.spendingLimit,
  });

  final String id;
  final CardKind kind;
  final CardBrand brand;
  final String last4;
  final String expiry; // MM/YY
  final String label;
  final CardStatus status;
  final bool onlinePurchases;
  final bool internationalTransactions;
  final bool tapToPay;
  final double? spendingLimit; // virtual cards only

  bool get isFrozen => status == CardStatus.frozen;

  BankCard copyWith({
    CardStatus? status,
    bool? onlinePurchases,
    bool? internationalTransactions,
    bool? tapToPay,
    double? spendingLimit,
  }) {
    return BankCard(
      id: id,
      kind: kind,
      brand: brand,
      last4: last4,
      expiry: expiry,
      label: label,
      status: status ?? this.status,
      onlinePurchases: onlinePurchases ?? this.onlinePurchases,
      internationalTransactions:
          internationalTransactions ?? this.internationalTransactions,
      tapToPay: tapToPay ?? this.tapToPay,
      spendingLimit: spendingLimit ?? this.spendingLimit,
    );
  }

  // Value equality keeps Riverpod from rebuilding widgets needlessly.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BankCard &&
          other.id == id &&
          other.kind == kind &&
          other.brand == brand &&
          other.last4 == last4 &&
          other.expiry == expiry &&
          other.label == label &&
          other.status == status &&
          other.onlinePurchases == onlinePurchases &&
          other.internationalTransactions == internationalTransactions &&
          other.tapToPay == tapToPay &&
          other.spendingLimit == spendingLimit;

  @override
  int get hashCode => Object.hash(id, kind, brand, last4, expiry, label,
      status, onlinePurchases, internationalTransactions, tapToPay, spendingLimit);
}

/// Sensitive card data. Short-lived, never logged.
@immutable
class CardSecrets {
  const CardSecrets({
    required this.cardId,
    required this.number,
    required this.cvv,
  });

  final String cardId;
  final String number;
  final String cvv;

  // Redacted so the PAN/CVV can never leak through logs or crash reports.
  @override
  String toString() => 'CardSecrets(redacted)';
}

/// Toggleable settings. Each knows how to read/write itself on a [BankCard],
/// so the notifier can handle all of them with one optimistic-update path.
enum CardSetting {
  onlinePurchases,
  internationalTransactions,
  tapToPay,
  stopCard;

  bool read(BankCard c) => switch (this) {
        CardSetting.onlinePurchases => c.onlinePurchases,
        CardSetting.internationalTransactions => c.internationalTransactions,
        CardSetting.tapToPay => c.tapToPay,
        CardSetting.stopCard => c.isFrozen,
      };

  BankCard apply(BankCard c, bool v) => switch (this) {
        CardSetting.onlinePurchases => c.copyWith(onlinePurchases: v),
        CardSetting.internationalTransactions =>
          c.copyWith(internationalTransactions: v),
        CardSetting.tapToPay => c.copyWith(tapToPay: v),
        CardSetting.stopCard =>
          c.copyWith(status: v ? CardStatus.frozen : CardStatus.active),
      };
}