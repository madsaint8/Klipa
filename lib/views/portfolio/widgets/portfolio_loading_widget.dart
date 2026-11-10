import 'package:flutter/material.dart';

class PortfolioLoading extends StatelessWidget {
  const PortfolioLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}