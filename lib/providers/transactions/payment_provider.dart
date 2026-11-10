import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/quick_send/quick_send_model.dart';
import '../../services/wallet_exception.dart';
import '../wallet/wallet_provider.dart';
import 'recent/recent_transaction_provider.dart';
import 'recent/recent_transactions_section_provider.dart';

enum PaymentStatus { idle, loading, success, error }

class PaymentState {
  final PaymentStatus status;
  final String? error;

  const PaymentState({
    this.status = PaymentStatus.idle,
    this.error,
  });

  PaymentState copyWith({PaymentStatus? status, String? error}) => PaymentState(
        status: status ?? this.status,
        error: error,
      );

  bool get isLoading => status == PaymentStatus.loading;
  bool get isSuccess => status == PaymentStatus.success;
}

final paymentProvider =
    StateNotifierProvider.autoDispose<PaymentNotifier, PaymentState>(
  (ref) => PaymentNotifier(ref),
);

class PaymentNotifier extends StateNotifier<PaymentState> {
  final Ref _ref;

  PaymentNotifier(this._ref) : super(const PaymentState());

  WalletService get _walletService => _ref.read(walletServiceProvider);

  void reset() => state = const PaymentState();

  Future<bool> send({
    required QuickSendContact recipient,
    required double amount,
    String? note,
  }) async {
    final recipientUserId = recipient.recipientId;

    if (recipientUserId == null || recipientUserId.trim().isEmpty) {
      state = state.copyWith(
        status: PaymentStatus.error,
        error: 'Invalid recipient. Please try again.',
      );
      return false;
    }

    state = state.copyWith(status: PaymentStatus.loading, error: null);

    try {
      await _walletService.sendMoney(
        recipientUserId: recipientUserId,
        amount: amount,
        note: note,
      );

      //  Invalidate balance so ALL screens reading it refresh immediately
      _ref.invalidate(walletAccountProvider);
      _ref.invalidate(walletBalanceProvider);
      _ref.invalidate(recentTransactionProvider);
      _ref.invalidate(recentTransactionsSectionProvider);

      state = state.copyWith(status: PaymentStatus.success);
      return true;

    } on InsufficientFundsException {
      state = state.copyWith(
        status: PaymentStatus.error,
        error: 'Insufficient funds in your account.',
      );
    } on InvalidAmountException {
      state = state.copyWith(
        status: PaymentStatus.error,
        error: 'Please enter a valid amount.',
      );
    } on WalletException catch (e) {
      state = state.copyWith(
        status: PaymentStatus.error,
        error: e.message,
      );
    } catch (_) {
      state = state.copyWith(
        status: PaymentStatus.error,
        error: 'Something went wrong. Please try again.',
      );
    }
    return false;
  }
}