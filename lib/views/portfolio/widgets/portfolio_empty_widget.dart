import 'package:flutter/material.dart';

class PortfolioEmpty extends StatelessWidget {
  const PortfolioEmpty({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.account_balance_wallet_outlined,
              size: 80,
            ),
            const SizedBox(height: 20),
            const Text(
              "Your wallet is empty",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Buy or receive crypto to start using your Web3 wallet.",
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            FilledButton(
              onPressed: () {},
              child: const Text("Buy Crypto"),
            )
          ],
        ),
      ),
    );
  }
}