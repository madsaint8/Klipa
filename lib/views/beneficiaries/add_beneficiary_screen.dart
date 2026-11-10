import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/routes/app_routes.dart';
import '../../config/theme/app_theme.dart';
import '../../providers/navigation/navigation_provider.dart';
import '../send/send_features/beneficiaries/add_beneficiary/add_beneficiary_by_phone_page.dart';

class AddBeneficiaryPage extends ConsumerWidget {
  const AddBeneficiaryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nav = ref.read(navigationProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Add Beneficiary',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // In AddBeneficiaryPage, update the Klipa cellphone card:
            _BeneficiaryCard(
              heroTag: "cellphone",
              title: 'Klipa cellphone',
              subtitle: "Pay to a Klipa user's cellphone",
              icon: Icons.phone_iphone,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AddBeneficiaryByPhonePage(),
                ),
              ),
            ),
            const SizedBox(height: 18),
            _BeneficiaryCard(
              heroTag: "registered",
              title: 'Registered beneficiary',
              subtitle: 'DSTV, Telkom, Mr Price, credit card',
              icon: Icons.receipt_long,
              onTap: () => nav.pushNamed(AppRoutes.registeredBeneficiary),
            ),
            const SizedBox(height: 18),
            _BeneficiaryCard(
              heroTag: "bank",
              title: 'Bank account',
              subtitle: "Enter beneficiary’s bank details",
              icon: Icons.account_balance,
              onTap: () => nav.pushNamed(AppRoutes.bankAccount),
            ),
          ],
        ),
      ),
    );
  }
}

class _BeneficiaryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;
  final String heroTag;

  const _BeneficiaryCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: heroTag,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 6),
                      Text(subtitle,
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade600)),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey.shade400),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
