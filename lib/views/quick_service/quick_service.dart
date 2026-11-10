import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/edit_favourites_screen.dart';
import 'providers/favourite_services_provider.dart';
import 'widgets/glass_container.dart';
import 'widgets/quick_service_catalog.dart';
import 'models/quick_service_model.dart';
import 'widgets/quick_service_tile.dart';
import 'sky_theme.dart';

/// Glassmorphic "Quick Services" panel.
///
/// * Sky-blue gradient panel with soft circles so the glass tiles have
///   something to blur.
/// * Dense grid: 3–8 columns chosen from the available width (4 on most
///   phones). Two rows are shown by default; if there are more favourites the
///   last slot becomes a "More +N" tile that expands the panel in place.
/// * Always reflects the user's favourites live (see favouriteServicesProvider).
class QuickService extends ConsumerStatefulWidget {
  const QuickService({super.key, this.title = 'Quick Services'});

  final String title;

  @override
  ConsumerState<QuickService> createState() => _QuickServiceState();
}

class _QuickServiceState extends ConsumerState<QuickService> {
  static const double _spacing = 10;
  static const double _minTileWidth = 64;
  static const int _collapsedRows = 2;

  bool _expanded = false;

  void _openEditor() => Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => const EditFavouritesScreen()),
      );

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(favouriteServicesProvider).value;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: SkyTheme.sky500.withValues(alpha: 0.25),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: DecoratedBox(
            decoration: const BoxDecoration(gradient: SkyTheme.panelGradient),
            child: Stack(
              children: [
                // Colour behind the glass; this is what gets blurred.
                Positioned(
                  top: -40,
                  right: -30,
                  child: _circle(150, [
                    Colors.white.withValues(alpha: 0.8),
                    Colors.white.withValues(alpha: 0.1),
                  ]),
                ),
                Positioned(
                  bottom: -50,
                  left: -40,
                  child: _circle(170, [
                    SkyTheme.sky400.withValues(alpha: 0.75),
                    SkyTheme.sky500.withValues(alpha: 0.15),
                  ]),
                ),
                Positioned(
                  top: 60,
                  left: -25,
                  child: _circle(90, [
                    SkyTheme.sky300.withValues(alpha: 0.9),
                    Colors.white.withValues(alpha: 0.1),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _header(),
                      const SizedBox(height: 14),
                      LayoutBuilder(
                        builder: (context, constraints) =>
                            _body(items, constraints.maxWidth),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _header() => Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: SkyTheme.ink,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your favourite shortcuts',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: SkyTheme.ink.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GlassContainer(
            borderRadius: 20,
            blur: 10,
            opacity: 0.4,
            onTap: _openEditor,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.tune_rounded, size: 15, color: SkyTheme.sky600),
                SizedBox(width: 5),
                Text(
                  'Edit',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: SkyTheme.sky600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );

  // ── Grid ───────────────────────────────────────────────────────────────────

  Widget _body(List<QuickServiceModel>? items, double width) {
    final cols =
        ((width + _spacing) / (_minTileWidth + _spacing)).floor().clamp(3, 8);

    if (items != null && items.isEmpty) return _emptyState();

    final tiles = <Widget>[];
    if (items == null) {
      // Loading: placeholders with the same geometry, so nothing jumps.
      for (var i = 0; i < defaultFavouriteIds.length; i++) {
        tiles.add(const GlassContainer(
          borderRadius: 18,
          blur: 10,
          opacity: 0.3,
          child: SizedBox(height: 82),
        ));
      }
    } else {
      final cap = cols * _collapsedRows;
      final overflow = items.length > cap;

      if (!overflow || _expanded) {
        tiles.addAll(items.map((s) => QuickServiceTile(key: ValueKey(s.id), service: s)));
        if (overflow) {
          tiles.add(GlassActionTile(
            key: const ValueKey('less'),
            icon: Icons.keyboard_arrow_up_rounded,
            label: 'Less',
            filled: false,
            onTap: () => setState(() => _expanded = false),
          ));
        }
      } else {
        final shown = items.take(cap - 1).toList();
        tiles.addAll(shown.map((s) => QuickServiceTile(key: ValueKey(s.id), service: s)));
        tiles.add(GlassActionTile(
          key: const ValueKey('more'),
          icon: Icons.apps_rounded,
          label: 'More +${items.length - shown.length}',
          filled: false,
          onTap: () => setState(() => _expanded = true),
        ));
      }
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      alignment: Alignment.topCenter,
      child: Column(children: _rows(tiles, cols)),
    );
  }

  /// Equal-width columns via Expanded, so tiles fill the panel exactly.
  List<Widget> _rows(List<Widget> tiles, int cols) {
    final rows = <Widget>[];
    for (var i = 0; i < tiles.length; i += cols) {
      final slice = tiles.sublist(i, math.min(i + cols, tiles.length));
      if (rows.isNotEmpty) rows.add(const SizedBox(height: _spacing));
      rows.add(Row(
        children: [
          for (var j = 0; j < cols; j++) ...[
            if (j > 0) const SizedBox(width: _spacing),
            Expanded(child: j < slice.length ? slice[j] : const SizedBox.shrink()),
          ],
        ],
      ));
    }
    return rows;
  }

  Widget _emptyState() => GlassContainer(
        borderRadius: 18,
        padding: const EdgeInsets.all(20),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            children: [
              const Icon(Icons.favorite_border_rounded,
                  color: SkyTheme.sky600, size: 28),
              const SizedBox(height: 8),
              const Text(
                'No quick services yet',
                style: TextStyle(fontWeight: FontWeight.w700, color: SkyTheme.ink),
              ),
              const SizedBox(height: 4),
              TextButton(
                onPressed: _openEditor,
                child: const Text('Add services'),
              ),
            ],
          ),
        ),
      );

  Widget _circle(double size, List<Color> colors) => IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: colors,
            ),
          ),
        ),
      );
}