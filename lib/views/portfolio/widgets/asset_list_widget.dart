import 'package:flutter/material.dart';
import '../models/crypto_asset_model.dart';
import 'asset_tile_widget.dart';

class AssetList extends StatelessWidget {

  final List<CryptoAssetModel> assets;

  const AssetList({

    super.key,

    required this.assets,

  });

  @override
  Widget build(BuildContext context) {

    return ListView.builder(

      shrinkWrap:true,

      physics:
      const NeverScrollableScrollPhysics(),

      itemCount: assets.length,

      itemBuilder:(context,index){

        return AssetTile(

          asset: assets[index],

        );

      },

    );

  }

}