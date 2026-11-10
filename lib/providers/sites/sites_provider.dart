import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../data/models/defi_sites/defi_sites_model.dart';
import '../../services/defi/defi_service.dart';


// ── Service singleton ─────────────────────────────────────────────────────────
final defiSiteServiceProvider =
    Provider<DefiSiteService>((_) => DefiSiteService());

// ── All top protocols ─────────────────────────────────────────────────────────
final topProtocolsProvider = FutureProvider<List<DefiSite>>((ref) {
  return ref.read(defiSiteServiceProvider).fetchTopProtocols(limit: 50);
});

// ── Sites filtered by search query ───────────────────────────────────────────
final sitesSearchQueryProvider = StateProvider<String>((_) => '');

final filteredSitesProvider =
    FutureProvider.autoDispose<List<DefiSite>>((ref) {
  final query = ref.watch(sitesSearchQueryProvider).trim();

  return ref
      .read(defiSiteServiceProvider)
      .fetchTopProtocols(limit: 100)
      .then((all) {
    if (query.isEmpty) return all.take(50).toList();
    final q = query.toLowerCase();
    return all
        .where((s) =>
            s.name.toLowerCase().contains(q) ||
            s.category.toLowerCase().contains(q) ||
            (s.url?.toLowerCase().contains(q) ?? false) ||
            s.chains.any((c) => c.toLowerCase().contains(q)))
        .toList();
  });
});

// ── Sites by category ────────────────────────────────────────────────────────
final sitesByCategoryProvider =
    FutureProvider.autoDispose.family<List<DefiSite>, String>(
  (ref, category) =>
      ref.read(defiSiteServiceProvider).fetchByCategory(category),
);