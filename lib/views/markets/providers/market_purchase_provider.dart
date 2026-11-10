import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../logic/market_error_mapper.dart';
import '../logic/market_limits.dart';
import '../logic/market_validators.dart';
import '../models/market_item_model.dart';
import 'market_repository_provider.dart';

enum PurchaseStatus { idle, processing, success, failure }

@immutable
class PurchaseState {
  const PurchaseState({
    this.status = PurchaseStatus.idle,
    this.message,
    this.reference,
  });

  final PurchaseStatus status;
  final String? message; // user-safe error text
  final String? reference; // receipt id on success
}

/// Drives the buy sheet. autoDispose: closing the sheet resets everything.
class MarketPurchaseNotifier extends Notifier<PurchaseState> {
  @override
  PurchaseState build() => const PurchaseState();

  Future<void> purchase({
    required MarketItem item,
    required double amount,
    String? planId,
  }) async {
    // Re-entrancy guard: a double tap can never create two orders.
    if (state.status == PurchaseStatus.processing) return;

    final problem = MarketValidators.amount(item, amount);
    if (problem != null && item.plans.isEmpty) {
      state = PurchaseState(status: PurchaseStatus.failure, message: problem);
      return;
    }

    state = const PurchaseState(status: PurchaseStatus.processing);
    try {
      final reference = await ref
          .read(marketCatalogRepositoryProvider)
          .purchase(PurchaseRequest(item: item, amount: amount, planId: planId))
          .timeout(MarketLimits.requestTimeout);
      if (!ref.mounted) return;
      state = PurchaseState(
          status: PurchaseStatus.success, reference: reference);
    } catch (e) {
      if (!ref.mounted) return;
      state = PurchaseState(
          status: PurchaseStatus.failure, message: marketErrorMessage(e));
    }
  }

  void reset() => state = const PurchaseState();
}

final marketPurchaseProvider =
    NotifierProvider.autoDispose<MarketPurchaseNotifier, PurchaseState>(
  MarketPurchaseNotifier.new,
);
