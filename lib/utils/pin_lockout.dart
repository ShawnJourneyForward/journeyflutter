import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Shared, persisted brute-force lockout for every PIN-entry surface — the app
/// lock screen AND the journal per-entry re-auth dialog.
///
/// Both surfaces verify the SAME device-lock PIN hash, so they MUST share one
/// throttle: otherwise an attacker who hits the lock screen's cooldown could
/// simply keep guessing in the journal dialog (which previously had no limit).
/// This helper reads/writes the same secure-storage keys the lock screen has
/// always used (`pin_fail_count` / `pin_lockout_until`) with the same storage
/// options, so the escalating cooldown is genuinely unified across both.
///
/// Thresholds mirror the lock screen exactly: 5 fails → 30s, 10 → 5m, 15 → 15m.
/// State is persisted (a force-stop can't reset the cooldown).
class PinLockout {
  PinLockout._();

  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  static const _failCountKey = 'pin_fail_count';
  static const _lockoutUntilKey = 'pin_lockout_until';

  /// The time the current lockout expires, or null when not currently locked
  /// out (also returns null once an old lockout has elapsed).
  static Future<DateTime?> lockedUntil() async {
    final raw = await _storage.read(key: _lockoutUntilKey);
    final until = raw == null ? null : DateTime.tryParse(raw);
    if (until == null) return null;
    return until.isAfter(DateTime.now()) ? until : null;
  }

  /// Record a failed attempt and apply the escalating cooldown. Returns the
  /// lockout-until time when this attempt triggers (or falls within) a lockout,
  /// otherwise null.
  static Future<DateTime?> registerFailure() async {
    final raw = await _storage.read(key: _failCountKey);
    final count = (int.tryParse(raw ?? '') ?? 0) + 1;
    await _storage.write(key: _failCountKey, value: count.toString());
    Duration? cooldown;
    if (count >= 15) {
      cooldown = const Duration(minutes: 15);
    } else if (count >= 10) {
      cooldown = const Duration(minutes: 5);
    } else if (count >= 5) {
      cooldown = const Duration(seconds: 30);
    }
    if (cooldown == null) return null;
    final until = DateTime.now().add(cooldown);
    await _storage.write(key: _lockoutUntilKey, value: until.toIso8601String());
    return until;
  }

  /// Clear the failure count + lockout. Call on a successful unlock.
  static Future<void> reset() async {
    await _storage.delete(key: _failCountKey);
    await _storage.delete(key: _lockoutUntilKey);
  }
}
