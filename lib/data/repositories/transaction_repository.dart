import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/errors/error_handler.dart';
import '../../data/models/transaction/transaction_model.dart';

class TransactionRepository {
  final supabase = Supabase.instance.client;

  Future sendMoney({
    required String senderWalletId,
    required String receiverWalletId,
    required double amount,
    required String currency,
    String? description,
  }) async {
    try {
      final response = await supabase.rpc('p2p_transfer', params: {
        'p_sender_wallet_id': senderWalletId,
        'p_receiver_wallet_id': receiverWalletId,
        'p_amount': amount,
        'p_currency': currency,
        'p_description': description,
      });

      return response as String;
    } catch (e) {
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }

  Future<List> getTransactions(String walletId) async {
    try {
      final response = await supabase
          .from('transactions')
          .select()
          .or('sender_wallet_id.eq.$walletId,receiver_wallet_id.eq.$walletId')
          .order('created_at', ascending: false)
          .limit(50);

      return (response as List)
          .map((json) => TransactionModel.fromJson(json))
          .toList();
    } catch (e) {
      throw AppException(ErrorHandler.getErrorMessage(e));
    }
  }

  Stream<List> watchTransactions(String walletId) {
    return supabase
        .from('transactions')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => data
            .where((json) =>
                json['sender_wallet_id'] == walletId ||
                json['receiver_wallet_id'] == walletId)
            .map((json) => TransactionModel.fromJson(json))
            .toList());
  }
}
