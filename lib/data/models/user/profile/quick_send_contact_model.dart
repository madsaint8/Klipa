import 'package:flutter/material.dart';

class QuickSendContact {
  final String name;
  final String? assetImage;
  final IconData? icon;

  const QuickSendContact({
    required this.name,
    this.assetImage,
    this.icon,
  });
}
