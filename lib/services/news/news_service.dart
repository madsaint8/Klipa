// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import '../../data/models/news_articles/news_article_model.dart';

// class NewsService {
//   static const _base = 'https://data-api.cryptocompare.com';

//   /// Fetch latest crypto news, optionally filtered by category/ticker.
//   ///
//   /// [categories] — comma-separated CryptoCompare categories, e.g. 'BTC,ETH'
//   /// [feeds]      — comma-separated feed IDs, e.g. 'coindesk,decrypt'
//   Future<List<NewsArticle>> fetchLatestNews({
//     String? categories,
//     String? feeds,
//     int limit = 20,
//   }) async {
//     final params = <String, String>{
//       'limit': limit.toString(),
//       'lang': 'EN',
//       'extraParams': 'FlutterMarketsApp',
//     };
//     if (categories != null && categories.isNotEmpty) {
//       params['categories'] = categories;
//     }
//     if (feeds != null && feeds.isNotEmpty) {
//       params['feeds'] = feeds;
//     }

//     final uri = Uri.parse('$_base/news/v1/article/list').replace(
//       queryParameters: params,
//     );

//     final res = await http.get(uri).timeout(const Duration(seconds: 15));

//     if (res.statusCode == 429) throw Exception('News rate limited');
//     if (res.statusCode != 200) {
//       throw Exception('News fetch failed: ${res.statusCode}');
//     }

//     final body = json.decode(res.body) as Map<String, dynamic>;

//     // data-api.cryptocompare.com returns {"Data": {"Data": [...]}}
//     dynamic rawList;
//     final data = body['Data'];
//     if (data is Map) {
//       rawList = data['Data'];
//     } else if (data is List) {
//       rawList = data;
//     }

//     if (rawList is! List) throw Exception('Unexpected news response shape');

//     return (rawList as List)
//         .map((e) =>
//             NewsArticle.fromCryptoCompare(e as Map<String, dynamic>))
//         .toList();
//   }

//   /// Convenience: news filtered to a specific ticker (e.g. 'BTC')
//   Future<List<NewsArticle>> fetchNewsForTicker(String ticker) =>
//       fetchLatestNews(categories: ticker);
// }