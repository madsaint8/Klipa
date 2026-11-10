import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/transaction/transaction_model.dart';
import '../datasource/transactions_datasource_provider.dart';


final recentTransactionsSectionProvider =
    AsyncNotifierProvider<RecentTransactionsNotifier, List<TransactionModel>>(
  RecentTransactionsNotifier.new,
);

class RecentTransactionsNotifier extends AsyncNotifier<List<TransactionModel>> {
  @override
  Future<List<TransactionModel>> build() => _fetch();

  Future<List<TransactionModel>> _fetch() =>
      ref.read(transactionsDatasourceProvider).fetchRecentTransactions();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}