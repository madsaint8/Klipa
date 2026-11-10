import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:paywave/services/wallet/wallet_services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WalletState {
  final String? address;
  final double balanceEth;
  final bool isLoading;

  /// True only when this device holds a key that controls [address].
  final bool canSign;

  /// An encrypted backup exists but this device has no key yet: ask for the PIN.
  final bool needsRecovery;

  /// This device has the key but there is no cloud backup yet: ask to set a PIN.
  final bool needsBackup;

  final String? error;
  final String? lastTxHash;

  const WalletState({
    this.address,
    this.balanceEth = 0,
    this.isLoading = false,
    this.canSign = false,
    this.needsRecovery = false,
    this.needsBackup = false,
    this.error,
    this.lastTxHash,
  });

  bool get hasWallet => address != null && address!.isNotEmpty;

  WalletState copyWith({
    String? address,
    double? balanceEth,
    bool? isLoading,
    bool? canSign,
    bool? needsRecovery,
    bool? needsBackup,
    String? error,
    String? lastTxHash,
    bool clearError = false,
  }) {
    return WalletState(
      address: address ?? this.address,
      balanceEth: balanceEth ?? this.balanceEth,
      isLoading: isLoading ?? this.isLoading,
      canSign: canSign ?? this.canSign,
      needsRecovery: needsRecovery ?? this.needsRecovery,
      needsBackup: needsBackup ?? this.needsBackup,
      error: clearError ? null : error ?? this.error,
      lastTxHash: lastTxHash ?? this.lastTxHash,
    );
  }
}

class WalletNotifier extends StateNotifier<WalletState> {
  final WalletService _service;

  late final StreamSubscription<AuthState> _authSubscription;

  WalletNotifier(this._service) : super(const WalletState()) {
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (authState) async {
        switch (authState.event) {
          case AuthChangeEvent.initialSession:
          case AuthChangeEvent.signedIn:
            await _restore();
            break;

          case AuthChangeEvent.signedOut:
            // Clears the in-memory key. The on-device copy is only deleted when
            // an encrypted cloud backup exists (see WalletService.logout).
            await _service.logout();
            if (mounted) state = const WalletState();
            break;

          default:
            break;
        }
      },
    );

    if (Supabase.instance.client.auth.currentSession != null) {
      Future.microtask(_restore);
    }
  }

  // ---------------------------------------------------------------------------
  // Restore
  // ---------------------------------------------------------------------------

  bool _restoring = false;
  bool _rerun = false;

  /// Auth events call this without [force] (duplicates are dropped). [reload]
  /// and signup call it with [force], which queues one more pass if a restore
  /// is already running, so a restore that started too early can't leave
  /// stale state behind.
  Future<void> _restore({bool force = false}) async {
    if (_restoring) {
      if (force) _rerun = true;
      return;
    }
    _restoring = true;
    try {
      do {
        _rerun = false;
        await _restoreInner();
      } while (_rerun && mounted);
    } finally {
      _restoring = false;
    }
  }

  Future<void> _restoreInner() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) state = const WalletState();
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      await _service.init();

      // 1. Which address does this account own?
      //    wallets table -> user metadata -> key already on this device.
      String? address;
      try {
        final remote = await _service.fetchWallet();
        address = remote?['wallet_address'] as String?;
      } catch (e) {
        debugPrint('[KLIPA][Wallet] fetchWallet failed: $e');
      }
      if (address == null || address.isEmpty) {
        address = user.userMetadata?['address'] as String?;
      }
      if (address == null || address.isEmpty) {
        address = _service.currentAddressHex;
      }

      if (!mounted) return;
      if (address == null || address.isEmpty) {
        state = const WalletState(
          error: 'No crypto wallet exists for this account.',
        );
        return;
      }

      // 2. Can this device sign for that address?
      final canSign = _service.hasWallet &&
          _service.currentAddressHex?.toLowerCase() == address.toLowerCase();

      // 3. Is there an encrypted backup?
      var needsRecovery = false;
      var needsBackup = false;
      try {
        final hasBackup = await _service.hasCloudBackup();
        needsRecovery = !canSign && hasBackup;
        needsBackup = canSign && !hasBackup;
      } catch (e) {
        debugPrint('[KLIPA][Wallet] backup check failed: $e');
      }

      debugPrint('[KLIPA][Wallet] address=$address '
          'localKey=${_service.currentAddressHex} canSign=$canSign '
          'needsRecovery=$needsRecovery needsBackup=$needsBackup');

      if (!mounted) return;
      state = state.copyWith(
        address: address,
        canSign: canSign,
        needsRecovery: needsRecovery,
        needsBackup: needsBackup,
        isLoading: true,
        clearError: true,
      );

      await refreshBalance();
    } catch (e, st) {
      debugPrint('[KLIPA][Wallet] Restore error: $e');
      debugPrint('$st');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load crypto wallet.',
      );
    }
  }

  // ---------------------------------------------------------------------------
  // Balance
  // ---------------------------------------------------------------------------

  Future<void> refreshBalance() async {
    final address = state.address;
    if (address == null || address.isEmpty) return;

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final balance = await _service.getBalance(address);
      debugPrint('[KLIPA][Wallet] Address: $address Balance: $balance ETH');

      if (!mounted) return;
      state = state.copyWith(
        balanceEth: balance,
        isLoading: false,
        clearError: true,
      );
    } catch (e, st) {
      debugPrint('[KLIPA][Wallet] Balance error: $e');
      debugPrint('$st');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: 'Unable to retrieve ETH balance.',
      );
    }
  }

  Future<void> reload() => _restore(force: true);

  // ---------------------------------------------------------------------------
  // PIN flows
  // ---------------------------------------------------------------------------

  /// New device / cleared storage: decrypt the cloud backup with the PIN.
  /// Throws on a wrong PIN, or if the backup belongs to a different address.
  Future<void> unlockWithPin(String pin) async {
    final address = state.address;
    if (address == null || address.isEmpty) {
      throw const WalletException('No wallet loaded.');
    }

    await _service.restoreFromCloud(pin); // decrypts + saves key on device

    final matches =
        _service.currentAddressHex?.toLowerCase() == address.toLowerCase();
    if (!matches) {
      await _service.discardLocalWallet();
      throw const WalletException(
        "This backup doesn't match the wallet on this account.",
      );
    }

    if (!mounted) return;
    state = state.copyWith(
      canSign: true,
      needsRecovery: false,
      needsBackup: false,
    );
  }

  /// Device has the key but no backup yet: encrypt it with a new PIN and upload.
  Future<void> createBackup(String pin) async {
    if (!state.canSign) {
      throw const WalletException('No signing key on this device to back up.');
    }
    await _service.backupToCloud(pin);
    if (!mounted) return;
    state = state.copyWith(needsBackup: false);
  }

  // ---------------------------------------------------------------------------
  // Send
  // ---------------------------------------------------------------------------

  Future<String> send({
    required String to,
    required String amountEth, // String keeps exact precision
  }) async {
    // Never sign from a different address than the one shown to the user.
    if (!state.canSign ||
        _service.currentAddressHex?.toLowerCase() !=
            state.address?.toLowerCase()) {
      throw const WalletException('This device cannot sign for this wallet.');
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final hash = await _service.sendTransaction(to: to, amount: amountEth);

      if (mounted) {
        state = state.copyWith(isLoading: false, lastTxHash: hash);
      }

      // Refresh in the background so the UI gets the hash immediately.
      unawaited(Future.delayed(const Duration(seconds: 5), () {
        if (mounted) refreshBalance();
      }));

      return hash;
    } catch (e) {
      if (mounted) {
        state = state.copyWith(
          isLoading: false,
          error: 'Transaction failed: $e',
        );
      }
      rethrow;
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}

final walletServiceProvider = Provider<WalletService>(
  (ref) => WalletService.instance,
);

final walletProvider = StateNotifierProvider<WalletNotifier, WalletState>(
  (ref) {
    return WalletNotifier(
      ref.watch(walletServiceProvider),
    );
  },
);