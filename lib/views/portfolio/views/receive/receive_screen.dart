import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/wallet_provider.dart';

// ───────────────────────── Palette ─────────────────────────

const _sky = Color(0xFF38BDF8);
const _skyDeep = Color(0xFF0284C7);
const _skyPale = Color(0xFFE0F2FE);
const _ink = Color(0xFF0C4A6E);
const _muted = Color(0xFF64748B);

/// Shows the connected wallet's address as a scannable QR code so the user
/// can receive funds.
///
/// Requires in pubspec.yaml:
///   qr_flutter: ^4.1.0
class ReceiveScreen extends ConsumerStatefulWidget {
  const ReceiveScreen({super.key});

  @override
  ConsumerState<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends ConsumerState<ReceiveScreen> {
  bool _copied = false;

  Future<void> _copy(String address) async {
    await Clipboard.setData(ClipboardData(text: address));
    HapticFeedback.lightImpact();
    if (!mounted) return;
    setState(() => _copied = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final address = ref.watch(walletProvider).address;

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Receive', style: TextStyle(fontWeight: FontWeight.w700)),
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
            child: Center(
              child: address == null
                  ? const _EmptyState()
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                      child: _Glass(
                        radius: 36,
                        padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _QrCard(address: address),
                            const SizedBox(height: 22),
                            const Text(
                              'Your Sepolia address',
                              style: TextStyle(
                                color: _muted,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 10),
                            _AddressChip(address: address),
                            const SizedBox(height: 16),
                            _CopyButton(copied: _copied, onPressed: () => _copy(address)),
                            const SizedBox(height: 16),
                            const _Notice(),
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

class _QrCard extends StatelessWidget {
  final String address;
  const _QrCard({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _sky.withAlpha(80), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _sky.withAlpha(70),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: QrImageView(
        data: address,
        version: QrVersions.auto,
        size: 220,
        backgroundColor: Colors.white,
        errorCorrectionLevel: QrErrorCorrectLevel.M,
        eyeStyle: const QrEyeStyle(
          eyeShape: QrEyeShape.circle,
          color: _skyDeep,
        ),
        dataModuleStyle: const QrDataModuleStyle(
          dataModuleShape: QrDataModuleShape.circle,
          color: _ink,
        ),
      ),
    );
  }
}

class _AddressChip extends StatelessWidget {
  final String address;
  const _AddressChip({required this.address});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(170),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _sky.withAlpha(70)),
      ),
      child: SelectableText(
        address,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'monospace',
          fontSize: 13.5,
          height: 1.4,
          color: _ink,
        ),
      ),
    );
  }
}

class _CopyButton extends StatelessWidget {
  final bool copied;
  final VoidCallback onPressed;
  const _CopyButton({required this.copied, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: copied
            ? const LinearGradient(colors: [Color(0xFF34D399), Color(0xFF059669)])
            : const LinearGradient(colors: [_sky, _skyDeep]),
        boxShadow: [
          BoxShadow(
            color: (copied ? const Color(0xFF059669) : _skyDeep).withAlpha(80),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: onPressed,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  copied ? Icons.check_rounded : Icons.copy_rounded,
                  key: ValueKey(copied),
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                copied ? 'Copied' : 'Copy address',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Notice extends StatelessWidget {
  const _Notice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: _skyPale.withAlpha(200),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline_rounded, size: 16, color: _skyDeep),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Only send Sepolia testnet ETH or Sepolia test tokens to this address.',
              style: TextStyle(fontSize: 12, color: _ink, height: 1.35),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 18),
      child: _Glass(
        radius: 30,
        padding: EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_balance_wallet_outlined, size: 48, color: _skyDeep),
            SizedBox(height: 12),
            Text(
              'No wallet connected.',
              style: TextStyle(color: _ink, fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reusable frosted-glass surface (same as the swap screen).
class _Glass extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;
  final int alpha;
  const _Glass({
    required this.child,
    required this.radius,
    required this.padding,
    this.alpha = 120,
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

/// White page with soft blurred sky-blue blobs for the glass to refract.
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