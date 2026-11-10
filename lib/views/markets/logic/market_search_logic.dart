import 'package:paywave/data/models/crypto/news/crypto_news_model.dart';

import '../models/market_item_model.dart';

/// Pure, testable search. Multi-word queries use AND semantics ("gold bar"
/// needs both words) and results are ranked: exact > prefix > title > other
/// fields (tags, description, keywords).
class MarketSearchLogic {
  MarketSearchLogic._();

  static List<String> terms(String query) => query
      .toLowerCase()
      .split(RegExp(r'\s+'))
      .where((t) => t.isNotEmpty)
      .toList(growable: false);

  /// -1 = not a match.
  static int score(MarketItem item, List<String> terms) {
    if (terms.isEmpty) return 0;
    final title = item.title.toLowerCase();
    final subtitle = item.subtitle.toLowerCase();
    var total = 0;
    for (final t in terms) {
      if (title == t || subtitle == t) {
        total += 100;
      } else if (title.startsWith(t) || subtitle.startsWith(t)) {
        total += 80;
      } else if (title.contains(t)) {
        total += 60;
      } else if (item.searchText.contains(t)) {
        total += 30;
      } else {
        return -1;
      }
    }
    return total;
  }

  static List<MarketItem> filter(List<MarketItem> items, String query) {
    final t = terms(query);
    if (t.isEmpty) return items;

    final scored = <({MarketItem item, int score, int index})>[];
    for (var i = 0; i < items.length; i++) {
      final s = score(items[i], t);
      if (s >= 0) scored.add((item: items[i], score: s, index: i));
    }
    scored.sort((a, b) {
      final byScore = b.score.compareTo(a.score);
      return byScore != 0 ? byScore : a.index.compareTo(b.index); // stable
    });
    return [for (final s in scored) s.item];
  }

  static List<CryptoNewsArticle> filterNews(
      List<CryptoNewsArticle> articles, String query) {
    final t = terms(query);
    if (t.isEmpty) return articles;
    return articles.where((a) {
      final hay =
          '${a.title} ${a.publisher} ${a.topics.join(' ')}'.toLowerCase();
      return t.every(hay.contains);
    }).toList();
  }
}
