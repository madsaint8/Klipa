import 'package:flutter/material.dart';

import '../data/models/wallet/wallet_ui_model.dart';
import '../services/wallet/wallet_services.dart';

class HomeViewModel extends ChangeNotifier {
  final WalletService _walletService = WalletService.instance;

  WalletUiModel? wallet;
  bool isLoading = true;
  bool isBalanceVisible = true;
  String? errorMessage;

  /// Safe to call more than once.
  Future<void> init() async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      await _walletService.init();

      final address = _walletService.currentAddressHex;
      if (address == null || address.isEmpty) {
        wallet = null; // no wallet created/imported yet
        return;
      }

      final balance = await _walletService.getBalance(address);

      wallet = WalletUiModel(
        address: address,
        balance: balance.toStringAsFixed(4),
      );
    } catch (e) {
      debugPrint('HomeViewModel error: $e');
      errorMessage = 'Unable to load balance. Please try again.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshBalance() async {
    final address = _walletService.currentAddressHex;
    if (address == null) return;

    try {
      final balance = await _walletService.getBalance(address);
      wallet = WalletUiModel(
        address: address,
        balance: balance.toStringAsFixed(4),
      );
      errorMessage = null;
    } catch (e) {
      debugPrint('HomeViewModel refresh error: $e');
      errorMessage = 'Unable to refresh balance.';
    }
    notifyListeners();
  }

  void toggleBalance() {
    isBalanceVisible = !isBalanceVisible;
    notifyListeners();
  }

  Future<void> logout() async {
    await _walletService.logout();
    wallet = null;
    errorMessage = null;
    notifyListeners();
  }
}