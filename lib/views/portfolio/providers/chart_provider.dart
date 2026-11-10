import 'package:flutter_riverpod/flutter_riverpod.dart';

/// true = bar chart (trend), false = pie chart (allocation)
class ChartNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void show({required bool bar}) => state = bar;
}

final chartProvider = NotifierProvider<ChartNotifier, bool>(ChartNotifier.new);