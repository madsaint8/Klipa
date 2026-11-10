import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../data/models/defi_sites/defi_sites_model.dart';

class DefiSiteService {
  static const _base = 'https://api.llama.fi';

  /// Fetches top DeFi protocols sorted by TVL.
  /// DeFiLlama is completely free with no API key required.
  Future<List<DefiSite>> fetchTopProtocols({int limit = 30}) async {
    final uri = Uri.parse('$_base/protocols');

    final res = await http.get(uri).timeout(const Duration(seconds: 20));

    if (res.statusCode != 200) {
      throw Exception('DeFiLlama fetch failed: ${res.statusCode}');
    }

    final List<dynamic> list = json.decode(res.body) as List;

    return list
        .take(limit)
        .map((e) => DefiSite.fromDeFiLlama(e as Map<String, dynamic>))
        .toList();
  }

  /// Fetches protocols filtered by category (e.g. 'Dexes', 'Lending', 'Yield').
  Future<List<DefiSite>> fetchByCategory(String category,
      {int limit = 20}) async {
    final all = await fetchTopProtocols(limit: 200);
    return all
        .where(
            (s) => s.category.toLowerCase() == category.toLowerCase())
        .take(limit)
        .toList();
  }
}