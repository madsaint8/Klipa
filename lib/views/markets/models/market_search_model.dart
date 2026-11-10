import 'package:flutter/foundation.dart';

/// `raw` follows every keystroke (drives the text field).
/// `committed` is the debounced value every list filters on.
@immutable
class MarketSearchState {
  const MarketSearchState({this.raw = '', this.committed = ''});

  final String raw;
  final String committed;

  bool get isActive => committed.isNotEmpty;

  /// true while the user is typing and results haven't caught up yet.
  bool get isSettling => raw.trim() != committed;

  MarketSearchState copyWith({String? raw, String? committed}) =>
      MarketSearchState(
        raw: raw ?? this.raw,
        committed: committed ?? this.committed,
      );
}
