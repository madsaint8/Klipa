import 'package:flutter/material.dart';
import '../models/crypto_asset_model.dart';

class AssetTile extends StatelessWidget {

  final CryptoAssetModel asset;

  const AssetTile({

    super.key,

    required this.asset,

  });

  @override
  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(
        vertical:8,
      ),

      child: Row(

        children: [

          CircleAvatar(

            radius:20,

            backgroundImage: AssetImage(
              asset.image,
            ),

          ),

          const SizedBox(width:12),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                Text(asset.name),

                Text(

                  asset.symbol,

                  style: const TextStyle(
                    color: Colors.grey,
                  ),

                )

              ],

            ),

          ),

          Column(

            crossAxisAlignment: CrossAxisAlignment.end,

            children: [

              Text(
                asset.balance.toString(),
              ),

              Text(

                "R${asset.fiatValue}",

                style: const TextStyle(
                  color: Colors.grey,
                ),

              )

            ],

          )

        ],
      ),
    );
  }

}