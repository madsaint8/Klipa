import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/common/widgets/transaction/quick_send_contact.dart';
import '../../../config/routes/app_routes.dart';
import '../../../data/models/quick_send/quick_send_model.dart';
import '../../../providers/navigation/navigation_provider.dart';
import '../../../providers/transactions/recent/recent_transaction_provider.dart';
import '../../send/send_features/beneficiaries/pay_beneficiary/pay_beneficiary.dart';

class QuickSendSection extends ConsumerWidget {
  const QuickSendSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contactsAsync = ref.watch(recentTransactionProvider);
    final nav = ref.read(navigationProvider);

    return contactsAsync.when(
      loading: () => const SizedBox(
        height: 100,
        child: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Color(0xFF003366),
          ),
        ),
      ),
      error: (_, __) => const Padding(
        padding: EdgeInsets.symmetric(vertical: 16),
        child: Text(
          'Failed to load contacts',
          style: TextStyle(color: Colors.grey),
        ),
      ),
      data: (beneficiaries) {
        if (beneficiaries.isEmpty) {
          return _EmptyQuickSend(
            onAddTap: () => nav.pushNamed(AppRoutes.addBeneficiary),
          );
        }

        return SizedBox(
          height: 110,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            // +1 for the always-present Add button at index 0
            itemCount: beneficiaries.length + 1,
            itemBuilder: (context, index) {
              // Index 0 is always the Add button
              if (index == 0) {
                return _AddButton(
                  onTap: () => nav.pushNamed(AppRoutes.addBeneficiary),
                );
              }

              // Offset by 1 to account for the Add button
              final beneficiary = beneficiaries[index - 1];
              return buildQuickSendContact(
                beneficiary,
                onTap: () => _handleTap(context, nav, beneficiary),
              );
            },
          ),
        );
      },
    );
  }

  void _handleTap(
      BuildContext context, dynamic nav, QuickSendContact beneficiary) {
    if (beneficiary.isAddButton) {
      nav.pushNamed(AppRoutes.addBeneficiary);
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PayBeneficiaryScreen(beneficiary: beneficiary),
      ),
    );
  }
}

class _EmptyQuickSend extends StatelessWidget {
  final VoidCallback onAddTap;

  const _EmptyQuickSend({required this.onAddTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Row(
        children: [
          // Add button always present
          _AddButton(onTap: onAddTap),
          // Placeholder message
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'No contacts yet ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Add a friend to send money quickly',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AddButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Same 60x60 size as contact avatars
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF003366).withOpacity(0.3),
                  width: 1.5,
                ),
                color: const Color(0xFF003366).withOpacity(0.06),
              ),
              child: const Icon(
                Icons.add,
                color: Color(0xFF003366),
                size: 26,
              ),
            ),
            const SizedBox(height: 6),

            //  Same name label height as contact
            const SizedBox(
              width: 64,
              child: Text(
                'Add',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF003366),
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Same height as the time label so tops align
            const SizedBox(height: 13),
          ],
        ),
      ),
    );
  }
}
