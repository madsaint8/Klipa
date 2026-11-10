import 'dart:convert';
import 'dart:developer' as developer;
import 'dart:math';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import '../../common/functions/user/get_user.dart';
import '../../common/widgets/wallet/get_wallet.dart';
import '../../data/models/environment/environment.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'wallet_vault.dart';

class WalletException implements Exception {
  final String message;
  const WalletException(this.message);
  @override
  String toString() => message;
}

class FeeEstimate {
  final BigInt gasLimit;
  final BigInt gasPriceWei;
  const FeeEstimate({required this.gasLimit, required this.gasPriceWei});

  BigInt get feeWei => gasLimit * gasPriceWei;
  double get feeEth => feeWei.toDouble() / 1e18;
  double get gasPriceGwei => gasPriceWei.toDouble() / 1e9;
}

class WalletService {
  WalletService._internal();
  static final WalletService instance = WalletService._internal();

  static const int _sepoliaChainId = 11155111;
  static const String _storageKey = 'wallet';
  static const String _logName = 'KLIPA.Wallet';
  static const Duration _rpcTimeout = Duration(seconds: 15);

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Web3Client? _client;
  EthPrivateKey? _credentials;
  String? _addressHex;
  bool _initialized = false;

  String? get currentAddressHex => _addressHex;

  /// True only when this device holds the private key (can sign).
  bool get hasWallet => _credentials != null;
  String get networkName => 'Ethereum Sepolia';

  Web3Client get client {
    final url = Environment.alchemySepoliaRpcUrl;
    if (url.isEmpty) {
      throw StateError(
        'ALCHEMY_SEPOLIA_RPC_URL is missing from ${Environment.fileName}.',
      );
    }
    return _client ??= Web3Client(url, Client());
  }

  String explorerAddressUrl(String address) =>
      'https://sepolia.etherscan.io/address/$address';

  String explorerTxUrl(String hash) => 'https://sepolia.etherscan.io/tx/$hash';

// ------------------------------ Cloud Backup ---------------------------------

  final WalletVault _vault = WalletVault();

  Future<bool> hasCloudBackup() => _vault.hasBackup();

  /// Encrypts the key on this device with [pin] and uploads the ciphertext.
  Future<void> backupToCloud(String pin) async {
    final c = _credentials;
    if (c == null) {
      throw const WalletException('No key on this device to back up.');
    }
    await _vault.backup(
      privateKeyHex: bytesToHex(c.privateKey, include0x: true),
      address: c.address.hex,
      pin: pin,
    );
  }

  /// New device / cleared storage: decrypt the backup and load the key.
  Future<void> restoreFromCloud(String pin) async {
    final r = await _vault.restore(pin);
    await importWallet(r.privateKey); // saves to secure storage
  }

  Future<void> logout() async {
    // Only wipe the local key if it can be restored from the cloud backup.
    final safe = await hasCloudBackup().catchError((_) => false);
    if (safe) await _storage.delete(key: _storageKey);
    _credentials = null;
    _addressHex = null;
    _initialized = false;
    _client?.dispose();
    _client = null;
  }

  /// Wipes the local key unconditionally (failed signup, or a backup that
  /// doesn't match this account).
  Future<void> discardLocalWallet() async {
    await _storage.delete(key: _storageKey);
    _credentials = null;
    _addressHex = null;
    _initialized = false;
  }
  // ------------------------------ Lifecycle ---------------------------------

  Future<void> init() async {
    if (_initialized) return;
    await _loadWalletFromStorage();
    _initialized = true;
  }

  /// Loads the signing key: local secure storage first, then the signed-in
  /// user's Supabase metadata (new-device case). If [expectedAddress] is given,
  /// the key must derive that address, otherwise it's rejected.
  Future<bool> ensureSigner({String? expectedAddress}) async {
    await init();

    bool matches() =>
        _credentials != null &&
        (expectedAddress == null ||
            _addressHex?.toLowerCase() == expectedAddress.toLowerCase());

    if (matches()) return true;

    final meta = Supabase.instance.client.auth.currentUser?.userMetadata;
    final pk = meta?['privateKey'] as String?;
    if (pk != null && pk.isNotEmpty) {
      try {
        await importWallet(pk); // also caches it in secure storage
        if (matches()) return true;
      } catch (e) {
        developer.log('Metadata key import failed: $e', name: _logName);
      }
    }
    return false;
  }

  /// Manual fallback: accept a pasted key only if it controls [expectedAddress].
  Future<void> importKeyForAddress(
      String privateKey, String expectedAddress) async {
    final key = EthPrivateKey.fromHex(privateKey.trim());
    if (key.address.hex.toLowerCase() != expectedAddress.toLowerCase()) {
      throw WalletException(
        'That key controls ${key.address.hex}, not this wallet.',
      );
    }
    await _persist(key);
  }

  // --------------------------- Wallet management ----------------------------

  Future<Map<String, dynamic>> createWallet() async {
    final key = EthPrivateKey.createRandom(Random.secure());
    return _persist(key);
  }

  Future<void> importWallet(String privateKey) async {
    final cleanKey = privateKey.trim();
    if (cleanKey.isEmpty) {
      throw const FormatException('Private key is empty.');
    }
    await _persist(EthPrivateKey.fromHex(cleanKey));
  }

  Future<Map<String, dynamic>> _persist(EthPrivateKey key) async {
    final address = key.address;
    final wallet = {
      'address': address.hex,
      'privateKey': bytesToHex(key.privateKey, include0x: true),
    };
    await _storage.write(key: _storageKey, value: jsonEncode(wallet));
    _credentials = key;
    _addressHex = address.hex;
    return wallet;
  }

  Future<void> _loadWalletFromStorage() async {
    final data = await _storage.read(key: _storageKey);
    if (data == null || data.isEmpty) return;

    try {
      final map = jsonDecode(data) as Map<String, dynamic>;
      final privateKey = map['privateKey'] as String?;
      if (privateKey == null || privateKey.isEmpty) return;

      final key = EthPrivateKey.fromHex(privateKey);
      _credentials = key;
      _addressHex = key.address.hex;
    } catch (e) {
      developer.log('Failed to load local wallet: $e', name: _logName);
    }
  }

  // -------------------------------- Balance ---------------------------------

  Future<double> getBalance(String address) async {
    final cleanAddress = address.trim();
    if (cleanAddress.isEmpty) {
      throw StateError('Wallet address is empty.');
    }
    try {
      final balance = await client
          .getBalance(EthereumAddress.fromHex(cleanAddress))
          .timeout(_rpcTimeout);
      return balance.getValueInUnit(EtherUnit.ether);
    } catch (e, st) {
      developer.log('ETH balance request failed: $e',
          name: _logName, error: e, stackTrace: st);
      rethrow;
    }
  }

  // ---------------------------------- Fees ----------------------------------

  bool isValidAddress(String? value) =>
      RegExp(r'^0x[0-9a-fA-F]{40}$').hasMatch((value ?? '').trim());

  /// Current gas price + 10% buffer so the tx isn't stuck if the base fee ticks up.
  Future<BigInt> _gasPriceWei() async {
    final p = await client.getGasPrice().timeout(_rpcTimeout);
    return p.getInWei * BigInt.from(110) ~/ BigInt.from(100);
  }

  Future<FeeEstimate> estimateFee({String? to}) async {
    var gasLimit = BigInt.from(21000); // plain ETH transfer
    final from = _credentials?.address;

    if (from != null && isValidAddress(to)) {
      try {
        final est = await client
            .estimateGas(sender: from, to: EthereumAddress.fromHex(to!.trim()))
            .timeout(_rpcTimeout);
        if (est > gasLimit) {
          gasLimit =
              est * BigInt.from(12) ~/ BigInt.from(10); // contract recipient
        }
      } catch (_) {
        // Fall back to 21000.
      }
    }

    return FeeEstimate(gasLimit: gasLimit, gasPriceWei: await _gasPriceWei());
  }

  /// Max amount (as exact ETH string) that can be sent after paying the fee.
  Future<String> maxSendableEth({String? to}) async {
    final address = _addressHex;
    if (address == null) {
      throw const WalletException('Wallet is not loaded.');
    }
    final balance = (await client
            .getBalance(EthereumAddress.fromHex(address))
            .timeout(_rpcTimeout))
        .getInWei;
    final fee = await estimateFee(to: to);
    final max = balance - fee.feeWei;
    return max > BigInt.zero ? weiToEthString(max) : '0';
  }

  String weiToEthString(BigInt wei) {
    final s = wei.toString().padLeft(19, '0');
    final whole = s.substring(0, s.length - 18);
    final frac = s.substring(s.length - 18).replaceFirst(RegExp(r'0+$'), '');
    return frac.isEmpty ? whole : '$whole.$frac';
  }

  // ---------------------------------- Send ----------------------------------

  Future<String> sendTransaction({
    required String to,
    required String amount,
  }) async {
    final credentials = _credentials;
    if (credentials == null) {
      throw const WalletException(
        'This device does not hold the signing key for this wallet. '
        'Import your private key to send funds.',
      );
    }
    if (!isValidAddress(to)) {
      throw const WalletException('Invalid recipient address.');
    }

    final valueWei = _ethToWei(amount);
    if (valueWei <= BigInt.zero) {
      throw const FormatException('Enter a valid ETH amount.');
    }

    final fee = await estimateFee(to: to);
    final balance =
        (await client.getBalance(credentials.address).timeout(_rpcTimeout))
            .getInWei;

    if (valueWei + fee.feeWei > balance) {
      throw const WalletException(
        'Insufficient ETH to cover the amount plus network fee.',
      );
    }

    final transaction = Transaction(
      to: EthereumAddress.fromHex(to.trim()),
      value: EtherAmount.inWei(valueWei),
      maxGas: fee.gasLimit.toInt(),
      gasPrice: EtherAmount.inWei(fee.gasPriceWei),
    );

    return client.sendTransaction(
      credentials,
      transaction,
      chainId: _sepoliaChainId,
    );
  }

  /// Returns true = confirmed, false = reverted, null = still pending/timeout.
  Future<bool?> waitForConfirmation(
    String hash, {
    Duration timeout = const Duration(seconds: 90),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      try {
        final receipt = await client.getTransactionReceipt(hash);
        if (receipt != null) return receipt.status ?? true;
      } catch (_) {}
      await Future.delayed(const Duration(seconds: 4));
    }
    return null;
  }

  BigInt _ethToWei(String input) {
    final text = input.trim();
    if (!RegExp(r'^\d+(\.\d{1,18})?$').hasMatch(text)) {
      throw const FormatException('Enter a valid ETH amount.');
    }
    final parts = text.split('.');
    final whole = BigInt.parse(parts[0]);
    final fraction =
        BigInt.parse((parts.length > 1 ? parts[1] : '').padRight(18, '0'));
    return whole * BigInt.from(10).pow(18) + fraction;
  }

  // ---------------------------- Backend helpers -----------------------------

  Future<Map<String, dynamic>?> fetchWallet() => getWallet();
  Future<Map<String, dynamic>?> fetchUser() => getUser();
}
