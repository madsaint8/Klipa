import 'package:flutter/material.dart';

/// A service that can be shown under "Quick Services".
///
/// [id] is the stable key persisted for favourites. Never reuse or rename an
/// id once shipped (titles, icons and routes can change freely, ids can't).
@immutable
class QuickServiceModel {
  const QuickServiceModel({
    required this.id,
    required this.title,
    required this.icon,
    required this.routeName,
    this.accentColor,
    this.shortTitle,
  });

  final String id;
  final String title;

  /// Compact label for grid tiles (falls back to [title]).
  final String? shortTitle;
  String get label => shortTitle ?? title;
  final IconData icon;
  final String routeName;
  final Color? accentColor;
}