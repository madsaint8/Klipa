import '../models/wallet_transaction_model.dart';

abstract class TransactionService {
  Future<List<WalletTransaction>> loadTransactions();
}