import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/transaction_category/transaction_category.dart';
import '../../../providers/transactions/details/transaction_detail_provider.dart';

class TransactionDetailScreen extends ConsumerWidget {
  const TransactionDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tx = ref.watch(selectedTransactionProvider);
    if (tx == null) return const SizedBox.shrink();

    final timeStr = _fullDate(tx.completedAt ?? tx.createdAt);
    final isCredit = tx.isCredit;
    final accentColor = isCredit ? Colors.green : Colors.blue;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Transaction Details',
          style: TextStyle(
              color: Colors.black87,
              fontSize: 17,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Amount card ─────────────────────────────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 32),
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.08),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                    color: accentColor.withOpacity(0.2), width: 1),
              ),
              child: Column(
                children: [
                  // Profile pic
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor.withOpacity(0.15),
                          border: Border.all(
                              color: accentColor.withOpacity(0.3),
                              width: 2),
                        ),
                        child: ClipOval(
                          child: tx.counterpartyPic != null &&
                                  tx.counterpartyPic!.isNotEmpty
                              ? Image.network(
                                  tx.counterpartyPic!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) =>
                                      _personIcon(accentColor),
                                )
                              : _personIcon(accentColor),
                        ),
                      ),
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accentColor,
                          border:
                              Border.all(color: Colors.white, width: 2),
                        ),
                        child: Icon(
                          isCredit
                              ? Icons.arrow_downward
                              : Icons.arrow_upward,
                          color: Colors.white,
                          size: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tx.counterpartyName,
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isCredit ? 'Received' : 'Sent Money',
                    style: TextStyle(
                        color: accentColor,
                        fontSize: 13,
                        fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    tx.formattedAmount,
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.w800,
                      color: isCredit ? Colors.green : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.check_circle,
                            color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          tx.status.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.green,
                              fontSize: 11,
                              fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Details card ────────────────────────────────────────────
            _DetailCard(
              children: [
                _DetailRow(
                  label: 'Date & Time',
                  value: timeStr,
                ),
                _DetailRow(
                  label: 'Transaction ID',
                  value: tx.id,
                  canCopy: true,
                ),
                _DetailRow(
                  label: 'Type',
                  value: tx.category.label,
                ),
                if (tx.description != null && tx.description!.isNotEmpty)
                  _DetailRow(
                    label: 'Description',
                    value: tx.description!,
                  ),
                _DetailRow(
                  label: 'Currency',
                  value: tx.currency,
                ),
                _DetailRow(
                  label: isCredit ? 'From' : 'To',
                  value: tx.counterpartyName,
                  isLast: true,
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _personIcon(Color color) => Center(
        child: Icon(Icons.person, color: color, size: 36),
      );

  String _fullDate(DateTime date) {
    const months = [
      '', 'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month]} ${date.year} at $h:$m';
  }
}

// ── Detail card ────────────────────────────────────────────────────────────────

class _DetailCard extends StatelessWidget {
  final List<Widget> children;
  const _DetailCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(children: children),
      );
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool canCopy;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    this.canCopy = false,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Flexible(
                      child: Text(
                        value,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87),
                        textAlign: TextAlign.right,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (canCopy) ...[
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: value));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Copied to clipboard'),
                              duration: Duration(seconds: 1),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Icon(Icons.copy,
                            size: 14, color: Colors.grey[400]),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(height: 1, color: Colors.grey.shade100, indent: 16),
      ],
    );
  }
}