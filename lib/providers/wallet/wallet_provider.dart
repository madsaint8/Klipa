import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../services/wallet_exception.dart';

final walletServiceProvider = Provider<WalletService>((_) => WalletService());

/// Ticks every time Supabase's auth state changes (login, logout, token
/// refresh). walletAccountProvider watches this purely so it re-runs on
/// those events instead of caching whatever it got the very first time it
/// was read — which, if that first read happened before the session had
/// finished restoring, would be a permanent UserNotAuthenticatedException.
final _authTickProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

// FutureProvider — re-fetches on login/logout; invalidate manually for a
// plain "pull to refresh".
final walletAccountProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  ref.watch(_authTickProvider);
  return ref.read(walletServiceProvider).getAccountInfo();
});

// Convenience balance-only provider
final walletBalanceProvider = FutureProvider<double>((ref) async {
  final info = await ref.watch(walletAccountProvider.future);
  return info['balance'] as double;
});