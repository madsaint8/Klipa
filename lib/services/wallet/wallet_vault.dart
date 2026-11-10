import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VaultException implements Exception {
  final String message;
  const VaultException(this.message);
  @override
  String toString() => message;
}

class WalletVault {
  static const _iterations = 210000;
  final _aes = AesGcm.with256bits();
  SupabaseClient get _db => Supabase.instance.client;

  Future<SecretKey> _derive(String pin, List<int> salt, int iterations) {
    final kdf = Pbkdf2(
      macAlgorithm: Hmac.sha256(),
      iterations: iterations,
      bits: 256,
    );
    return kdf.deriveKeyFromPassword(password: pin, nonce: salt);
  }

  Future<bool> hasBackup() async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) return false;
    final row = await _db
        .from('wallet_backups')
        .select('user_id')
        .eq('user_id', uid)
        .maybeSingle();
    return row != null;
  }

  Future<void> backup({
    required String privateKeyHex,
    required String address,
    required String pin,
  }) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw const VaultException('Not signed in.');

    final salt = SecretKeyData.random(length: 16).bytes;
    final key = await _derive(pin, salt, _iterations);
    final box = await _aes.encrypt(utf8.encode(privateKeyHex), secretKey: key);

    await _db.from('wallet_backups').upsert({
      'user_id': uid,
      'address': address,
      'blob': base64Encode(box.concatenation()),
      'salt': base64Encode(salt),
      'iterations': _iterations,
    });
  }

  /// Returns the decrypted private key hex. Throws on a wrong PIN.
  Future<({String privateKey, String address})> restore(String pin) async {
    final uid = _db.auth.currentUser?.id;
    if (uid == null) throw const VaultException('Not signed in.');

    final row = await _db
        .from('wallet_backups')
        .select()
        .eq('user_id', uid)
        .maybeSingle();
    if (row == null) throw const VaultException('No wallet backup found.');

    final key = await _derive(
      pin,
      base64Decode(row['salt'] as String),
      row['iterations'] as int,
    );
    try {
      final box = SecretBox.fromConcatenation(
        base64Decode(row['blob'] as String),
        nonceLength: 12,
        macLength: 16,
      );
      final clear = await _aes.decrypt(box, secretKey: key);
      return (privateKey: utf8.decode(clear), address: row['address'] as String);
    } on SecretBoxAuthenticationError {
      throw const VaultException('Incorrect PIN.');
    }
  }
}