// class NewsArticle {
//   final String id;
//   final String title;
//   final String source;
//   final String url;
//   final String? imageUrl;
//   final String? body;
//   final List<String> categories;
//   final List<String> tickers;
//   final DateTime publishedAt;

//   const NewsArticle({
//     required this.id,
//     required this.title,
//     required this.source,
//     required this.url,
//     this.imageUrl,
//     this.body,
//     required this.categories,
//     required this.tickers,
//     required this.publishedAt,
//   });

//   /// CryptoCompare /data/v2/news response shape
//   factory NewsArticle.fromCryptoCompare(Map<String, dynamic> json) {
//     final ts = json['published_on'] as int? ?? 0;
//     return NewsArticle(
//       id: json['id']?.toString() ?? '',
//       title: json['title'] as String? ?? '',
//       source: (json['source_info'] as Map?)?['name'] as String? ??
//           json['source'] as String? ??
//           '',
//       url: json['url'] as String? ?? '',
//       imageUrl: json['imageurl'] as String?,
//       body: json['body'] as String?,
//       categories: (json['categories'] as String? ?? '')
//           .split('|')
//           .where((c) => c.isNotEmpty)
//           .toList(),
//       tickers: (json['tags'] as String? ?? '')
//           .split('|')
//           .where((t) => t.isNotEmpty)
//           .toList(),
//       publishedAt: DateTime.fromMillisecondsSinceEpoch(ts * 1000),
//     );
//   }

//   String get timeAgo {
//     final diff = DateTime.now().difference(publishedAt);
//     if (diff.inMinutes < 1) return 'just now';
//     if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
//     if (diff.inHours < 24) return '${diff.inHours}h ago';
//     return '${diff.inDays}d ago';
//   }

//   /// First tag/ticker for the badge, fallback to first category
//   String get badge {
//     if (tickers.isNotEmpty) return tickers.first.toUpperCase();
//     if (categories.isNotEmpty) return categories.first;
//     return 'NEWS';
//   }
// }