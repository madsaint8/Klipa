import 'package:flutter/material.dart';
import '../../../services/wallet/wallet_services.dart';

class WalletBalanceWidget extends StatefulWidget {
  const WalletBalanceWidget({super.key});

  @override
  State<WalletBalanceWidget> createState() => _WalletBalanceWidgetState();
}

class _WalletBalanceWidgetState extends State<WalletBalanceWidget> {
  final WalletService _walletService = WalletService.instance;

  static const String _hiddenText = '••••••';

  bool _isVisible = true;
  bool _loading = true;
  double? _ethBalance;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  Future<void> _fetchBalance() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      await _walletService.init(); // safe to call repeatedly

      final address = _walletService.currentAddressHex;
      if (address == null || address.isEmpty) {
        throw StateError('No wallet on this device. Create or import one.');
      }

      final balance = await _walletService.getBalance(address);
      if (!mounted) return;
      setState(() => _ethBalance = balance);
    } catch (e) {
      if (!mounted) return;
      setState(() => _errorMessage = 'Unable to load balance: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String get _balanceText {
    if (!_isVisible) return _hiddenText;
    if (_loading) return 'Loading...';
    return '${(_ethBalance ?? 0).toStringAsFixed(4)} ETH';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _balanceText,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              icon: Icon(
                _isVisible ? Icons.visibility : Icons.visibility_off,
                color: Colors.white,
              ),
              onPressed: () => setState(() => _isVisible = !_isVisible),
            ),
          ],
        ),
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
        TextButton.icon(
          onPressed: _loading ? null : _fetchBalance,
          icon: const Icon(Icons.refresh, color: Colors.white70),
          label: const Text('Refresh', style: TextStyle(color: Colors.white70)),
        ),
      ],
    );
  }
}