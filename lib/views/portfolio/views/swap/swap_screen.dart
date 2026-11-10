import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/wallet_provider.dart';

// ───────────────────────── Palette ─────────────────────────

const _sky = Color(0xFF38BDF8);
const _skyDeep = Color(0xFF0284C7);
const _skyPale = Color(0xFFE0F2FE);
const _ink = Color(0xFF0C4A6E);
const _muted = Color(0xFF64748B);

// ───────────────────────── Models ─────────────────────────

class _SwapToken {
  final String symbol;
  final String name;
  final String? contractAddress; // null = native ETH (or not configured yet)
  final Color color;
  const _SwapToken(this.symbol, this.name, this.contractAddress, this.color);

  bool get isNative => symbol == 'ETH';
}

const _tokens = [
  _SwapToken('ETH', 'Ethereum', null, Color(0xFF627EEA)),
  _SwapToken('USDC', 'USD Coin (test)', null, Color(0xFF2775CA)), // TODO: Sepolia address
  _SwapToken('DAI', 'Dai (test)', null, Color(0xFFF5AC37)), // TODO: Sepolia address
];

/// NOTE: no on-chain swap is wired up yet. To make `_executeSwap` live you need:
///   1. A deployed Uniswap-V2/V3-style router address for Sepolia
///   2. ERC20 `approve()` for the input token (skip if input is ETH)
///   3. `swapExactETHForTokens` / `swapExactTokensForTokens` via web3dart
class SwapScreen extends ConsumerStatefulWidget {
  const SwapScreen({super.key});

  @override
  ConsumerState<SwapScreen> createState() => _SwapScreenState();
}

class _SwapScreenState extends ConsumerState<SwapScreen> {
  final _fromController = TextEditingController();
  final _toController = TextEditingController();

  _SwapToken _from = _tokens[0];
  _SwapToken _to = _tokens[1];
  double _turns = 0;

  @override
  void initState() {
    super.initState();
    _fromController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    super.dispose();
  }

  double? get _amount => double.tryParse(_fromController.text.trim());

  ({String label, bool enabled}) _buttonState(double? balance) {
    final a = _amount;
    if (_fromController.text.isEmpty) return (label: 'Enter an amount', enabled: false);
    if (a == null || a <= 0) return (label: 'Enter a valid amount', enabled: false);
    if (balance != null && a > balance) return (label: 'Insufficient balance', enabled: false);
    return (label: 'Swap', enabled: true);
  }

  void _flip() {
    setState(() {
      final tmp = _from;
      _from = _to;
      _to = tmp;
      _turns += 0.5;
    });
  }

  Future<void> _pickToken({required bool isFrom}) async {
    final selected = await showModalBottomSheet<_SwapToken>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _TokenSheet(current: isFrom ? _from : _to),
    );
    if (selected == null) return;
    setState(() {
      if (isFrom) {
        _from = selected;
        if (_to == selected) _to = _tokens.firstWhere((t) => t != selected);
      } else {
        _to = selected;
        if (_from == selected) _from = _tokens.firstWhere((t) => t != selected);
      }
    });
  }

  Future<void> _executeSwap() async {
    // TODO: plug in router call here, roughly:
    //
    // final credentials = ref.read(walletProvider).credentials!;
    // final router = DeployedContract(routerAbi, routerAddress);
    // await client.sendTransaction(credentials, Transaction.callContract(
    //   contract: router,
    //   function: router.function('swapExactETHForTokens'),
    //   parameters: [...],
    //   value: EtherAmount.fromBigInt(EtherUnit.wei, amountInWei),
    // ), chainId: sepoliaChainId);
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final fromBalance = _from.isNative ? wallet.balanceEth : null;
    final btn = _buttonState(fromBalance);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Swap', style: TextStyle(fontWeight: FontWeight.w700)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        foregroundColor: _ink,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: Stack(
        children: [
          const _SkyBackdrop(),
          SafeArea(
            // Centered vertically → the swap button sits mid-screen, in thumb reach.
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                child: _Glass(
                  radius: 36,
                  padding: const EdgeInsets.all(14),
                  alpha: 120,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: [
                              _TokenCard(
                                token: _from,
                                controller: _fromController,
                                editable: true,
                                balance: fromBalance,
                                onTokenTap: () => _pickToken(isFrom: true),
                              ),
                              const SizedBox(height: 10),
                              _TokenCard(
                                token: _to,
                                controller: _toController,
                                editable: false,
                                onTokenTap: () => _pickToken(isFrom: false),
                              ),
                            ],
                          ),
                          _FlipButton(turns: _turns, onTap: _flip),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _SwapButton(
                        label: btn.label,
                        enabled: btn.enabled,
                        onPressed: _executeSwap,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ───────────────────────── Widgets ─────────────────────────

/// Reusable frosted-glass surface.
class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final int alpha; // white tint strength 0–255
  const _Glass({
    required this.child,
    required this.radius,
    required this.padding,
    this.alpha = 150,
  });

  @override
  Widget build(BuildContext context) {
    final r = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: r,
        boxShadow: [
          BoxShadow(
            color: _skyDeep.withAlpha(36),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: r,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Container(
            padding: padding,
            decoration: BoxDecoration(
              borderRadius: r,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Colors.white.withAlpha(alpha + 50), Colors.white.withAlpha(alpha)],
              ),
              border: Border.all(color: Colors.white.withAlpha(200), width: 1.2),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// White page with soft blurred sky-blue blobs so the glass has something to refract.
class _SkyBackdrop extends StatelessWidget {
  const _SkyBackdrop();

  Widget _blob(double size, Color color) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      );

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 60, sigmaY: 60),
        child: Stack(
          children: [
            Positioned(top: -60, right: -70, child: _blob(280, _sky.withAlpha(150))),
            Positioned(top: 260, left: -110, child: _blob(260, const Color(0xFF7DD3FC).withAlpha(140))),
            Positioned(bottom: -80, right: -40, child: _blob(300, _skyDeep.withAlpha(90))),
          ],
        ),
      ),
    );
  }
}

class _TokenCard extends StatelessWidget {
  final _SwapToken token;
  final TextEditingController controller;
  final bool editable;
  final double? balance;
  final VoidCallback onTokenTap;

  const _TokenCard({
    required this.token,
    required this.controller,
    required this.editable,
    required this.onTokenTap,
    this.balance,
  });

  @override
  Widget build(BuildContext context) {
    return _Glass(
      radius: 26,
      alpha: 140,
      padding: const EdgeInsets.fromLTRB(14, 14, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _TokenPill(token: token, onTap: onTokenTap),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: controller,
                  enabled: editable,
                  textAlign: TextAlign.end,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  cursorColor: _skyDeep,
                  decoration: const InputDecoration(
                    hintText: '0.0',
                    hintStyle: TextStyle(color: Color(0x4D0C4A6E)),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  style: const TextStyle(
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    color: _ink,
                  ),
                ),
              ),
            ],
          ),
          if (balance != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: Text(
                'Balance: ${balance!.toStringAsFixed(4)}',
                style: const TextStyle(color: _muted, fontSize: 13),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TokenAvatar extends StatelessWidget {
  final _SwapToken token;
  final double size;
  const _TokenAvatar(this.token, {this.size = 34});

  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(shape: BoxShape.circle, color: token.color),
        child: Text(
          token.symbol.substring(0, 1),
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: size * 0.45,
          ),
        ),
      );
}

class _TokenPill extends StatelessWidget {
  final _SwapToken token;
  final VoidCallback onTap;
  const _TokenPill({required this.token, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30),
      child: Container(
        padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(170),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: _sky.withAlpha(80)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _TokenAvatar(token),
            const SizedBox(width: 10),
            Text(
              token.symbol,
              style: const TextStyle(
                color: _ink,
                fontSize: 17,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 2),
            const Icon(Icons.keyboard_arrow_down_rounded, color: _skyDeep, size: 20),
          ],
        ),
      ),
    );
  }
}

class _FlipButton extends StatelessWidget {
  final double turns;
  final VoidCallback onTap;
  const _FlipButton({required this.turns, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 5),
        boxShadow: [BoxShadow(color: _sky.withAlpha(120), blurRadius: 20)],
      ),
      child: Material(
        color: _skyDeep,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: AnimatedRotation(
              turns: turns,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutBack,
              child: const Icon(Icons.swap_vert_rounded, color: Colors.white, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class _SwapButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onPressed;
  const _SwapButton({required this.label, required this.enabled, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: double.infinity,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(29),
        gradient: enabled ? const LinearGradient(colors: [_sky, _skyDeep]) : null,
        color: enabled ? null : _skyPale,
        boxShadow: enabled
            ? [BoxShadow(color: _skyDeep.withAlpha(90), blurRadius: 22, offset: const Offset(0, 8))]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(29),
          onTap: enabled ? onPressed : null,
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: enabled ? Colors.white : _skyDeep.withAlpha(150),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TokenSheet extends StatelessWidget {
  final _SwapToken current;
  const _TokenSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          color: Colors.white.withAlpha(225),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: _sky.withAlpha(120),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Select a token',
                style: TextStyle(color: _ink, fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              for (final t in _tokens)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: _TokenAvatar(t, size: 40),
                  title: Text(t.symbol,
                      style: const TextStyle(color: _ink, fontWeight: FontWeight.w600)),
                  subtitle: Text(t.name, style: const TextStyle(color: _muted)),
                  trailing: t == current
                      ? const Icon(Icons.check_circle_rounded, color: _skyDeep)
                      : null,
                  onTap: () => Navigator.pop(context, t),
                ),
            ],
          ),
        ),
      ),
    );
  }
}