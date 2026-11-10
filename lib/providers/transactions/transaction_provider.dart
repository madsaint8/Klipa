import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/transaction_repository.dart';
import '../wallet/wallet_provider.dart';


final transactionRepositoryProvider = Provider((ref) => TransactionRepository());

final transactionsProvider = StreamProvider<List>((ref) {
  final repository = ref.watch(transactionRepositoryProvider);
  final wallet = ref.watch(walletAccountProvider);
  
  return wallet.when(
    data: (w) => repository.watchTransactions(w['id']),
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});