import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/config/theme/colors/app_colors.dart';
import '../providers/favourite_services_provider.dart';
import 'quick_service_catalog.dart';
import '../models/quick_service_model.dart';
import '../sky_theme.dart';

/// Add, remove and reorder quick services. Every change is applied (and saved)
/// immediately, so the home screen is already up to date when you go back.
class EditFavouritesScreen extends ConsumerWidget {
  const EditFavouritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favourites = ref.watch(favouriteServicesProvider).value ?? const [];
    final favouriteIds = favourites.map((s) => s.id).toSet();
    final others =
        quickServiceCatalog.where((s) => !favouriteIds.contains(s.id)).toList();
    final notifier = ref.read(favouriteIdsProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: const Text(
          'Edit Quick Services',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          TextButton(
            onPressed: notifier.resetToDefault,
            child: const Text('Reset'),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: CustomScrollView(
              slivers: [
                const _SectionHeader('Your quick services', 'Drag to reorder'),
                if (favourites.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Text(
                        'Nothing here yet. Add a service from the list below.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  SliverReorderableList(
                    itemCount: favourites.length,
                    onReorder: notifier.reorder,
                    itemBuilder: (context, index) {
                      final s = favourites[index];
                      return Material(
                        key: ValueKey(s.id),
                        color: AppColors.white,
                        child: ListTile(
                          leading: _IconBadge(service: s),
                          title: Text(s.title),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                tooltip: 'Remove ${s.title}',
                                icon: const Icon(
                                  Icons.remove_circle_outline,
                                  color: Colors.red,
                                ),
                                onPressed: () => notifier.remove(s.id),
                              ),
                              ReorderableDragStartListener(
                                index: index,
                                child: const Padding(
                                  padding: EdgeInsets.all(8),
                                  child: Icon(Icons.drag_handle, color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                if (others.isNotEmpty) ...[
                  const _SectionHeader('More services', 'Tap + to add'),
                  SliverList.builder(
                    itemCount: others.length,
                    itemBuilder: (context, i) {
                      final s = others[i];
                      return ListTile(
                        key: ValueKey(s.id),
                        leading: _IconBadge(service: s),
                        title: Text(s.title),
                        trailing: IconButton(
                          tooltip: 'Add ${s.title}',
                          icon: const Icon(
                            Icons.add_circle_outline,
                            color: AppColors.buttonPrimary,
                          ),
                          onPressed: () => notifier.add(s.id),
                        ),
                        onTap: () => notifier.add(s.id),
                      );
                    },
                  ),
                ],
                const SliverToBoxAdapter(child: SizedBox(height: 24)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title, this.hint);
  final String title;
  final String hint;

  @override
  Widget build(BuildContext context) => SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              Text(hint, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          ),
        ),
      );
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.service});
  final QuickServiceModel service;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: SkyTheme.iconGradient,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(service.icon, color: Colors.white, size: 22),
    );
  }
}