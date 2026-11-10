import 'package:flutter/material.dart';
import '../models/operator_model.dart';

class OperatorCard extends StatelessWidget {
  final OperatorModel operator;

  const OperatorCard({
    super.key,
    required this.operator,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Image.network(
          operator.logoUrl,
          width: 40,
        ),
        title: Text(operator.name),
        subtitle: Text(
          operator.countryCode,
        ),
      ),
    );
  }
}