import 'package:flutter/material.dart';

class PaymentMethods {
  final String name;
  final String? assetImage;
  final IconData? icon;

  const PaymentMethods({
    required this.name,
    this.assetImage,
    this.icon,
  });
}