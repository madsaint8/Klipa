import 'dart:developer' as developer;
import 'package:supabase_flutter/supabase_flutter.dart';

// Custom Exceptions
class WalletException implements Exception {
  final String message;
  final String? code;
  final Object? cause;

  const WalletException(this.message, {this.code, this.cause});

  @override
  String toString() =>
      'WalletException(code: $code, message: $message, cause: $cause)';
}

class InsufficientFundsException extends WalletException {
  const InsufficientFundsException()
      : super('Insufficient funds', code: 'INSUFFICIENT_FUNDS');
}

class InvalidAmountException extends WalletException {
  const InvalidAmountException(double amount)
      : super('Invalid amount: $amount', code: 'INVALID_AMOUNT');
}

class UserNotAuthenticatedException extends WalletException {
  const UserNotAuthenticatedException()
      : super('User is not authenticated', code: 'UNAUTHENTICATED');
}

// Wallet Service
class WalletService {
  WalletService({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  static const _tag = 'WalletService';
  static const double _minAmount = 0.01;
  static const double _maxAmount = 100000.00;

  // Auth Helper
  String get _currentUserId {
    final user = _client.auth.currentUser;
    if (user == null) throw const UserNotAuthenticatedException();
    return user.id;
  }

  // Validation
  void _validateAmount(double amount) {
    if (amount < _minAmount ||
        amount > _maxAmount ||
        amount.isNaN ||
        amount.isInfinite) {
      throw InvalidAmountException(amount);
    }
  }

  void _validateRecipient(String recipientId) {
    if (recipientId.trim().isEmpty) {
      throw const WalletException('Recipient ID must not be empty',
          code: 'INVALID_RECIPIENT');
    }
  }

  // Error Mapping
  Never _handleError(Object error, StackTrace stack, String operation) {
    developer.log(
      'WalletService.$operation failed',
      name: _tag,
      error: error,
      stackTrace: stack,
    );

    if (error is WalletException) throw error;

    if (error is PostgrestException) {
      // Log every field so we can see the real Postgres error
      developer.log('PostgrestException details:', name: _tag);
      developer.log('  code: ${error.code}', name: _tag);
      developer.log('  message: ${error.message}', name: _tag);
      developer.log('  details: ${error.details}', name: _tag);
      developer.log('  hint: ${error.hint}', name: _tag);

      if (error.code == 'P0001' ||
          error.message.toLowerCase().contains('insufficient')) {
        throw const InsufficientFundsException();
      }
      if (error.code == 'P0002' ||
          error.message.toLowerCase().contains('wallet not found')) {
        throw const WalletException(
          'Recipient does not have a wallet.',
          code: 'NO_WALLET',
        );
      }
      if (error.message.toLowerCase().contains('self')) {
        throw const WalletException(
          'You cannot send money to yourself.',
          code: 'SELF_TRANSFER',
        );
      }
      throw WalletException(
        // Show the real message in UI during dev
        'DB error: ${error.message} (code: ${error.code})',
        code: error.code,
        cause: error,
      );
    }

    throw WalletException(
      'Unexpected error during $operation: $error',
      code: 'UNKNOWN',
      cause: error,
    );
  }

  // Public API
  /// Returns the current user's wallet balance.
  Future<Map<String, dynamic>> getAccountInfo() async {
  try {
    final userId = _currentUserId;

    final response = await _client
        .from('accounts')
        .select('balance_fiat, full_name, currency, status')
        .eq('user_id', userId)
        .eq('type', 'wallet')
        .eq('status', 'active')
        .single();

    return {
      'balance': (response['balance_fiat'] as num).toDouble(),
      'full_name': response['full_name'] as String? ?? '',
      'currency': response['currency'] as String? ?? 'ZAR',
    };
  } catch (e, s) {
    _handleError(e, s, 'getAccountInfo');
  }
}
  /// Deposits [amount] into the current user's wallet.
  Future<void> deposit(double amount) async {
    try {
      _validateAmount(amount);
      developer.log('Depositing $amount', name: _tag);

      await _client.rpc('deposit', params: {'amount': amount});

      developer.log('Deposit successful: $amount', name: _tag);
    } catch (e, s) {
      _handleError(e, s, 'deposit');
    }
  }

  /// Withdraws [amount] from the current user's wallet.
  Future<void> withdraw(double amount) async {
    try {
      _validateAmount(amount);
      developer.log('Withdrawing $amount', name: _tag);

      await _client.rpc('withdraw', params: {'amount': amount});

      developer.log('Withdrawal successful: $amount', name: _tag);
    } catch (e, s) {
      _handleError(e, s, 'withdraw');
    }
  }

  /// Transfers [amount] to [recipientId].
  /// Transfers [amount] to the user identified by [recipientUserId].
  Future<void> sendMoney({
    required String recipientUserId,
    required double amount,
    String? note,
  }) async {
    try {
      _validateAmount(amount);
      _validateRecipient(recipientUserId);

      final senderId = _currentUserId;
      if (recipientUserId == senderId) {
        throw const WalletException(
          'Cannot send money to yourself',
          code: 'SELF_TRANSFER',
        );
      }

      developer.log('Sending $amount to user $recipientUserId', name: _tag);

      //  Pass recipient's user_id — send_money RPC resolves their wallet
      await _client.rpc('send_money', params: {
        'recipient_user_id': recipientUserId,
        'amount': amount,
        if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
      });

      developer.log('Transfer successful: $amount to $recipientUserId',
          name: _tag);
    } catch (e, s) {
      _handleError(e, s, 'sendMoney');
    }
  }
}
