import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Set Temporary Limits',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TemporaryLimitsScreenT(),
    );
  }
}

class TemporaryLimitsScreenT extends StatefulWidget {
  const TemporaryLimitsScreenT({super.key});

  @override
  _TemporaryLimitsScreenState createState() => _TemporaryLimitsScreenState();
}

class _TemporaryLimitsScreenState extends State<TemporaryLimitsScreenT> {
  bool _cashWithdrawals = false;
  bool _cardMachinePurchases = false;
  bool _onlinePayments = false;

  final TextEditingController _cashWithdrawalController = TextEditingController();
  final TextEditingController _cardMachineController = TextEditingController();
  final TextEditingController _onlinePaymentsController = TextEditingController();

  // Function to create the CheckboxListTile with dynamic height and optional TextField dropdown
  Widget buildLimitOption({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required TextEditingController controller,
    bool showDropdown = false,
    String? expiryDate,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Smooth transition
      height: value ? 130 : 58, // Dynamic height change
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            activeColor: Colors.blue, // Set the active color to blue
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                if (expiryDate != null)
                  Text(
                    'Expires on $expiryDate',
                    style: const TextStyle(fontSize: 12),
                  ),
              ],
            ),
            value: value,
            onChanged: onChanged,
          ),
          if (showDropdown)
            Padding(
              padding: const EdgeInsets.only(left: 16.0, bottom: 16.0),
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount (max R10 000)',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Set Temporary Limits'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Debit daily limits',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            buildLimitOption(
              title: 'Cash withdrawals',
              value: _cashWithdrawals,
              onChanged: (bool? value) {
                setState(() {
                  _cashWithdrawals = value ?? false;
                });
              },
              controller: _cashWithdrawalController,
              showDropdown: _cashWithdrawals,
              expiryDate: '3 Feb 2025 at midnight', // Optional expiry date
            ),
            buildLimitOption(
              title: 'Card machine purchases',
              value: _cardMachinePurchases,
              onChanged: (bool? value) {
                setState(() {
                  _cardMachinePurchases = value ?? false;
                });
              },
              controller: _cardMachineController,
              showDropdown: _cardMachinePurchases,
            ),
            buildLimitOption(
              title: 'Online/scan to pay/phone',
              value: _onlinePayments,
              onChanged: (bool? value) {
                setState(() {
                  _onlinePayments = value ?? false;
                });
              },
              controller: _onlinePaymentsController,
              showDropdown: _onlinePayments,
            ),
            const Spacer(),
            const Text(
              'A temporary limit will replace a permanent limit until it automatically expires after 3 days.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement logic for setting the limits
                },
                child: const Text('Set'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
