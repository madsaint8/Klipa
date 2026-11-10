import 'package:flutter/material.dart';
import '../../common/widgets/transaction/payment_method.dart';
import '../../config/theme/colors/app_colors.dart';
import '../../config/theme/constants/image_strings.dart';

class TopUpScreen extends StatefulWidget {
  const TopUpScreen({super.key});

  @override
  _TopUpScreenState createState() => _TopUpScreenState();
}

class _TopUpScreenState extends State<TopUpScreen> {
  double amount = 150.00;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(color: Colors.white),
        title: const Text(
          'Deposit',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      backgroundColor: AppColors.softGrey,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Enter amount to transfer into your wallet',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(10.0),
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const SizedBox(width: 10),
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          image: DecorationImage(
                            image: AssetImage(AppImages.countryFlag),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(width: 31),
                      IconButton(
                        icon: const Icon(
                          Icons.remove,
                          size: 24,
                          color: AppColors.buttonPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            if (amount > 0) amount -= 10;
                          });
                        },
                      ),
                      Text(
                        'R${amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 24,
                          color: AppColors.buttonPrimary,
                        ),
                        onPressed: () {
                          setState(() {
                            amount += 10;
                          });
                        },
                      ),
                    ],
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Balance: R140 654.14",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkGrey,
                        ),
                      ),
                      Text(
                        "Min amount: R20",
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.darkGrey,
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Payment methods',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // Action to change payment method
                  },
                  child: const Text(
                    'Edit',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(16.0),
              height: 335,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.white,
              ),
              child: Align(
                alignment: Alignment.topCenter,
                // Center the button inside the container
                child: Column(
                  children: [
                    Column(
                      children: paymentMethods
                          .map((method) => buildContactCard(method))
                          .toList(),
                    ),
                    
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Action on continue
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 120, vertical: 20),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(color: AppColors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
