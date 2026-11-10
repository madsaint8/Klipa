/// Matches FreeNewsAPI response shape.
///
/// /news  returns lightweight articles (no thumbnail, no body).
/// /details returns full article including thumbnail, body, authors, topics.
class CryptoNewsArticle {
  final String uuid;
  final String title;
  final String publisher;
  final DateTime publishedAt;

  // Present only after a /details fetch
  final String? thumbnail;
  final String? originalUrl;
  final String? incipit;   // subtitle / excerpt
  final String? body;
  final List<String> authors;
  final List<String> topics;
  final List<String> countries;
  final List<String> languages;

  const CryptoNewsArticle({
    required this.uuid,
    required this.title,
    required this.publisher,
    required this.publishedAt,
    this.thumbnail,
    this.originalUrl,
    this.incipit,
    this.body,
    this.authors = const [],
    this.topics  = const [],
    this.countries = const [],
    this.languages = const [],
  });

  // ── /news list item ─────────────────────────────────────────────────────────
  factory CryptoNewsArticle.fromListJson(Map<String, dynamic> json) {
    return CryptoNewsArticle(
      uuid:        json['uuid']         as String? ?? '',
      title:       json['title']        as String? ?? '',
      publisher:   json['publisher']    as String? ?? '',
      publishedAt: _parseDate(json['published_at']),
    );
  }

  // ── /details full article ───────────────────────────────────────────────────
  factory CryptoNewsArticle.fromDetailJson(Map<String, dynamic> json) {
    return CryptoNewsArticle(
      uuid:        json['uuid']         as String? ?? '',
      title:       json['title']        as String? ?? '',
      publisher:   json['publisher']    as String? ?? '',
      publishedAt: _parseDate(json['published_at']),
      thumbnail:   json['thumbnail']   as String?,
      originalUrl: json['original_url'] as String?,
      incipit:     json['incipit']      as String?,
      body:        json['body']         as String?,
      authors:   List<String>.from(json['authors']   as List? ?? []),
      topics:    List<String>.from(json['topics']    as List? ?? []),
      countries: List<String>.from(json['countries'] as List? ?? []),
      languages: List<String>.from(json['languages'] as List? ?? []),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Returns an enriched copy after a /details fetch
  CryptoNewsArticle withDetails(CryptoNewsArticle details) => CryptoNewsArticle(
    uuid:        uuid,
    title:       title,
    publisher:   publisher,
    publishedAt: publishedAt,
    thumbnail:   details.thumbnail,
    originalUrl: details.originalUrl,
    incipit:     details.incipit,
    body:        details.body,
    authors:     details.authors,
    topics:      details.topics,
    countries:   details.countries,
    languages:   details.languages,
  );

  /// Human-readable relative time — ISO 8601 parsed correctly
  String get timeAgo {
    final diff = DateTime.now().difference(publishedAt);
    if (diff.inSeconds < 60)  return 'just now';
    if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
    if (diff.inHours < 24)    return '${diff.inHours}h ago';
    if (diff.inDays < 7)      return '${diff.inDays}d ago';
    if (diff.inDays < 30)     return '${(diff.inDays / 7).floor()}w ago';
    if (diff.inDays < 365)    return '${(diff.inDays / 30).floor()}mo ago';
    return '${(diff.inDays / 365).floor()}y ago';
  }

  /// Short badge shown when there's no thumbnail
  String get badge {
    if (topics.isNotEmpty) {
      return topics.first.substring(0, topics.first.length.clamp(0, 4)).toUpperCase();
    }
    if (publisher.isNotEmpty) {
      return publisher.substring(0, publisher.length.clamp(0, 3)).toUpperCase();
    }
    return 'NEWS';
  }

  /// Display source name — same field name as CoinGecko model so _NewsRow
  /// doesn't need changes if you switch back.
  String get sourceName => publisher;

  /// Thumbnail URL — same field name used in the news card widget
  String? get imageUrl => thumbnail;

  /// Backward-compat alias — coingecko_news_service.dart calls fromJson.
  /// Delegates to fromListJson; if the json has 'thumbnail' it uses fromDetailJson.
  factory CryptoNewsArticle.fromJson(Map<String, dynamic> json) {
    if (json.containsKey('thumbnail') || json.containsKey('body')) {
      return CryptoNewsArticle.fromDetailJson(json);
    }
    return CryptoNewsArticle.fromListJson(json);
  }

  /// First author string, or null — used by news_section.dart card footer.
  String? get author => authors.isNotEmpty ? authors.first : null;

  /// FreeNewsAPI has no guide type — always false.
  /// Keeps news_section.dart _TypeChip working without changes.
  bool get isGuide => false;

  static DateTime _parseDate(dynamic raw) {
    if (raw is String) return DateTime.tryParse(raw)?.toLocal() ?? DateTime.now();
    if (raw is int)    return DateTime.fromMillisecondsSinceEpoch(raw * 1000).toLocal();
    return DateTime.now();
  }
}










// /// Matches CoinGecko GET /news response shape
// class CryptoNewsArticle {
//   final String title;
//   final String url;
//   final String? imageUrl;
//   final String? author;
//   final DateTime postedAt;
//   final String type; // 'news' | 'guide'
//   final String sourceName;
//   final List<String> relatedCoinIds;

//   const CryptoNewsArticle({
//     required this.title,
//     required this.url,
//     this.imageUrl,
//     this.author,
//     required this.postedAt,
//     required this.type,
//     required this.sourceName,
//     required this.relatedCoinIds,
//   });

//   factory CryptoNewsArticle.fromJson(Map<String, dynamic> json) {
//     // posted_at is ISO 8601 string: "2026-03-27T11:00:42Z"
//     DateTime parsedDate;
//     final rawDate = json['posted_at'];
//     if (rawDate is String) {
//       parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
//     } else if (rawDate is int) {
//       // Some endpoints return Unix seconds — guard against it
//       parsedDate = DateTime.fromMillisecondsSinceEpoch(rawDate * 1000);
//     } else {
//       parsedDate = DateTime.now();
//     }

//     return CryptoNewsArticle(
//       title: json['title'] as String? ?? '',
//       url: json['url'] as String? ?? '',
//       imageUrl: json['image'] as String?,
//       author: json['author'] as String?,
//       postedAt: parsedDate,
//       type: json['type'] as String? ?? 'news',
//       sourceName: json['source_name'] as String? ?? '',
//       relatedCoinIds: List<String>.from(
//         json['related_coin_ids'] as List? ?? [],
//       ),
//     );
//   }

//   // ── Derived helpers ─────────────────────────────────────────────────────────

//   /// Human-readable relative time, e.g. "3h ago", "2d ago"
//   String get timeAgo {
//     final diff = DateTime.now().difference(postedAt);
//     if (diff.inSeconds < 60)  return 'just now';
//     if (diff.inMinutes < 60)  return '${diff.inMinutes}m ago';
//     if (diff.inHours < 24)    return '${diff.inHours}h ago';
//     if (diff.inDays < 7)      return '${diff.inDays}d ago';
//     if (diff.inDays < 30)     return '${(diff.inDays / 7).floor()}w ago';
//     if (diff.inDays < 365)    return '${(diff.inDays / 30).floor()}mo ago';
//     return '${(diff.inDays / 365).floor()}y ago';
//   }

//   /// Short badge: first related coin uppercased, or source initials
//   String get badge {
//     if (relatedCoinIds.isNotEmpty) {
//       return relatedCoinIds.first
//           .split('-')
//           .last
//           .toUpperCase()
//           .substring(0, relatedCoinIds.first.split('-').last.length.clamp(0, 4));
//     }
//     if (sourceName.isNotEmpty) {
//       return sourceName.substring(0, sourceName.length.clamp(0, 3)).toUpperCase();
//     }
//     return 'NEWS';
//   }

//   bool get isGuide => type == 'guide';
// }