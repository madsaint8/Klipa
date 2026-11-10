import 'package:flutter/material.dart';
import '../../../config/theme/colors/app_colors.dart';


class TemporaryLimitsScreen extends StatefulWidget {
  const TemporaryLimitsScreen({super.key});

  @override
  _TemporaryLimitsScreenState createState() => _TemporaryLimitsScreenState();
}

class _TemporaryLimitsScreenState extends State<TemporaryLimitsScreen> {
  bool _cashWithdrawals = false;
  bool _cardMachinePurchases = false;
  bool _onlinePayments = false;

  final TextEditingController _cashWithdrawalController = TextEditingController(text: "R0.00");
  final TextEditingController _cardMachineController = TextEditingController(text: "R0.00");
  final TextEditingController _onlinePaymentsController = TextEditingController(text: "R0.00");

  // Function to calculate the height based on the state of the checkboxes
  double _calculateHeight() {
    double baseHeight = 219; // Default height
    if (_cashWithdrawals) baseHeight += 70;
    if (_cardMachinePurchases) baseHeight += 70;
    if (_onlinePayments) baseHeight += 73;
    return baseHeight;
  }

  // Custom input formatter to maintain "R" at the start of the amount
  String _formatCurrency(String value) {
    if (!value.startsWith('R')) {
      return 'R$value';
    }
    return value;
  }

  // Function to create the CheckboxListTile and the optional TextField dropdown
  Widget buildLimitOption({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required TextEditingController controller,
    bool showDropdown = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          activeColor: Colors.blue, // Set the active color to blue
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title),
              if (value) // Expiry date visible only when checkbox is clicked
                const Text(
                  'Expires on 3 Feb 2025 at midnight',
                  style: TextStyle(fontSize: 12),
                ),
            ],
          ),
          value: value,
          onChanged: onChanged,
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
                hintText: '0.00', // Hint for the user to input an amount
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none, // Remove the underline
                labelText: 'Amount (max R10 000)',
                labelStyle: TextStyle(
                  color: Colors.blue, // Max amount label color to blue
                ),
              ),
              onChanged: (text) {
                // Ensuring that the currency symbol "R" stays in front
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
      backgroundColor: AppColors.softGrey,
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Set Temporary Limits',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        centerTitle: true,
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 0), // Smooth transition
              padding: const EdgeInsets.all(10.0),
              height: _calculateHeight(), // Dynamic height calculation
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.white,
              ),
              child: Column(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 0), // Smooth transition
                    height: _cashWithdrawals ? 130 : 58, // Dynamic height change
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.lightGrey,
                    ),
                    child: buildLimitOption(
                      title: 'Cash withdrawals',
                      value: _cashWithdrawals,
                      onChanged: (bool? value) {
                        setState(() {
                          _cashWithdrawals = value ?? false;
                        });
                      },
                      controller: _cashWithdrawalController,
                      showDropdown: _cashWithdrawals,
                    ),
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 0), // Smooth transition
                    height: _cardMachinePurchases ? 130 : 58, // Dynamic height change
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.lightGrey,
                    ),
                    child: buildLimitOption(
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
                  ),
                  const SizedBox(height: 10),
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 0), // Smooth transition
                    height: _onlinePayments ? 130 : 58, // Dynamic height change
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: AppColors.lightGrey,
                    ),
                    child: buildLimitOption(
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
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              '    A temporary limit will replace a permanent limit until it\n                      automatically expires after 3 days.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Implement your logic here for setting limits
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 150, vertical: 15),
                  backgroundColor: AppColors.buttonPrimary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Set',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
