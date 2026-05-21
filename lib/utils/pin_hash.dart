import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Cryptographically-strong PIN hashing for the lock screen.
///
/// Why this exists: a plain `sha256(pin)` of a 4-digit PIN has only 10,000
/// possible inputs. A precomputed rainbow table breaks every PIN in milliseconds
/// if an attacker can read the stored hash (a rooted device, a backup escape,
/// a stolen secure-storage blob, or `adb backup` on a vulnerable device).
///
/// This module uses PBKDF2-HMAC-SHA256 with:
///   - a 128-bit random salt, unique per install (stored alongside the hash)
///   - 150,000 iterations (~100ms on a typical phone, costly enough to make
///     brute-force impractical even with the small input space)
///
/// Stored format (in `flutter_secure_storage` under key `pin_hash_v2`):
///   "<base64 salt>:<base64 derived key>"
///
/// Migration: callers should check the legacy `pin_hash` key first; if it
/// exists, verify against it with the old `sha256(pin)` scheme and on the
/// first successful unlock re-hash with the new scheme and migrate the key.
class PinHash {
  PinHash._();

  static const int _iterations = 150000;
  static const int _saltBytes = 16; // 128 bits
  static const int _keyBytes = 32; // 256 bits — output of HMAC-SHA256

  /// Storage key for the modern salted+iterated hash. The legacy key
  /// `pin_hash` (unsalted sha256) is migrated on first successful unlock.
  static const String storageKey = 'pin_hash_v2';
  static const String legacyKey = 'pin_hash';

  static final _rand = Random.secure();

  /// Hash a freshly-entered PIN with a new random salt. Returns the encoded
  /// string ready to write to secure storage.
  static String hashForStorage(String pin) {
    final salt = Uint8List(_saltBytes);
    for (var i = 0; i < _saltBytes; i++) {
      salt[i] = _rand.nextInt(256);
    }
    final derived = _pbkdf2(utf8.encode(pin), salt, _iterations, _keyBytes);
    return '${base64.encode(salt)}:${base64.encode(derived)}';
  }

  /// Constant-time verify a typed PIN against a previously stored encoded hash.
  static bool verify(String pin, String stored) {
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    late final Uint8List salt;
    late final Uint8List expected;
    try {
      salt = base64.decode(parts[0]);
      expected = base64.decode(parts[1]);
    } catch (_) {
      return false;
    }
    final actual =
        _pbkdf2(utf8.encode(pin), salt, _iterations, expected.length);
    return _constantTimeEquals(actual, expected);
  }

  /// One-shot helper to write a freshly-hashed PIN to secure storage and
  /// remove any legacy unsalted entry.
  static Future<void> writeNew(FlutterSecureStorage storage, String pin) async {
    final encoded = hashForStorage(pin);
    await storage.write(key: storageKey, value: encoded);
    // Remove the legacy unsalted entry once the v2 hash is in place.
    await storage.delete(key: legacyKey);
  }

  // ── Internals ─────────────────────────────────────────────────────────────

  /// PBKDF2-HMAC-SHA256, RFC 8018 §5.2.
  static Uint8List _pbkdf2(
      List<int> password, List<int> salt, int iterations, int outLength) {
    final hmac = Hmac(sha256, password);
    final blockCount = (outLength + 31) ~/ 32; // ceil(outLength / 32)
    final out = Uint8List(blockCount * 32);

    for (var i = 1; i <= blockCount; i++) {
      // INT(i) = big-endian 4-byte block index
      final intBlock = Uint8List(4)
        ..[0] = (i >> 24) & 0xff
        ..[1] = (i >> 16) & 0xff
        ..[2] = (i >> 8) & 0xff
        ..[3] = i & 0xff;

      var u = Uint8List.fromList(hmac.convert([...salt, ...intBlock]).bytes);
      final block = Uint8List.fromList(u);

      for (var j = 1; j < iterations; j++) {
        u = Uint8List.fromList(hmac.convert(u).bytes);
        for (var k = 0; k < block.length; k++) {
          block[k] ^= u[k];
        }
      }

      out.setRange((i - 1) * 32, i * 32, block);
    }

    return Uint8List.sublistView(out, 0, outLength);
  }

  static bool _constantTimeEquals(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a[i] ^ b[i];
    }
    return diff == 0;
  }
}
