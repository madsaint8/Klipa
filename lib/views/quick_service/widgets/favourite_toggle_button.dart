import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/favourite_services_provider.dart';
import 'quick_service_catalog.dart';

/// Heart button that adds/removes a service from Quick Services. Drop it into
/// any screen's AppBar:
///
///   actions: [FavouriteToggleButton(serviceId: 'airtime')]
///
/// The home screen updates instantly because both read the same provider.
class FavouriteToggleButton extends ConsumerWidget {
  const FavouriteToggleButton({super.key, required this.serviceId});

  final String serviceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(isFavouriteProvider(serviceId));
    final title = quickServiceById[serviceId]?.title ?? 'Service';

    return IconButton(
      tooltip: isFav ? 'Remove from Quick Services' : 'Add to Quick Services',
      icon: Icon(
        isFav ? Icons.favorite : Icons.favorite_border,
        color: isFav ? Colors.red : null,
      ),
      onPressed: () {
        ref.read(favouriteIdsProvider.notifier).toggle(serviceId);
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              duration: const Duration(seconds: 2),
              content: Text(
                isFav
                    ? '$title removed from Quick Services'
                    : '$title added to Quick Services',
              ),
            ),
          );
      },
    );
  }
}