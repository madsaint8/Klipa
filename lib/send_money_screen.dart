import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

//=============================================
// Models
//=============================================
class Account {
  final String id;
  final String name;
  final double balance;
  final String type;

  Account({
    required this.id,
    required this.name,
    required this.balance,
    required this.type,
  });
}

class Beneficiary {
  final String name;
  final String email;
  final bool selfieVerified;

  Beneficiary({
    required this.name,
    required this.email,
    required this.selfieVerified,
  });
}

class Transaction {
  final double amount;
  final DateTime date;
  final String beneficiary;

  Transaction({
    required this.amount,
    required this.date,
    required this.beneficiary,
  });
}

enum NotificationType { none, sms, email }

//=====================================================
// Providers
//======================================================
final accountsProvider = Provider<List<Account>>((ref) {
  return [
    Account(id: '1', name: 'Main Account', balance: 16.03, type: 'Available balance'),
    Account(id: '2', name: 'Savings Account', balance: 1250.50, type: 'Available balance'),
    Account(id: '3', name: 'Investment Wallet', balance: 5430.75, type: 'Available balance'),
    Account(id: '4', name: 'Emergency Fund', balance: 3200.00, type: 'Available balance'),
  ];
});

final selectedAccountProvider = StateProvider<Account?>((ref) {
  final accounts = ref.watch(accountsProvider);
  return accounts.first;
});

final beneficiaryProvider = Provider<Beneficiary>((ref) {
  return Beneficiary(
    name: 'Sefofane WaPoho',
    email: 'hasefofe@gmail.com',
    selfieVerified: true,
  );
});

final transactionHistoryProvider = Provider<List<Transaction>>((ref) {
  return [
    Transaction(
      amount: 200.00,
      date: DateTime(2025, 12, 16, 20, 10),
      beneficiary: 'Sefofane WaPoho',
    ),
    Transaction(
      amount: 150.00,
      date: DateTime(2025, 12, 10, 14, 30),
      beneficiary: 'Sefofane WaPoho',
    ),
    Transaction(
      amount: 300.00,
      date: DateTime(2025, 12, 5, 10, 15),
      beneficiary: 'Sefofane WaPoho',
    ),
  ];
});

final paymentAmountProvider = StateProvider<String>((ref) => '');
final beneficiaryReferenceProvider = StateProvider<String>((ref) => '');
final statementDescriptionProvider = StateProvider<String>((ref) => '');
final notificationTypeProvider = StateProvider<NotificationType>((ref) => NotificationType.none);

// Main App
void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pay Beneficiary',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      home: const PayBeneficiaryScreen(),
    );
  }
}

// Main Screen
class PayBeneficiaryScreen extends ConsumerStatefulWidget {
  const PayBeneficiaryScreen({super.key});

  @override
  ConsumerState<PayBeneficiaryScreen> createState() => _PayBeneficiaryScreenState();
}

class _PayBeneficiaryScreenState extends ConsumerState<PayBeneficiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _referenceController.text = '';
    _descriptionController.text = '';
  }

  @override
  void dispose() {
    _tabController.dispose();
    _amountController.dispose();
    _referenceController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _showAccountSelector() {
    final accounts = ref.read(accountsProvider);
    
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Select Account',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...accounts.map((account) => InkWell(
              onTap: () {
                ref.read(selectedAccountProvider.notifier).state = account;
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${account.name} selected'),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF0288D1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0288D1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet,
                        color: Color(0xFF0288D1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            account.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            account.type,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'R${account.balance.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0288D1),
                      ),
                    ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showNotificationSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Choose Notification Type',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            ...NotificationType.values.map((type) => InkWell(
              onTap: () {
                ref.read(notificationTypeProvider.notifier).state = type;
                Navigator.pop(context);
                String message = type == NotificationType.none 
                    ? 'No notification selected' 
                    : type == NotificationType.sms 
                        ? 'SMS notification selected' 
                        : 'Email notification selected';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message),
                    duration: const Duration(seconds: 2),
                    backgroundColor: const Color(0xFF0288D1),
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0288D1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        type == NotificationType.none
                            ? Icons.notifications_off
                            : type == NotificationType.sms
                                ? Icons.sms
                                : Icons.email,
                        color: const Color(0xFF0288D1),
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        type == NotificationType.none
                            ? 'None'
                            : type == NotificationType.sms
                                ? 'SMS'
                                : 'Email',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (ref.watch(notificationTypeProvider) == type)
                      const Icon(
                        Icons.check_circle,
                        color: Color(0xFF0288D1),
                        size: 24,
                      ),
                  ],
                ),
              ),
            )),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _processPayment() {
    final amount = _amountController.text;
    final selectedAccount = ref.read(selectedAccountProvider);
    
    if (amount.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter an amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final double? parsedAmount = double.tryParse(amount);
    if (parsedAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (selectedAccount != null && parsedAmount > selectedAccount.balance) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Insufficient funds'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Process payment
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment of R${parsedAmount.toStringAsFixed(2)} processed successfully'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showDeleteConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Beneficiary',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
          content: const Text(
            'Are you sure you want to delete this beneficiary? This action cannot be undone.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Beneficiary deleted successfully'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final beneficiary = ref.watch(beneficiaryProvider);
    final selectedAccount = ref.watch(selectedAccountProvider);
    final transactions = ref.watch(transactionHistoryProvider);
    final notificationType = ref.watch(notificationTypeProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0288D1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0288D1),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Pay Beneficiary',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            offset: const Offset(0, 50),
            onSelected: (value) {
              if (value == 'update') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Update beneficiary selected'),
                    backgroundColor: Color(0xFF0288D1),
                  ),
                );
              } else if (value == 'delete') {
                _showDeleteConfirmation();
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'update',
                child: Row(
                  children: [
                    Icon(Icons.edit, color: Color(0xFF0288D1), size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Update beneficiary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red, size: 20),
                    SizedBox(width: 12),
                    Text(
                      'Delete beneficiary',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Beneficiary Card - Wider Rectangle
          Container(
            margin: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF0277BD),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey[300],
                  child: const Icon(Icons.person, size: 35, color: Colors.grey),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        beneficiary.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        beneficiary.email,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Selfie verified',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 16,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Tabs - Without indicator line
          Container(
            color: const Color(0xFF0288D1),
            child: TabBar(
              controller: _tabController,
              indicator: const BoxDecoration(),
              dividerColor: Colors.transparent,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white.withOpacity(0.6),
              labelStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              tabs: const [
                Tab(text: 'Payment'),
                Tab(text: 'History'),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Payment Tab
                  SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'From',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _showAccountSelector,
                          child: Container(
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
                                  child: const Icon(
                                    Icons.call_made,
                                    color: Color(0xFF0288D1),
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        selectedAccount?.name ?? 'Main Account',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        selectedAccount?.type ?? 'Available balance',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  'R${selectedAccount?.balance.toStringAsFixed(2) ?? '16.03'}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0288D1),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(Icons.more_vert, color: Colors.grey[600]),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Amount',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: 'Enter amount',
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Last Paid: R200.00 on 16 Dec 2025 at 20:10',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Beneficiary reference',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _referenceController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'My statement description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _descriptionController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        const SizedBox(height: 32),
                        const Text(
                          'Payment notification',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        InkWell(
                          onTap: _showNotificationSelector,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  notificationType == NotificationType.none
                                      ? Icons.notifications_off
                                      : notificationType == NotificationType.sms
                                          ? Icons.sms
                                          : Icons.email,
                                  color: const Color(0xFF0288D1),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    notificationType == NotificationType.none
                                        ? 'None'
                                        : notificationType == NotificationType.sms
                                            ? 'SMS'
                                            : 'Email',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                Icon(Icons.arrow_forward_ios, color: Colors.grey[600], size: 16),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 100),
                      ],
                    ),
                  ),
                  // History Tab
                  ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: transactions.length,
                    itemBuilder: (context, index) {
                      final transaction = transactions[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                              child: const Icon(
                                Icons.call_made,
                                color: Color(0xFF0288D1),
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    transaction.beneficiary,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${transaction.date.day} ${_getMonth(transaction.date.month)} ${transaction.date.year} at ${transaction.date.hour.toString().padLeft(2, '0')}:${transaction.date.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'R${transaction.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0288D1),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _tabController.index == 0 
          ? Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: ElevatedButton(
                  onPressed: _processPayment,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0288D1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Pay Now',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            )
          : null,
    );
  }

  String _getMonth(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month - 1];
  }
}





// import 'package:flutter/material.dart';
// class CryptoWalletScreen extends StatefulWidget {
//   const CryptoWalletScreen({Key? key}) : super(key: key);

//   @override
//   State<CryptoWalletScreen> createState() => _CryptoWalletScreenState();
// }

// class _CryptoWalletScreenState extends State<CryptoWalletScreen> {
//   String amount = '240';
//   bool isAccountSelected = false;

//   void _onNumberPressed(String number) {
//     setState(() {
//       if (amount == '0' || amount == '240') {
//         amount = number;
//       } else {
//         amount += number;
//       }
//     });
//   }

//   void _onDeletePressed() {
//     setState(() {
//       if (amount.length > 1) {
//         amount = amount.substring(0, amount.length - 1);
//       } else {
//         amount = '0';
//       }
//     });
//   }

//   void _onQuickAmountPressed(int value) {
//     setState(() {
//       amount = value.toString();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Color(0xFF4A90E2),
//               Color(0xFF2E5F8D),
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               // Header
//               Padding(
//                 padding: const EdgeInsets.all(20.0),
//                 child: Row(
//                   children: [
//                     Container(
//                       width: 60,
//                       height: 60,
//                       decoration: BoxDecoration(
//                         shape: BoxShape.circle,
//                         color: Colors.white,
//                         image: const DecorationImage(
//                           image: NetworkImage(
//                             'https://i.pravatar.cc/150?img=12',
//                           ),
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Alexsmithmob',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 20,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         SizedBox(height: 2),
//                         Text(
//                           '0x7094...2242',
//                           style: TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                           ),
//                         ),
//                       ],
//                     ),
//                     const Spacer(),
//                     Container(
//                       width: 44,
//                       height: 44,
//                       decoration: BoxDecoration(
//                         color: Colors.white.withOpacity(0.2),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: const Icon(
//                         Icons.settings_outlined,
//                         color: Colors.white,
//                         size: 24,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
              
//               const SizedBox(height: 40),
              
//               // Amount Display
//               Text(
//                 '\$${amount}',
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 72,
//                   fontWeight: FontWeight.bold,
//                   height: 1,
//                 ),
//               ),
              
//               const SizedBox(height: 50),
              
//               // Bottom Card
//               Expanded(
//                 child: Container(
//                   decoration: const BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.only(
//                       topLeft: Radius.circular(30),
//                       topRight: Radius.circular(30),
//                     ),
//                   ),
//                   child: Padding(
//                     padding: const EdgeInsets.all(24.0),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Choose Account',
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Color(0xFF333333),
//                           ),
//                         ),
//                         const SizedBox(height: 16),
                        
//                         // Account Card
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               isAccountSelected = !isAccountSelected;
//                             });
//                           },
//                           child: Container(
//                             padding: const EdgeInsets.all(20),
//                             decoration: BoxDecoration(
//                               color: const Color(0xFFF5F5F5),
//                               borderRadius: BorderRadius.circular(16),
//                             ),
//                             child: Row(
//                               children: [
//                                 Container(
//                                   width: 40,
//                                   height: 40,
//                                   decoration: const BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     gradient: LinearGradient(
//                                       colors: [
//                                         Color(0xFFEB001B),
//                                         Color(0xFFF79E1B),
//                                       ],
//                                     ),
//                                   ),
//                                 ),
//                                 const SizedBox(width: 16),
//                                 const Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       'Account',
//                                       style: TextStyle(
//                                         fontSize: 16,
//                                         color: Color(0xFF666666),
//                                       ),
//                                     ),
//                                     SizedBox(height: 2),
//                                     Text(
//                                       '••••••••••••3994',
//                                       style: TextStyle(
//                                         fontSize: 14,
//                                         color: Color(0xFF999999),
//                                       ),
//                                     ),
//                                   ],
//                                 ),
//                                 const Spacer(),
//                                 Container(
//                                   width: 24,
//                                   height: 24,
//                                   decoration: BoxDecoration(
//                                     shape: BoxShape.circle,
//                                     border: Border.all(
//                                       color: isAccountSelected
//                                           ? const Color(0xFF4A90E2)
//                                           : const Color(0xFFDDDDDD),
//                                       width: 2,
//                                     ),
//                                     color: isAccountSelected
//                                         ? const Color(0xFF4A90E2)
//                                         : Colors.transparent,
//                                   ),
//                                   child: isAccountSelected
//                                       ? const Icon(
//                                           Icons.check,
//                                           size: 16,
//                                           color: Colors.white,
//                                         )
//                                       : null,
//                                 ),
//                               ],
//                             ),
//                           ),
//                         ),
                        
//                         const SizedBox(height: 24),
                        
//                         // Quick Amount Buttons
//                         Row(
//                           children: [
//                             Expanded(
//                               child: _QuickAmountButton(
//                                 amount: 100,
//                                 onPressed: () => _onQuickAmountPressed(100),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: _QuickAmountButton(
//                                 amount: 300,
//                                 onPressed: () => _onQuickAmountPressed(300),
//                               ),
//                             ),
//                             const SizedBox(width: 12),
//                             Expanded(
//                               child: _QuickAmountButton(
//                                 amount: 1000,
//                                 onPressed: () => _onQuickAmountPressed(1000),
//                               ),
//                             ),
//                           ],
//                         ),
                        
//                         const SizedBox(height: 24),
                        
//                         // Number Pad
//                         Expanded(
//                           child: _NumberPad(
//                             onNumberPressed: _onNumberPressed,
//                             onDeletePressed: _onDeletePressed,
//                           ),
//                         ),
                        
//                         const SizedBox(height: 16),
                        
//                         // Buy Button
//                         SizedBox(
//                           width: double.infinity,
//                           height: 60,
//                           child: ElevatedButton(
//                             onPressed: () {},
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: const Color(0xFF00D084),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(30),
//                               ),
//                               elevation: 0,
//                             ),
//                             child: const Text(
//                               'Buy',
//                               style: TextStyle(
//                                 fontSize: 20,
//                                 fontWeight: FontWeight.w600,
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _QuickAmountButton extends StatelessWidget {
//   final int amount;
//   final VoidCallback onPressed;

//   const _QuickAmountButton({
//     Key? key,
//     required this.amount,
//     required this.onPressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onPressed,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16),
//         decoration: BoxDecoration(
//           color: const Color(0xFFF5F5F5),
//           borderRadius: BorderRadius.circular(16),
//         ),
//         child: Center(
//           child: Text(
//             '\$$amount',
//             style: const TextStyle(
//               fontSize: 20,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF00A86B),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// class _NumberPad extends StatelessWidget {
//   final Function(String) onNumberPressed;
//   final VoidCallback onDeletePressed;

//   const _NumberPad({
//     Key? key,
//     required this.onNumberPressed,
//     required this.onDeletePressed,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         Expanded(
//           child: Row(
//             children: [
//               _NumberButton('1', onNumberPressed),
//               _NumberButton('2', onNumberPressed),
//               _NumberButton('3', onNumberPressed),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Row(
//             children: [
//               _NumberButton('4', onNumberPressed),
//               _NumberButton('5', onNumberPressed),
//               _NumberButton('6', onNumberPressed),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Row(
//             children: [
//               _NumberButton('7', onNumberPressed),
//               _NumberButton('8', onNumberPressed),
//               _NumberButton('9', onNumberPressed),
//             ],
//           ),
//         ),
//         Expanded(
//           child: Row(
//             children: [
//               _NumberButton('.', onNumberPressed),
//               _NumberButton('0', onNumberPressed),
//               Expanded(
//                 child: GestureDetector(
//                   onTap: onDeletePressed,
//                   child: Container(
//                     color: Colors.transparent,
//                     child: const Center(
//                       child: Icon(
//                         Icons.backspace_outlined,
//                         size: 28,
//                         color: Color(0xFF333333),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// class _NumberButton extends StatelessWidget {
//   final String number;
//   final Function(String) onPressed;

//   const _NumberButton(this.number, this.onPressed, {Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Expanded(
//       child: GestureDetector(
//         onTap: () => onPressed(number),
//         child: Container(
//           color: Colors.transparent,
//           child: Center(
//             child: Text(
//               number,
//               style: const TextStyle(
//                 fontSize: 32,
//                 fontWeight: FontWeight.w400,
//                 color: Color(0xFF333333),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }














// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';

// import 'package:flutter_riverpod/legacy.dart';

// /// =======================
// /// STATE MANAGEMENT
// /// =======================

// final amountProvider =
//     StateNotifierProvider<AmountNotifier, String>((ref) {
//   return AmountNotifier();
// });

// class AmountNotifier extends StateNotifier<String> {
//   AmountNotifier() : super('');

//   void add(String value) {
//     if (value == '.' && state.contains('.')) return;
//     if (state == '0' && value != '.') {
//       state = value;
//     } else {
//       state += value;
//     }
//   }

//   void delete() {
//     if (state.isNotEmpty) {
//       state = state.substring(0, state.length - 1);
//     }
//   }

//   void setAmount(String value) {
//     state = value;
//   }

//   double get amount => double.tryParse(state) ?? 0;
// }

// /// =======================
// /// SCREEN
// /// =======================

// class BuyTraderScreen extends ConsumerWidget {
//   const BuyTraderScreen({super.key});

//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final amount = ref.watch(amountProvider);

//     return Scaffold(
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               Color(0xFFEAF6FF),
//               Color(0xFFBEE7FF),
//             ],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               _header(),
//               const SizedBox(height: 24),

//               /// Amount Display
//               Text(
//                 '\R${amount.isEmpty ? '0' : amount}',
//                 style: const TextStyle(
//                   fontSize: 40,
//                   fontWeight: FontWeight.bold,
//                   color: Color(0xFF1565C0),
//                 ),
//               ),

//               const SizedBox(height: 24),
//               _assetCard(),
//               const SizedBox(height: 24),
//               _quickAmounts(ref),
//               const SizedBox(height: 24),
//               _keypad(ref),
//               const Spacer(),
//               _buyButton(ref),
//               const SizedBox(height: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   /// =======================
//   /// HEADER
//   /// =======================

//   Widget _header() {
//     return const Padding(
//       padding: EdgeInsets.symmetric(horizontal: 20),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Buy Trader',
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1E88E5),
//             ),
//           ),
//           Icon(Icons.notifications_none, color: Color(0xFF1E88E5)),
//         ],
//       ),
//     );
//   }

//   /// =======================
//   /// ASSET CARD
//   /// =======================

//   Widget _assetCard() {
//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(16),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.blue.withOpacity(0.08),
//               blurRadius: 10,
//             ),
//           ],
//         ),
//         child: const Row(
//           children: [
//             CircleAvatar(
//               backgroundColor: Color(0xFF64B5F6),
//               child: Text(
//                 'T',
//                 style: TextStyle(color: Colors.white),
//               ),
//             ),
//             SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Tether USD',
//                   style: TextStyle(fontWeight: FontWeight.w600),
//                 ),
//                 Text(
//                   'Balance: 240 USDT',
//                   style: TextStyle(
//                     fontSize: 12,
//                     color: Colors.grey,
//                   ),
//                 ),
//               ],
//             ),
//             Spacer(),
//             Icon(Icons.chevron_right),
//           ],
//         ),
//       ),
//     );
//   }

//   /// =======================
//   /// QUICK AMOUNTS
//   /// =======================

//   Widget _quickAmounts(WidgetRef ref) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         _amountChip('\R100', () {
//           ref.read(amountProvider.notifier).setAmount('100');
//         }),
//         _amountChip('\R300', () {
//           ref.read(amountProvider.notifier).setAmount('300');
//         }),
//         _amountChip('\R1000', () {
//           ref.read(amountProvider.notifier).setAmount('1000');
//         }),
//       ],
//     );
//   }

//   Widget _amountChip(String text, VoidCallback onTap) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         margin: const EdgeInsets.symmetric(horizontal: 6),
//         padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(20),
//         ),
//         child: Text(
//           text,
//           style: const TextStyle(
//             color: Color(0xFF1E88E5),
//             fontWeight: FontWeight.w600,
//           ),
//         ),
//       ),
//     );
//   }

//   /// =======================
//   /// KEYPAD
//   /// =======================

//   Widget _keypad(WidgetRef ref) {
//     final keys = [
//       '1', '2', '3',
//       '4', '5', '6',
//       '7', '8', '9',
//       '.', '0', '⌫',
//     ];

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 32),
//       child: GridView.builder(
//         shrinkWrap: true,
//         physics: const NeverScrollableScrollPhysics(),
//         itemCount: keys.length,
//         gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//           crossAxisCount: 3,
//           mainAxisSpacing: 16,
//           crossAxisSpacing: 16,
//           childAspectRatio: 1.4,
//         ),
//         itemBuilder: (context, index) {
//           final key = keys[index];

//           return GestureDetector(
//             onTap: () {
//               final notifier = ref.read(amountProvider.notifier);
//               if (key == '⌫') {
//                 notifier.delete();
//               } else {
//                 notifier.add(key);
//               }
//             },
//             child: Center(
//               child: Text(
//                 key,
//                 style: const TextStyle(
//                   fontSize: 22,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }

//   /// =======================
//   /// BUY BUTTON
//   /// =======================

//   Widget _buyButton(WidgetRef ref) {
//     final amount = ref.watch(amountProvider.notifier).amount;

//     return Padding(
//       padding: const EdgeInsets.symmetric(horizontal: 20),
//       child: Container(
//         height: 54,
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(28),
//           gradient: const LinearGradient(
//             colors: [
//               Color.fromARGB(255, 248, 252, 255),
//               Color(0xFF42A5F5),
//             ],
//           ),
//         ),
//         child: Center(
//           child: Text(
//             'Buy \$${amount.toStringAsFixed(2)}',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.bold,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
























































































// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'providers/transactions/transaction_provider.dart';
// import 'providers/wallet/wallet_provider.dart';

// class SendMoneyScreen extends ConsumerStatefulWidget {
//   const SendMoneyScreen({super.key});

//   @override
//   ConsumerState<SendMoneyScreen> createState() => _SendMoneyScreenState();
// }

// class _SendMoneyScreenState extends ConsumerState<SendMoneyScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _emailController = TextEditingController();
//   final _amountController = TextEditingController();
//   final _descriptionController = TextEditingController();
//   bool _isLoading = false;

//   @override
//   void dispose() {
//     _emailController.dispose();
//     _amountController.dispose();
//     _descriptionController.dispose();
//     super.dispose();
//   }

//   Future<void> _sendMoney() async {
//     if (!_formKey.currentState!.validate()) return;

//     setState(() => _isLoading = true);

//     try {
//       final senderWallet = ref.read(walletProvider).value!;
//       final receiverWallet = await ref
//           .read(walletRepositoryProvider)
//           .getWalletByEmail(_emailController.text.trim());

//       if (receiverWallet == null) {
//         throw Exception('Recipient not found');
//       }

//       await ref.read(transactionRepositoryProvider).sendMoney(
//             senderWalletId: senderWallet.id,
//             receiverWalletId: receiverWallet.id,
//             amount: double.parse(_amountController.text),
//             currency: senderWallet.currency,
//             description: _descriptionController.text,
//           );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Transfer successful')),
//         );
//         Navigator.pop(context);
//       }
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(e.toString())),
//       );
//     } finally {
//       setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Send Money')),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               TextFormField(
//                 controller: _emailController,
//                 decoration: const InputDecoration(labelText: 'Recipient Email'),
//                 keyboardType: TextInputType.emailAddress,
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an email';
//                   }
//                   if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
//                     return 'Please enter a valid email';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _amountController,
//                 decoration: const InputDecoration(labelText: 'Amount'),
//                 keyboardType: const TextInputType.numberWithOptions(decimal: true),
//                 validator: (value) {
//                   if (value == null || value.isEmpty) {
//                     return 'Please enter an amount';
//                   }
//                   if (double.tryParse(value) == null ||
//                       double.parse(value) <= 0) {
//                     return 'Please enter a valid amount';
//                   }
//                   return null;
//                 },
//               ),
//               TextFormField(
//                 controller: _descriptionController,
//                 decoration: const InputDecoration(labelText: 'Description'),
//               ),
//               const SizedBox(height: 20),
//               _isLoading
//                   ? const CircularProgressIndicator()
//                   : ElevatedButton(
//                       onPressed: _sendMoney,
//                       child: const Text('Send Money'),
//                     ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
