import 'package:flutter/material.dart';

class QuickServiceModel {
  final String title;
  final IconData icon;
  final String routeName;
  final Color? accentColor;

  const QuickServiceModel({
    required this.title,
    required this.icon,
    required this.routeName,
    this.accentColor,
  });
}