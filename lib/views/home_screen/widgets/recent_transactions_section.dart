import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../config/theme/constants/text_strings.dart';
import '../../../providers/transactions/details/transaction_detail_provider.dart';
import '../../../providers/transactions/recent/recent_transactions_section_provider.dart';
import '../../../../common/widgets/transaction/recent_transaction_item.dart';
import '../../transactions/details/transaction_detail_screen.dart';

class RecentTransactionsSection extends ConsumerWidget {
  const RecentTransactionsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactionsAsync = ref.watch(recentTransactionsSectionProvider);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              AppTexts.recentTransactions,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () => ref
                  .read(recentTransactionsSectionProvider.notifier)
                  .refresh(),
              child:
                  const Text('See All', style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        transactionsAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.blue)),
          ),
          error: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 36),
                const SizedBox(height: 8),
                const Text('Failed to load transactions',
                    style: TextStyle(color: Colors.grey)),
                TextButton(
                  onPressed: () => ref
                      .read(recentTransactionsSectionProvider.notifier)
                      .refresh(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
          data: (transactions) => transactions.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long_outlined,
                          size: 48, color: Colors.grey[300]),
                      const SizedBox(height: 12),
                      Text(
                        'No transactions yet',
                        style: TextStyle(color: Colors.grey[400], fontSize: 15),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: transactions
                      .map((tx) => buildTransactionItem(
                            tx,
                            onTap: () {
                              ref
                                  .read(selectedTransactionProvider.notifier)
                                  .state = tx;
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const TransactionDetailScreen(),
                                ),
                              );
                            },
                          ))
                      .toList(),
                ),
        ),
      ],
    );
  }
}
