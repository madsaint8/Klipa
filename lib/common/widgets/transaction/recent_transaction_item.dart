import 'package:flutter/material.dart';
import '../../../config/theme/colors/app_colors.dart';
import '../../../data/models/transaction/transaction_model.dart';

Widget buildTransactionItem(
  TransactionModel tx, {
  VoidCallback? onTap,
}) {
  final timeLabel = _formatDate(tx.completedAt ?? tx.createdAt);
  final label = tx.isCredit ? 'Received' : 'Sent Money';

  return GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.lightGrey,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: Colors.grey.shade300, width: 1.0),
      ),
      child: Row(
        children: [
          //  Profile pic avatar
          _TransactionAvatar(
            profilePic: tx.counterpartyPic,
            isCredit: tx.isCredit,
          ),
          const SizedBox(width: 14),

          //  Name + category label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.counterpartyName,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  label,
                  style: TextStyle(
                    color: tx.isCredit
                        ? Colors.green.shade600
                        : Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // ── Amount + time ───────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                tx.formattedAmount,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  color: tx.isCredit ? Colors.green : Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                timeLabel,
                style: TextStyle(color: Colors.grey[400], fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}

// ── Avatar with profile pic or default person icon ────────────────────────────

class _TransactionAvatar extends StatelessWidget {
  final String? profilePic;
  final bool isCredit;

  const _TransactionAvatar({this.profilePic, required this.isCredit});

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isCredit ? Colors.green.withOpacity(0.1) : Colors.blue.withOpacity(0.1);
    final iconColor = isCredit ? Colors.green : Colors.blue;

    return Stack(
      children: [
        // ── Circle with pic or icon ─────────────────────────────────
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: bgColor,
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: ClipOval(
            child: profilePic != null && profilePic!.isNotEmpty
                ? Image.network(
                    profilePic!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _defaultIcon(iconColor),
                    loadingBuilder: (_, child, progress) =>
                        progress == null ? child : _defaultIcon(iconColor),
                  )
                : _defaultIcon(iconColor),
          ),
        ),

        // ── Direction badge ─────────────────────────────────────────
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCredit ? Colors.green : Colors.blue,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(
              isCredit ? Icons.arrow_downward : Icons.arrow_upward,
              color: Colors.white,
              size: 10,
            ),
          ),
        ),
      ],
    );
  }

  Widget _defaultIcon(Color color) => Center(
        child: Icon(Icons.person, color: color, size: 26),
      );
}

// ── Date formatter ─────────────────────────────────────────────────────────────

String _formatDate(DateTime date) {
  final diff = DateTime.now().difference(date);
  if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
  if (diff.inHours < 24) return '${diff.inHours}h ago';
  if (diff.inDays == 1) return 'Yesterday';
  if (diff.inDays < 7) return '${diff.inDays}d ago';
  return '${date.day} ${_month(date.month)} ${date.year}';
}

String _month(int m) => const [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ][m];