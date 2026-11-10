import 'dart:async';
import 'dart:math';
import '../models/bank_card_model.dart';
import '../formatters/card_limits.dart';

/// Thrown by repositories with a message that is safe to show to the user.
class CardRepositoryException implements Exception {
  const CardRepositoryException(this.message);
  final String message;

  @override
  String toString() => 'CardRepositoryException($message)';
}

/// Data-source contract. Swap [MockCardRepository] for your API client by
/// overriding cardRepositoryProvider — no UI or provider code changes.
abstract class CardRepository {
  Future<List<BankCard>> fetchCards();
  Future<BankCard> updateSetting(String cardId, CardSetting setting, bool value);
  Future<BankCard> createVirtualCard({
    required String label,
    required double spendingLimit,
  });
  Future<void> terminateCard(String cardId);

  /// Full number + CVV. Must be served over an authenticated channel and
  /// never cached by the client beyond the reveal window.
  Future<CardSecrets> fetchSecrets(String cardId);
}

/// In-memory implementation for development and tests.
class MockCardRepository implements CardRepository {
  final _random = Random.secure();
  final Map<String, CardSecrets> _secrets = {};

  final List<BankCard> _cards = [
    const BankCard(
      id: 'physical-1',
      kind: CardKind.physical,
      brand: CardBrand.mastercard,
      last4: '1121',
      expiry: '09/28',
      label: 'Debit',
    ),
    const BankCard(
      id: 'virtual-1',
      kind: CardKind.virtual,
      brand: CardBrand.visa,
      last4: '4402',
      expiry: '03/29',
      label: 'Online shopping',
      spendingLimit: 5000,
      tapToPay: false,
    ),
  ];

  Future<void> _latency() =>
      Future<void>.delayed(const Duration(milliseconds: 450));

  String _digits(int n) =>
      List.generate(n, (_) => _random.nextInt(10)).join();

  int _indexOf(String id) {
    final i = _cards.indexWhere((c) => c.id == id);
    if (i < 0) throw const CardRepositoryException('Card not found.');
    return i;
  }

  @override
  Future<List<BankCard>> fetchCards() async {
    await _latency();
    return List.unmodifiable(_cards);
  }

  @override
  Future<BankCard> updateSetting(
      String cardId, CardSetting setting, bool value) async {
    await _latency();
    final i = _indexOf(cardId);
    return _cards[i] = setting.apply(_cards[i], value);
  }

  @override
  Future<BankCard> createVirtualCard({
    required String label,
    required double spendingLimit,
  }) async {
    await _latency();
    if (_cards.where((c) => c.kind == CardKind.virtual).length >=
        CardLimits.maxVirtualCards) {
      throw const CardRepositoryException(
          'You have reached the virtual card limit.');
    }
    final now = DateTime.now();
    final card = BankCard(
      id: 'virtual-${now.microsecondsSinceEpoch}',
      kind: CardKind.virtual,
      brand: CardBrand.visa,
      last4: _digits(4),
      expiry:
          '${now.month.toString().padLeft(2, '0')}/${((now.year + 3) % 100).toString().padLeft(2, '0')}',
      label: label,
      spendingLimit: spendingLimit,
      tapToPay: false,
    );
    _cards.add(card);
    return card;
  }

  @override
  Future<void> terminateCard(String cardId) async {
    await _latency();
    _cards.removeAt(_indexOf(cardId));
    _secrets.remove(cardId);
  }

  @override
  Future<CardSecrets> fetchSecrets(String cardId) async {
    await _latency();
    final card = _cards[_indexOf(cardId)];
    return _secrets.putIfAbsent(
      cardId,
      () => CardSecrets(
        cardId: cardId,
        number: '5412${_digits(8)}${card.last4}',
        cvv: _digits(3),
      ),
    );
  }
}