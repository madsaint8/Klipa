import 'package:flutter/material.dart';
import '../../../config/theme/colors/app_colors.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: UpdateLimitsScreen(),
    );
  }
}

class UpdateLimitsScreen extends StatefulWidget {
  const UpdateLimitsScreen({super.key});

  @override
  _UpdateLimitsScreenState createState() => _UpdateLimitsScreenState();
}

class _UpdateLimitsScreenState extends State<UpdateLimitsScreen> {
  // All options are now permanently selected
  final bool _cashWithdrawals = true;
  final bool _cardMachinePurchases = true;
  final bool _onlinePayments = true;

  final TextEditingController _cashWithdrawalController = TextEditingController(text: "R0.00");
  final TextEditingController _cardMachineController = TextEditingController(text: "R0.00");
  final TextEditingController _onlinePaymentsController = TextEditingController(text: "R0.00");

 
  // Custom input formatter to maintain "R" at the start of the amount
  String _formatCurrency(String value) {
    if (!value.startsWith('R')) {
      return 'R$value';
    }
    return value;
  }

  // Function to create the TextField dropdown without Checkbox
  Widget buildLimitOption({
    required String title,
    required bool value,
    required TextEditingController controller,
    bool showDropdown = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ListTile(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              if (value) // Expiry date always visible since it's selected
                const Text(
                  'Expires on 3 Feb 2025 at midnight',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
        ),
        if (showDropdown) ...[
          const Divider(
            color: Colors.grey,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 14.0, bottom: 0.0),
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                hintText: '0.00',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                labelText: 'Amount (max R10 000)',
                labelStyle: TextStyle(
                  color: Colors.blue,
                ),
              ),
              onChanged: (text) {
                controller.value = controller.value.copyWith(
                  text: _formatCurrency(text),
                  selection: TextSelection.collapsed(offset: text.length + 1),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.lightGrey,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          "Update Permanent Limits",
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Making a big purchase? Increase the temporary limit instead, it will automatically change back in 3 days. Easy and safe.',
                      style: TextStyle(fontSize: 14, color: Colors.black),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('Debit daily limits', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10.0),
              height: 430,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 0),
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.lightGrey,
                    ),
                    child: buildLimitOption(
                      title: 'Cash withdrawals',
                      value: _cashWithdrawals,
                      controller: _cashWithdrawalController,
                      showDropdown: _cashWithdrawals,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 0),
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.lightGrey,
                    ),
                    child: buildLimitOption(
                      title: 'Card machine purchases',
                      value: _cardMachinePurchases,
                      controller: _cardMachineController,
                      showDropdown: _cardMachinePurchases,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 0),
                    height: 130,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.lightGrey,
                    ),
                    child: buildLimitOption(
                      title: 'Online/scan to pay/phone',
                      value: _onlinePayments,
                      controller: _onlinePaymentsController,
                      showDropdown: _onlinePayments,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                // Update button action
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: Colors.blue,
              ),
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
