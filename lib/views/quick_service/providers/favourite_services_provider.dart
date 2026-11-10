import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/quick_service_catalog.dart';
import '../models/quick_service_model.dart';

const _prefsKey = 'quick_services.favourites.v1';

/// Ordered list of favourite service ids: the single source of truth.
///
/// * Persisted on the device (ids only; icons/colors come from the catalog).
/// * Updates are optimistic: the UI changes instantly, saving happens after.
/// * Unknown ids (e.g. a service removed in a later app version) are dropped.
/// * An explicitly empty list is respected; defaults only apply when nothing
///   has ever been saved.
final favouriteIdsProvider =
    AsyncNotifierProvider<FavouriteIdsNotifier, List<String>>(
  FavouriteIdsNotifier.new,
);

class FavouriteIdsNotifier extends AsyncNotifier<List<String>> {
  @override
  Future<List<String>> build() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getStringList(_prefsKey);
      if (saved == null) return defaultFavouriteIds;
      return saved.where(quickServiceById.containsKey).toSet().toList();
    } catch (_) {
      return defaultFavouriteIds;
    }
  }

  List<String> get _current => state.value ?? defaultFavouriteIds;

  bool isFavourite(String id) => _current.contains(id);

  Future<void> toggle(String id) => isFavourite(id) ? remove(id) : add(id);

  Future<void> add(String id) async {
    if (!quickServiceById.containsKey(id) || isFavourite(id)) return;
    await _commit([..._current, id]);
  }

  Future<void> remove(String id) =>
      _commit(_current.where((e) => e != id).toList());

  /// [newIndex] follows Flutter's ReorderableList convention.
  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [..._current];
    if (oldIndex < 0 || oldIndex >= list.length) return;
    if (newIndex > oldIndex) newIndex -= 1;
    list.insert(newIndex.clamp(0, list.length - 1), list.removeAt(oldIndex));
    await _commit(list);
  }

  Future<void> resetToDefault() => _commit(defaultFavouriteIds);

  Future<void> _commit(List<String> ids) async {
    state = AsyncData(List.unmodifiable(ids)); // UI updates immediately
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_prefsKey, ids);
    } catch (_) {/* best effort; state stays correct for this session */}
  }
}

/// Favourites resolved to full models, in the user's order.
final favouriteServicesProvider =
    Provider<AsyncValue<List<QuickServiceModel>>>((ref) {
  return ref.watch(favouriteIdsProvider).whenData(
        (ids) => ids
            .map((id) => quickServiceById[id])
            .whereType<QuickServiceModel>()
            .toList(),
      );
});

/// Whether one service is a favourite. Rebuilds only when *that* answer
/// changes, so a heart button doesn't rebuild when other items change.
final isFavouriteProvider = Provider.family.autoDispose<bool, String>(
  (ref, id) => ref.watch(
    favouriteIdsProvider.select(
      (a) => (a.value ?? defaultFavouriteIds).contains(id),
    ),
  ),
);