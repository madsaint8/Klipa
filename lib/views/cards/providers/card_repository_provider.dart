import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repository/card_repository.dart';

/// TODO: return your real API-backed repository here (or override this
/// provider in main.dart / tests). Everything else depends only on the
/// abstract [CardRepository].
final cardRepositoryProvider = Provider<CardRepository>((ref) {
  return MockCardRepository();
});