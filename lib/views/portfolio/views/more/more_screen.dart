import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paywave/services/wallet/wallet_services.dart';

import '../../../../services/auth/auth_service.dart';
import '../../providers/wallet_provider.dart';

class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  Future<void> _confirmExport(BuildContext context, WalletService service) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Export private key?'),
        content: const Text(
          'Anyone with this key has full control of this wallet\'s funds. '
          'Never share it or paste it anywhere untrusted.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Show it')),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    final wallet = await service.fetchWallet();
    final key = wallet?['privateKey'] as String?;
    if (key == null || !context.mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Private key'),
        content: SelectableText(key, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
        actions: [
          TextButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: key));
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied')));
            },
            child: const Text('Copy'),
          ),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final service = ref.read(walletServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('More')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (wallet.isLoading && !wallet.hasWallet) ...[
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              ),
            ] else if (!wallet.hasWallet) ...[
              // Every account gets a wallet at sign-up, so if we land here
              // it means restoring it from this device/session failed.
              const Text('Wallet not loaded', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(wallet.error ?? 'Could not find a wallet for this account.', style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh),
                label: const Text('Reload wallet'),
                onPressed: () => ref.read(walletProvider.notifier).reload(),
              ),
            ] else ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(service.networkName, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      const SizedBox(height: 6),
                      SelectableText(wallet.address!, style: const TextStyle(fontFamily: 'monospace')),
                      const SizedBox(height: 8),
                      Text('${wallet.balanceEth.toStringAsFixed(6)} ETH', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ListTile(
                leading: const Icon(Icons.refresh),
                title: const Text('Refresh balance'),
                onTap: () => ref.read(walletProvider.notifier).refreshBalance(),
              ),
              ListTile(
                leading: const Icon(Icons.open_in_new),
                title: const Text('View on Sepolia Etherscan'),
                subtitle: Text(
                  service.explorerAddressUrl(wallet.address!),
                  style: const TextStyle(fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: service.explorerAddressUrl(wallet.address!)));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Explorer link copied — open it in a browser')),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.key, color: Colors.orange),
                title: const Text('Export private key'),
                onTap: () => _confirmExport(context, service),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log out', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  await AuthServices().logout();
                  // walletProvider clears itself automatically via the
                  // Supabase signedOut auth-state event.
                },
              ),
            ],
            if (wallet.error != null && wallet.hasWallet) ...[
              const SizedBox(height: 16),
              Text(wallet.error!, style: const TextStyle(color: Colors.red)),
            ],
          ],
        ),
      ),
    );
  }
}