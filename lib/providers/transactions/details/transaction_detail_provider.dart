import 'package:flutter_riverpod/legacy.dart';
import '../../../data/models/transaction/transaction_model.dart';

// Holds the selected transaction for the detail page
final selectedTransactionProvider =
    StateProvider<TransactionModel?>((ref) => null);