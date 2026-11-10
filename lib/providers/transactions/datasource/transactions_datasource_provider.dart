import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/datasources/remote/transactions_remote_datasource.dart';

final transactionsDatasourceProvider = Provider<TransactionsRemoteDatasource>(
  (_) => TransactionsRemoteDatasource(),
);