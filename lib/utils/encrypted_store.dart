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

  /// Read a value (decrypts via Keystore). Returns null only if the key is
  /// genuinely absent.
  ///
  /// CRITICAL for data safety: a *transient* Keystore / EncryptedSharedPreferences
  /// failure (notably right after an APK replace, when the Android Keystore can
  /// be briefly unavailable) must NOT be mistaken for "no data". If a collection
  /// loaded empty on a transient read error, the user's next add/edit would
  /// persist that empty list and silently wipe their history. So we retry with a
  /// short backoff to let the transient window self-heal before concluding the
  /// key is absent. (An absent key returns null WITHOUT throwing, so this adds
  /// zero delay to the happy path or to genuinely-missing keys.)
  static Future<String?> read(String key) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await _storage.read(key: key);
      } catch (e) {
        lastError = e;
        debugPrint(
            '[EncryptedStore] read($key) attempt ${attempt + 1} failed: $e');
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 120 * (attempt + 1)));
        }
      }
    }
    debugPrint('[EncryptedStore] read($key) gave up after retries: $lastError');
    return null;
  }

  /// Like [read], but THROWS [EncryptedStoreException] when every attempt fails
  /// on a transient Keystore error. An absent key still returns null without
  /// throwing. Use this on the BACKUP EXPORT path: [read] returns null for BOTH
  /// "absent" and "transiently unreadable", so exporting with it can silently
  /// omit a collection the user still has — handing them a backup they believe
  /// is complete. readStrict lets export abort loudly instead.
  static Future<String?> readStrict(String key) async {
    Object? lastError;
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        return await _storage.read(key: key);
      } catch (e) {
        lastError = e;
        debugPrint(
            '[EncryptedStore] readStrict($key) attempt ${attempt + 1} failed: $e');
        if (attempt < 2) {
          await Future.delayed(Duration(milliseconds: 120 * (attempt + 1)));
        }
      }
    }
    throw EncryptedStoreException(
        'Secure read failed for key "$key" after retries: $lastError');
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
