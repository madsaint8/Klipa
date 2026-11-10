import 'package:supabase_flutter/supabase_flutter.dart';

class DepositService {
  static final _supabase = Supabase.instance.client;

  static Future<void> deposit({
    required double amount,
  }) async {
    if (amount <= 0) {
      throw Exception("Invalid deposit amount");
    }

    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception("Not authenticated");

    // Get wallet
    final wallet = await _supabase
        .from('wallets')
        .select()
        .eq('user_id', user.id)
        .single();

    final walletId = wallet['id'];
    final currentBalance = wallet['balance'] ?? 0;

    // Insert transaction
    await _supabase.from('transactions').insert({
      'user_id': user.id,
      'wallet_id': walletId,
      'type': 'deposit',
      'amount': amount,
      'status': 'completed',
    });

    // Update wallet balance
    await _supabase.from('wallets').update({
      'balance': currentBalance + amount,
    }).eq('id', walletId);
  }
}
