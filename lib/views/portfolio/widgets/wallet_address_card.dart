import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';

class WalletAddressCard extends StatelessWidget {

  final String address;

  const WalletAddressCard({
    super.key,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.symmetric(vertical: 20),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(

        color: Colors.grey.shade100,

        borderRadius: BorderRadius.circular(18),

      ),

      child: Row(

        children: [

          const Icon(Iconsax.wallet),

          const SizedBox(width: 12),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Text(
                  "Wallet Address",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),

                Text(
                  address,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),

              ],
            ),
          ),

          IconButton(

            onPressed: () {

              Clipboard.setData(
                ClipboardData(text: address),
              );

              ScaffoldMessenger.of(context).showSnackBar(

                const SnackBar(
                  content: Text("Wallet copied"),
                ),

              );

            },

            icon: const Icon(Icons.copy),

          )

        ],
      ),
    );
  }
}