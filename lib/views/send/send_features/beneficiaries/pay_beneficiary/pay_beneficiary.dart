import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../../../data/models/quick_send/quick_send_model.dart';
import '../../../../../providers/transactions/payment_provider.dart';
import '../../../../../providers/wallet/wallet_provider.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Local providers (scoped to this screen)
// ─────────────────────────────────────────────────────────────────────────────

enum NotificationType { none, sms, email }

final _notificationTypeProvider =
    StateProvider.autoDispose<NotificationType>((_) => NotificationType.none);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class PayBeneficiaryScreen extends ConsumerStatefulWidget {
  final QuickSendContact beneficiary;

  const PayBeneficiaryScreen({super.key, required this.beneficiary});

  @override
  ConsumerState<PayBeneficiaryScreen> createState() =>
      _PayBeneficiaryScreenState();
}

class _PayBeneficiaryScreenState extends ConsumerState<PayBeneficiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _amountFocus = FocusNode();

  static const _primary = Color(0xFF0288D1);
  //static const _darkPrimary = Color(0xFF0277BD);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this)
      ..addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    _amountFocus.dispose();
    super.dispose();
  }

  // Payment processing

  Future<void> _processPayment() async {
    final amountText = _amountController.text.trim();

    if (amountText.isEmpty) {
      _showError('Please enter an amount.');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount.');
      return;
    }

    // Confirm dialog before sending
    final confirmed = await _showConfirmDialog(amount);
    if (!confirmed) return;

    final note = [
      _referenceController.text.trim(),
      _descriptionController.text.trim(),
    ].where((s) => s.isNotEmpty).join(' | ');

    final success = await ref.read(paymentProvider.notifier).send(
          recipient: widget.beneficiary,
          amount: amount,
          note: note.isEmpty ? null : note,
        );

    if (success && mounted) {
      // Refresh balance after successful payment
      //ref.invalidate(walletBalanceProvider);
      _showSuccessAndPop(amount);
    }
  }

  Future<bool> _showConfirmDialog(double amount) async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text(
              'You are about to pay ${widget.beneficiary.name}',
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 3,
                        height: 36,
                        decoration: BoxDecoration(
                          color: _primary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('account',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12)),
                          Text(
                            widget.beneficiary.phone ?? '',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 15),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Amount', style: TextStyle(color: Colors.grey)),
                    Text(
                      'R${amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: _primary),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child:
                    Text('Cancel', style: TextStyle(color: Colors.grey[600])),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Confirm'),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showSuccessAndPop(double amount) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'R${amount.toStringAsFixed(2)} sent to ${widget.beneficiary.name}'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 3),
      ),
    );
    Navigator.pop(context);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ── Delete beneficiary ────────────────────────────────────────────────────

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Beneficiary',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
        content: Text(
            'Remove ${widget.beneficiary.name} from your beneficiaries? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: wire to beneficiariesProvider.remove(widget.beneficiary.id)
              Navigator.pop(context);
            },
            child: const Text('Delete',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheets ─────────────────────────────────────────────────────────

  void _showNotificationSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _NotificationSheet(
        current: ref.read(_notificationTypeProvider),
        onSelect: (type) {
          ref.read(_notificationTypeProvider.notifier).state = type;
          Navigator.pop(context);
        },
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final paymentState = ref.watch(paymentProvider);
    final notificationType = ref.watch(_notificationTypeProvider);
    //final balanceAsync = ref.watch(walletBalanceProvider);

    // Show payment error via snackbar reactively
    ref.listen<PaymentState>(paymentProvider, (_, next) {
      if (next.status == PaymentStatus.error && next.error != null) {
        _showError(next.error!);
      }
    });

    return Scaffold(
      backgroundColor: _primary,
      appBar: AppBar(
        backgroundColor: _primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pay Beneficiary',
          style: TextStyle(
              color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == 'delete') _showDeleteConfirmation();
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text('Delete beneficiary',
                        style: TextStyle(
                            color: Colors.red, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Beneficiary card ─────────────────────────────────────────────
          _BeneficiaryCard(beneficiary: widget.beneficiary),

          // ── Tabs ─────────────────────────────────────────────────────────
          Container(
            color: _primary,
            child: TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              labelStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              tabs: const [Tab(text: 'Payment'), Tab(text: 'History')],
            ),
          ),

          // ── Tab content ──────────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Payment tab ──────────────────────────────────────────
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // From / balance row
                        const _SectionLabel('From'),
                        const SizedBox(height: 8),
                        const _BalanceCard(),
                        const SizedBox(height: 24),

                        // Amount
                        const _SectionLabel('Amount'),
                        const SizedBox(height: 8),
                        _AmountField(controller: _amountController),
                        const SizedBox(height: 8),

                        // Quick amounts
                        _QuickAmounts(onSelect: (v) {
                          _amountController.text = v;
                        }),
                        const SizedBox(height: 24),

                        // Beneficiary reference
                        const _SectionLabel('Beneficiary reference'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _referenceController,
                          hint: 'e.g. Rent, Groceries',
                        ),
                        const SizedBox(height: 24),

                        // My statement description
                        const _SectionLabel('My statement description'),
                        const SizedBox(height: 8),
                        _InputField(
                          controller: _descriptionController,
                          hint: 'Optional note for your records',
                        ),
                        const SizedBox(height: 24),

                        // Payment notification
                        const _SectionLabel('Payment notification'),
                        const SizedBox(height: 8),
                        _NotificationTile(
                          type: notificationType,
                          onTap: _showNotificationSelector,
                        ),

                        // Payment error inline
                        if (paymentState.status == PaymentStatus.error &&
                            paymentState.error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Text(
                              paymentState.error!,
                              style: const TextStyle(
                                  color: Colors.red, fontSize: 13),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // ── History tab ──────────────────────────────────────────
                  const _HistoryTab(),
                ],
              ),
            ),
          ),
        ],
      ),

      // ── Pay Now button ───────────────────────────────────────────────────
      bottomNavigationBar: _tabController.index == 0
          ? _PayNowBar(
              isLoading: paymentState.isLoading,
              onPay: _processPayment,
            )
          : null,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sub-widgets
// ─────────────────────────────────────────────────────────────────────────────

class _BeneficiaryCard extends StatelessWidget {
  final QuickSendContact beneficiary;

  const _BeneficiaryCard({required this.beneficiary});

  String get _initials {
    final parts = beneficiary.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return beneficiary.name.isNotEmpty
        ? beneficiary.name[0].toUpperCase()
        : '?';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0277BD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white24,
            child: ClipOval(
              child: beneficiary.profilePic != null &&
                      beneficiary.profilePic!.isNotEmpty
                  ? Image.network(
                      beneficiary.profilePic!,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _buildDefaultIcon(),
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : _buildDefaultIcon(),
                    )
                  : _buildDefaultIcon(),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(beneficiary.name,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w600)),
                if (beneficiary.phone != null) ...[
                  const SizedBox(height: 4),
                  Text(beneficiary.phone!,
                      style: TextStyle(
                          color: Colors.white.withOpacity(0.75), fontSize: 13)),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('PayWave',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w500)),
                SizedBox(width: 4),
                Icon(Icons.check_circle, color: Colors.greenAccent, size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildDefaultIcon() => const Center(
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: 28,
      ),
    );

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
            fontSize: 15, fontWeight: FontWeight.w600, color: Colors.black87),
      );
}

class _BalanceCard extends ConsumerWidget {
  const _BalanceCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accountAsync = ref.watch(walletAccountProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF0288D1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child:
                const Icon(Icons.call_made, color: Color(0xFF0288D1), size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: accountAsync.when(
              loading: () => const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Main Account',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Loading...',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              error: (_, __) => const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Main Account',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                  SizedBox(height: 4),
                  Text('Could not load balance',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
              data: (info) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info['full_name'] as String? ?? 'Main Account',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  const Text('Available balance',
                      style: TextStyle(fontSize: 13, color: Colors.grey)),
                ],
              ),
            ),
          ),
          // Balance amount
          accountAsync.when(
            loading: () => const SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: Color(0xFF0288D1)),
            ),
            error: (_, __) =>
                const Text('—', style: TextStyle(color: Colors.grey)),
            data: (info) => Text(
              'R${(info['balance'] as double).toStringAsFixed(2)}',
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0288D1)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AmountField extends StatelessWidget {
  final TextEditingController controller;
  const _AmountField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
      ],
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        hintText: '0.00',
        prefixText: 'R  ',
        prefixStyle: const TextStyle(
            fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black54),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _QuickAmounts extends StatelessWidget {
  final ValueChanged<String> onSelect;
  const _QuickAmounts({required this.onSelect});

  @override
  Widget build(BuildContext context) {
    const amounts = ['50', '100', '200', '500'];
    return Row(
      children: amounts
          .map((a) => Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => onSelect(a),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0288D1).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text('R$a',
                            style: const TextStyle(
                                color: Color(0xFF0288D1),
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ),
                    ),
                  ),
                ),
              ))
          .toList(),
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;

  const _InputField({required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationType type;
  final VoidCallback onTap;

  const _NotificationTile({required this.type, required this.onTap});

  IconData get _icon => switch (type) {
        NotificationType.sms => Icons.sms,
        NotificationType.email => Icons.email,
        NotificationType.none => Icons.notifications_off,
      };

  String get _label => switch (type) {
        NotificationType.sms => 'SMS',
        NotificationType.email => 'Email',
        NotificationType.none => 'None',
      };

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(_icon, color: const Color(0xFF0288D1), size: 22),
            const SizedBox(width: 12),
            Expanded(
                child: Text(_label,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w500))),
            Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 14),
          ],
        ),
      ),
    );
  }
}

class _PayNowBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPay;

  const _PayNowBar({required this.isLoading, required this.onPay});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton(
            onPressed: isLoading ? null : onPay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0288D1),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
            child: isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                        strokeWidth: 2.5, color: Colors.white),
                  )
                : const Text('Pay Now',
                    style:
                        TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          ),
        ),
      ),
    );
  }
}

class _HistoryTab extends StatelessWidget {
  const _HistoryTab();

  @override
  Widget build(BuildContext context) {
    // TODO: replace with real transaction history provider
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
          SizedBox(height: 12),
          Text('No transactions yet',
              style: TextStyle(color: Colors.grey, fontSize: 15)),
        ],
      ),
    );
  }
}

class _NotificationSheet extends StatelessWidget {
  final NotificationType current;
  final ValueChanged<NotificationType> onSelect;

  const _NotificationSheet({required this.current, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text('Payment Notification',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 8),
          ...NotificationType.values.map((type) {
            final label = switch (type) {
              NotificationType.none => 'None',
              NotificationType.sms => 'SMS',
              NotificationType.email => 'Email',
            };
            final icon = switch (type) {
              NotificationType.none => Icons.notifications_off,
              NotificationType.sms => Icons.sms,
              NotificationType.email => Icons.email,
            };
            return ListTile(
              leading: Icon(icon, color: const Color(0xFF0288D1)),
              title: Text(label,
                  style: const TextStyle(fontWeight: FontWeight.w500)),
              trailing: current == type
                  ? const Icon(Icons.check_circle, color: Color(0xFF0288D1))
                  : null,
              onTap: () => onSelect(type),
            );
          }),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
