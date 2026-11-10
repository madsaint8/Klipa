import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/operator_model.dart';
import 'vas_provider.dart';

final operatorsProvider =
    FutureProvider.family<
        List<OperatorModel>,
        String>((ref, countryCode) async {
  final repository =
      ref.watch(vasRepositoryProvider);

  return repository.getOperators(countryCode);
});