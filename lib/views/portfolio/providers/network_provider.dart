import 'package:flutter_riverpod/legacy.dart';
import '../models/network_model.dart';

final networkProvider =
    StateProvider<WalletNetwork>((ref) {
  return WalletNetwork.ethereum;
});