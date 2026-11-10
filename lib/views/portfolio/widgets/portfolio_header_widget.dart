import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/wallet_provider.dart';
import '../views/more/more_screen.dart';
import '../views/receive/receive_screen.dart';
import '../views/send/send_screen.dart';
import '../views/swap/swap_screen.dart';

class PortfolioHeader extends ConsumerWidget {
  final VoidCallback? onVisibilityToggle;

  const PortfolioHeader({
    super.key,
    this.onVisibilityToggle,
  });

  String _formatEth(double value) {
    if (value == 0) return '0.000000';

    return value.toStringAsFixed(6);
  }

  void _requireWallet(
    BuildContext context,
    WalletState wallet,
    VoidCallback onReady,
  ) {
    if (wallet.hasWallet) {
      onReady();
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'No wallet found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Your crypto wallet could not be loaded.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MoreScreen(),
                  ),
                );
              },
              child: const Text('Wallet settings'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);

    final balance = wallet.balanceEth;
    final formattedBalance = _formatEth(balance);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 18,
            sigmaY: 18,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(
              vertical: 28,
              horizontal: 20,
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF14AAFA).withOpacity(.55),
                  const Color(0xFF52B1E4).withOpacity(.35),
                  const Color(0xFFD4E6F3).withOpacity(.25),
                ],
              ),
              border: Border.all(
                color: Colors.white.withOpacity(.6),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF56A9E8).withOpacity(.35),
                  blurRadius: 30,
                  spreadRadius: -4,
                  offset: const Offset(0, 18),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(.08),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                GestureDetector(
                  onTap: onVisibilityToggle,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Portfolio value',
                        style: TextStyle(
                          color: const Color(0xFF0B4E77)
                              .withOpacity(.85),
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(
                        Icons.remove_red_eye_outlined,
                        color: const Color(0xFF0B4E77)
                            .withOpacity(.85),
                        size: 16,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                /// LIVE BLOCKCHAIN BALANCE
                if (wallet.isLoading && !wallet.hasWallet)
                  const SizedBox(
                    height: 48,
                    width: 48,
                    child: CircularProgressIndicator(),
                  )
                else
                  Text(
                    '$formattedBalance ETH',
                    style: const TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0B3C5D),
                    ),
                  ),

                const SizedBox(height: 10),

                if (wallet.error != null)
                  Text(
                    wallet.error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.redAccent,
                      fontSize: 12,
                    ),
                  ),

                const SizedBox(height: 12),

                _WalletBalanceRow(
                  wallet: wallet,
                ),

                const SizedBox(height: 24),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _ActionButton(
                      icon: Icons.arrow_upward_rounded,
                      label: 'Send',
                      onTap: () => _requireWallet(
                        context,
                        wallet,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SendScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.swap_horiz_rounded,
                      label: 'Swap',
                      onTap: () => _requireWallet(
                        context,
                        wallet,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SwapScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.arrow_downward_rounded,
                      label: 'Receive',
                      iconColor: const Color(0xFF1FAE6B),
                      onTap: () => _requireWallet(
                        context,
                        wallet,
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ReceiveScreen(),
                            ),
                          );
                        },
                      ),
                    ),
                    _ActionButton(
                      icon: Icons.grid_view_rounded,
                      label: 'More',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MoreScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _WalletBalanceRow extends StatelessWidget {
  final WalletState wallet;

  const _WalletBalanceRow({
    required this.wallet,
  });

  @override
  Widget build(BuildContext context) {
    if (!wallet.hasWallet) {
      return const Text(
        'Loading wallet...',
        style: TextStyle(
          color: Color(0xFF0B4E77),
          fontSize: 12,
        ),
      );
    }

    final address = wallet.address!;

    final shortAddress =
        '${address.substring(0, 6)}...${address.substring(address.length - 4)}';

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.account_balance_wallet_outlined,
          size: 14,
          color: Color(0xFF0B4E77),
        ),
        const SizedBox(width: 6),
        GestureDetector(
          onTap: () async {
            await Clipboard.setData(
              ClipboardData(text: address),
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Wallet address copied'),
                ),
              );
            }
          },
          child: Text(
            shortAddress,
            style: const TextStyle(
              color: Color(0xFF0B4E77),
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
        if (wallet.isLoading) ...[
          const SizedBox(width: 8),
          const SizedBox(
            width: 10,
            height: 10,
            child: CircularProgressIndicator(
              strokeWidth: 1.5,
            ),
          ),
        ],
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final Color iconColor;

  const _ActionButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.iconColor = const Color(0xFF0B3C5D),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(.25),
              border: Border.all(
                color: Colors.white.withOpacity(.5),
              ),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF0B3C5D),
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}