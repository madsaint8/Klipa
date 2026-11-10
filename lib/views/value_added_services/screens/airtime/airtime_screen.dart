import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/operator_provider.dart';
import 'widgets/operator_card.dart';

class AirtimeScreen extends ConsumerWidget {
  const AirtimeScreen({super.key});

  @override
  Widget build(BuildContext context,
      WidgetRef ref) {
    final operators =
        ref.watch(operatorsProvider("ZA"));

    return Scaffold(
      appBar: AppBar(
        title: const Text("Airtime & Data"),
      ),
      body: operators.when(
        data: (items) {
          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (_, index) {
              return OperatorCard(
                operator: items[index],
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (e, _) => Center(
          child: Text(e.toString()),
        ),
      ),
    );
  }
}