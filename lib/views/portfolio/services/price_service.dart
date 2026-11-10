import 'package:dio/dio.dart';
import '../models/crypto_asset_model.dart';


class PriceService {
  final Dio _dio;

  const PriceService(this._dio);

  static const _base =
      'https://api.coingecko.com/api/v3';

  Future<Map<String, dynamic>> getCoin(
    String id,
  ) async {
    final response = await _dio.get(
      '$_base/coins/$id',
      queryParameters: {
        'localization': false,
        'tickers': false,
        'market_data': true,
        'community_data': false,
        'developer_data': false,
        'sparkline': false,
      },
    );

    return response.data;
  }

  Future<double> getPrice(String id) async {
    final json = await getCoin(id);

    return (json["market_data"]["current_price"]["usd"]
            as num)
        .toDouble();
  }

  Future<CryptoAssetModel> enrich({
    required CryptoAssetModel asset,
    required String coinId,
  }) async {
    final json = await getCoin(coinId);

    final price =
        (json["market_data"]["current_price"]["usd"]
                as num)
            .toDouble();

    return asset.copyWith(
      name: json["name"],
      symbol: json["symbol"].toString().toUpperCase(),
      image: json["image"]["large"],
      currentPrice: price,
      fiatValue: asset.balance * price,
      priceChange24h:
          (json["market_data"]["price_change_percentage_24h"]
                  as num)
              .toDouble(),
    );
  }
}