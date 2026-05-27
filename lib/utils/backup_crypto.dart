import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

// Symmetric backup encryption: passphrase + PBKDF2-derived key + HMAC-SHA256
// used as a stream cipher PRF in CTR mode (not AES — there is no AES anywhere
// in this implementation).
//
// We avoid pulling in pointycastle / cryptography to keep the dependency
// footprint minimal — sobriety apps live on phones with constrained storage
// and we already have `crypto` for PIN hashing. The construction is the
// well-understood "PRF-in-CTR" pattern (key + nonce + counter → HMAC-SHA256
// → keystream block; XOR with plaintext), with a separate HMAC key used to
// MAC salt||nonce||ct for tamper detection. Each backup gets a fresh random
// 128-bit salt + 96-bit nonce, so the same passphrase encrypting the same
// data twice produces different ciphertexts.
//
// Format (JSON wrapper):
//   {
//     "v": 1,                          // version (lets us migrate later)
//     "salt": "<base64 16 bytes>",
//     "nonce": "<base64 12 bytes>",
//     "ct": "<base64 ciphertext>",
//     "mac": "<base64 HMAC-SHA256 over salt||nonce||ct>"
//   }
//
// Wrong passphrase → MAC fails fast (no garbage plaintext) → throws
// [BackupCryptoException]. Right passphrase → original UTF-8 plaintext.

class BackupCryptoException implements Exception {
  final String message;
  BackupCryptoException(this.message);
  @override
  String toString() => 'BackupCryptoException: $message';
}

class BackupCrypto {
  static const int _iterations = 150000;
  static const int _saltLen = 16;
  static const int _nonceLen = 12;
  static const int _keyLen = 32;
  static const int _macKeyLen = 32;
  static const int _version = 1;

  /// Encrypt [plaintext] with [passphrase]. Returns a UTF-8 JSON string.
  static String encrypt(String plaintext, String passphrase) {
    if (passphrase.isEmpty) {
      throw BackupCryptoException('Passphrase cannot be empty.');
    }
    final rng = Random.secure();
    final salt = Uint8List.fromList(
        List<int>.generate(_saltLen, (_) => rng.nextInt(256)));
    final nonce = Uint8List.fromList(
        List<int>.generate(_nonceLen, (_) => rng.nextInt(256)));

    final (encKey, macKey) = _deriveKeys(passphrase, salt);
    final ptBytes = Uint8List.fromList(utf8.encode(plaintext));
    final ct = _ctrXor(encKey, nonce, ptBytes);

    final macInput = BytesBuilder()
      ..add(salt)
      ..add(nonce)
      ..add(ct);
    final mac = Hmac(sha256, macKey).convert(macInput.toBytes()).bytes;

    return jsonEncode({
      'v': _version,
      'salt': base64Encode(salt),
      'nonce': base64Encode(nonce),
      'ct': base64Encode(ct),
      'mac': base64Encode(mac),
    });
  }

  /// Decrypt the JSON envelope produced by [encrypt]. Throws on tampered
  /// data OR wrong passphrase.
  static String decrypt(String envelope, String passphrase) {
    late final Map<String, dynamic> m;
    try {
      m = jsonDecode(envelope) as Map<String, dynamic>;
    } catch (_) {
      throw BackupCryptoException('Backup file is not valid JSON.');
    }
    final v = m['v'];
    if (v != _version) {
      throw BackupCryptoException('Unsupported backup version: $v');
    }
    final salt = base64Decode(m['salt'] as String);
    final nonce = base64Decode(m['nonce'] as String);
    final ct = base64Decode(m['ct'] as String);
    final mac = base64Decode(m['mac'] as String);

    final (encKey, macKey) = _deriveKeys(passphrase, salt);

    final macInput = BytesBuilder()
      ..add(salt)
      ..add(nonce)
      ..add(ct);
    final expected = Hmac(sha256, macKey).convert(macInput.toBytes()).bytes;
    if (!_constantTimeEq(mac, expected)) {
      throw BackupCryptoException(
          'Wrong passphrase, or the backup file has been altered.');
    }
    final pt = _ctrXor(encKey, nonce, ct);
    return utf8.decode(pt);
  }

  /// Returns `true` if [envelope] *looks* like an encrypted backup. Cheap
  /// sniff used by restore UI to switch into passphrase-prompt mode.
  static bool looksEncrypted(String envelope) {
    try {
      final m = jsonDecode(envelope);
      return m is Map &&
          m.containsKey('v') &&
          m.containsKey('salt') &&
          m.containsKey('nonce') &&
          m.containsKey('ct') &&
          m.containsKey('mac');
    } catch (_) {
      return false;
    }
  }

  // ─── Internals ──────────────────────────────────────────────────────────────

  /// PBKDF2-HMAC-SHA256 derives 2× 32-byte keys: one for the HMAC-SHA256
  /// CTR-mode stream cipher PRF, one for the HMAC integrity tag. Splitting
  /// prevents key reuse across primitives.
  static (List<int>, List<int>) _deriveKeys(String passphrase, List<int> salt) {
    final dk = _pbkdf2(
        utf8.encode(passphrase), salt, _iterations, _keyLen + _macKeyLen);
    return (dk.sublist(0, _keyLen), dk.sublist(_keyLen));
  }

  static List<int> _pbkdf2(
      List<int> password, List<int> salt, int iterations, int dkLen) {
    final hmac = Hmac(sha256, password);
    final blocks = (dkLen + 31) ~/ 32;
    final out = <int>[];
    for (var i = 1; i <= blocks; i++) {
      final block = _f(hmac, salt, iterations, i);
      out.addAll(block);
    }
    return out.sublist(0, dkLen);
  }

  static List<int> _f(Hmac hmac, List<int> salt, int iterations, int blockIdx) {
    final saltBlock = [
      ...salt,
      (blockIdx >> 24) & 0xff,
      (blockIdx >> 16) & 0xff,
      (blockIdx >> 8) & 0xff,
      blockIdx & 0xff,
    ];
    var u = hmac.convert(saltBlock).bytes;
    final t = List<int>.from(u);
    for (var i = 1; i < iterations; i++) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < t.length; j++) {
        t[j] ^= u[j];
      }
    }
    return t;
  }

  /// Stream cipher: HMAC-SHA256(key, nonce || counter) → 32 bytes per block,
  /// XOR into plaintext. Reuses HMAC as a PRF — secure as long as
  /// (key, nonce) is unique per ciphertext, which we guarantee with a fresh
  /// 96-bit random nonce per encrypt() call.
  static Uint8List _ctrXor(List<int> key, List<int> nonce, Uint8List data) {
    final out = Uint8List(data.length);
    final hmac = Hmac(sha256, key);
    var counter = 0;
    var offset = 0;
    while (offset < data.length) {
      final block = [
        ...nonce,
        (counter >> 24) & 0xff,
        (counter >> 16) & 0xff,
        (counter >> 8) & 0xff,
        counter & 0xff,
      ];
      final keystream = hmac.convert(block).bytes;
      final n = (data.length - offset).clamp(0, keystream.length);
      for (var i = 0; i < n; i++) {
        out[offset + i] = data[offset + i] ^ keystream[i];
      }
      offset += n;
      counter++;
    }
    return out;
  }

  static bool _constantTimeEq(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
