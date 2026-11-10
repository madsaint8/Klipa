import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/quick_send/quick_send_model.dart';
import '../datasource/transactions_datasource_provider.dart';

final recentTransactionProvider =
    AsyncNotifierProvider<RecentRecipientsNotifier, List<QuickSendContact>>(
  RecentRecipientsNotifier.new,
);

class RecentRecipientsNotifier extends AsyncNotifier<List<QuickSendContact>> {
  @override
  Future<List<QuickSendContact>> build() => _fetch();

  Future<List<QuickSendContact>> _fetch() =>
      ref.read(transactionsDatasourceProvider).fetchRecentRecipients();

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(_fetch);
  }
}