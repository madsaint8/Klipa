import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/transaction/transaction_model.dart';
import '../../models/quick_send/quick_send_model.dart';

class TransactionsRemoteDatasource {
  final _supabase = Supabase.instance.client;

  String get _userId {
    final id = _supabase.auth.currentUser?.id;
    if (id == null) throw Exception('Not authenticated');
    return id;
  }

  // ── Used by RecentTransactionsSection ────────────────────────────────────
  Future<List<TransactionModel>> fetchRecentTransactions({
    int limit = 20,
  }) async {
    try {
      final userId = _userId;

      final response = await _supabase
          .from('transactions')
          .select(
            'id, user_id, wallet_id, sender_id, receiver_id, '
            'amount, currency, status, type, transaction_type, '
            'description, created_at, completed_at',
          )
          .eq('user_id', userId) 
          .eq('status', 'completed')
          .order('created_at', ascending: false)
          .limit(limit);

      final transactions = List<Map<String, dynamic>>.from(response as List);
      if (transactions.isEmpty) return [];

      // Collect unique user IDs
      final userIds = <String>{};
      for (final tx in transactions) {
        if (tx['sender_id'] != null) userIds.add(tx['sender_id'] as String);
        if (tx['receiver_id'] != null) userIds.add(tx['receiver_id'] as String);
      }

      // Fetch full_name AND profile_pic
      final usersResponse = await _supabase
          .from('users')
          .select('id, full_name, profile_pic')
          .inFilter('id', userIds.toList());

      // Map id → { full_name, profile_pic }
      final userMap = <String, Map<String, String?>>{};
      for (final u in usersResponse as List) {
        userMap[u['id'] as String] = {
          'full_name': u['full_name'] as String?,
          'profile_pic': u['profile_pic'] as String?,
        };
      }

      return transactions.map((tx) {
        final senderId = tx['sender_id'] as String?;
        final receiverId = tx['receiver_id'] as String?;
        return TransactionModel.fromJson({
          ...tx,
          'sender_name': userMap[senderId]?['full_name'],
          'sender_pic': userMap[senderId]?['profile_pic'],
          'receiver_name': userMap[receiverId]?['full_name'],
          'receiver_pic': userMap[receiverId]?['profile_pic'],
          'current_user_id': userId,
        });
      }).toList();
    } catch (e, stack) {
      debugPrint('❌ fetchRecentTransactions error: $e');
      debugPrint(stack.toString());
      rethrow;
    }
  }

  // ── Used by QuickSendSection ──────────────────────────────────────────────
  Future<List<QuickSendContact>> fetchRecentRecipients({
    int limit = 10,
  }) async {
    final response = await _supabase
        .from('recent_recipients')
        .select()
        .eq('sender_id', _userId)
        .order('last_paid_at', ascending: false)
        .limit(limit);

    return (response as List)
        .map((e) =>
            QuickSendContact.fromRecentRecipient(e as Map<String, dynamic>))
        .toList();
  }
}
