import 'package:flutter/material.dart';
import 'package:paywave/config/theme/colors/app_colors.dart';
import '../../common/widgets/buttons/custom_button.dart';
import '../scan_to_pay/scan_features/my_qr.dart';

class SendBankAccountPage extends StatelessWidget {
  const SendBankAccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Bank Account',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Account Holder
            const Text(
              "Account Holder's Name",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            _inputField("John Smith"),

            const SizedBox(height: 20),

            /// Bank Name
            const Text(
              "Bank Name",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            _inputField("Capitec Bank"),

            const SizedBox(height: 20),

            /// Account Number
            const Text(
              "Account Number",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            _inputField("1234 5678 9012"),

            const SizedBox(height: 20),

            /// Row fields
            Row(
              children: [
                /// Amount
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Amount",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _inputField("R0.00"),
                    ],
                  ),
                ),

                const SizedBox(width: 15),

                /// Branch Code
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Branch Code",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _inputField("470010"),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            /// Send Button
            CustomButton(
              text: 'Send Money',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MyQRCodeScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable fintech input
  static Widget _inputField(String hint) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: AppColors.grey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
