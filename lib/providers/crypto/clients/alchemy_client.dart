import 'package:dio/dio.dart';

class AlchemyClient {
  final Dio _dio;
  final String rpcUrl;

  const AlchemyClient({
    required Dio dio,
    required this.rpcUrl,
  }) : _dio = dio;

  Future<Map<String, dynamic>> rpc({
    required String method,
    List<dynamic> params = const [],
  }) async {
    final response = await _dio.post(
      rpcUrl,
      data: {
        "jsonrpc": "2.0",
        "id": 1,
        "method": method,
        "params": params,
      },
    );

    final data = response.data as Map<String, dynamic>;

    if (data["error"] != null) {
      throw Exception(data["error"]["message"]);
    }

    return data;
  }

  Future<String> getNativeBalance(String address) async {
    final json = await rpc(
      method: "eth_getBalance",
      params: [address, "latest"],
    );

    return json["result"] as String;
  }

  Future<Map<String, dynamic>> getTokenBalances(
    String address,
  ) async {
    return rpc(
      method: "alchemy_getTokenBalances",
      params: [address],
    );
  }

  Future<Map<String, dynamic>> getAssetTransfers(
    String address,
  ) async {
    return rpc(
      method: "alchemy_getAssetTransfers",
      params: [
        {
          "fromBlock": "0x0",
          "toAddress": address,
          "category": [
            "external",
            "erc20",
            "erc721",
            "erc1155",
          ],
        }
      ],
    );
  }
}