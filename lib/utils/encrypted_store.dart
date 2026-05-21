import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Thin wrapper around `flutter_secure_storage` that:
///   • backs onto Android Keystore (EncryptedSharedPreferences) — the OS
///     stores the encryption key in hardware-backed Keystore so even a
///     rooted device or compromised backup cannot trivially decrypt.
///   • exposes the same surface as `SharedPreferences.getString/setString`
///     so existing code can swap in with minimal changes.
///   • includes a one-shot migration helper: read a key from regular
///     SharedPreferences, copy into secure storage, delete the plain
///     entry. Idempotent and safe to call on every app launch.
///
/// Why we don't put EVERYTHING here: EncryptedSharedPreferences has a
/// per-entry size soft-limit (Android typically OK up to ~256 KB but slow
/// for larger blobs) and per-write latency ~10× SharedPreferences. For
/// the journal / slip / craving lists this matters; for the profile
/// (~1 KB) it does not.
class EncryptedStore {
  EncryptedStore._();

  static const _options = AndroidOptions(encryptedSharedPreferences: true);
  static const _ios =
      IOSOptions(accessibility: KeychainAccessibility.first_unlock);

  static const FlutterSecureStorage _storage =
      FlutterSecureStorage(aOptions: _options, iOptions: _ios);

  /// Read a value (decrypts via Keystore). Returns null if absent.
  static Future<String?> read(String key) async {
    try {
      return await _storage.read(key: key);
    } catch (e) {
      debugPrint('[EncryptedStore] read($key) failed: $e');
      return null;
    }
  }

  /// Write a value (encrypts via Keystore).
  /// Throws [EncryptedStoreException] if the write fails so callers are
  /// not left believing sensitive data was persisted when it was not.
  static Future<void> write(String key, String value) async {
    try {
      await _storage.write(key: key, value: value);
    } catch (e) {
      debugPrint('[EncryptedStore] write($key) failed: $e');
      throw EncryptedStoreException('Secure write failed for key "$key": $e');
    }
  }

  /// Delete a key from secure storage.
  static Future<void> delete(String key) async {
    try {
      await _storage.delete(key: key);
    } catch (e) {
      debugPrint('[EncryptedStore] delete($key) failed: $e');
    }
  }

  /// One-shot migration: if `key` exists in regular SharedPreferences,
  /// copy its value into secure storage and remove the plain entry. Idempotent
  /// (safe to call every launch — does nothing once the prefs key is gone).
  ///
  /// Returns the current value (post-migration), or null if neither store
  /// has it. Callers can use this as a drop-in replacement for prefs.getString
  /// during read paths.
  static Future<String?> migrateFromPrefs(
      SharedPreferences prefs, String key) async {
    final plain = prefs.getString(key);
    if (plain != null) {
      await write(key, plain);
      await prefs.remove(key);
      return plain;
    }
    return read(key);
  }
}

/// Thrown when [EncryptedStore.write] cannot persist data to secure storage.
/// Callers should surface this to the user rather than silently ignoring it.
class EncryptedStoreException implements Exception {
  final String message;
  const EncryptedStoreException(this.message);

  @override
  String toString() => 'EncryptedStoreException: $message';
}
