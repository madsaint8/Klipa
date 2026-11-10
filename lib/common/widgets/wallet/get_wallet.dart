import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

Future<Map<String, dynamic>?> getWallet() async {
  final user = supabase.auth.currentUser;

  if (user == null) {
    return null;
  }

  final wallet = await supabase
      .from('wallets')
      .select(
        'id, user_id, wallet_address, currency, balance, is_active, created_at, updated_at',
      )
      .eq('user_id', user.id)
      .eq('is_active', true)
      .maybeSingle();

  return wallet;
}