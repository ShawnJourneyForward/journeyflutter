import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'encrypted_store.dart';

// ─── One-shot migration: plain SharedPreferences → EncryptedStore ─────────────
//
// Called once at app startup BEFORE runApp(). Reads each sensitive key from
// plain SharedPreferences (the old store), copies the value into
// EncryptedStore (Android Keystore–backed EncryptedSharedPreferences), then
// deletes the plain entry. The operation is idempotent — if the plain key is
// already absent (already migrated) it silently skips the key and reads from
// EncryptedStore instead, so repeated launches are safe and fast.
//
// Keys NOT migrated here (left in plain SharedPreferences):
//   • 'lockMethod' — plain string used synchronously by the GoRouter redirect;
//     not personally sensitive (just 'pin', 'biometric', or 'none').
//   • 'has_profile' — synchronous presence sentinel used by the router;
//     contains only the literal '1', not any user data.
//   • 'profile_sober_date' — the sober date mirrors the profile for the home
//     screen widget; already covered by the profile key migration (individual
//     date string, no other personal data).
//   • 'weekly_goal_toggles' / 'mission_toggles' — ephemeral toggle state,
//     no personal narrative content.
//   • 'notification_*' — notification scheduling prefs (times + on/off flags).
//
// Keys that WERE already in EncryptedStore before this migration ('profile')
// are excluded to avoid an unnecessary re-read/re-write cycle.

const _migratableKeys = [
  // Journal data — most sensitive: personal recovery narrative
  'journal_entries',
  'gratitude',

  // Craving & thought logs — sensitive: records moments of vulnerability
  'cravings',
  'thoughts',
  'thought_records',

  // Slip history — very sensitive: records relapse events
  'slip_log',

  // Clinical practice data (new features)
  'daily_intentions',
  'recovery_capital',

  // Life management data — moderately sensitive
  'activities',
  'sleep_logs',
  'meetings',
  'future_letters',
  'hard_days',

  // Goals & vision — moderately sensitive
  'vision_board',
  'custom_affirmations',
];

class StorageMigration {
  StorageMigration._();

  /// Copy all sensitive keys from plain SharedPreferences to EncryptedStore,
  /// then delete the plaintext copies. Safe to call on every app launch —
  /// already-migrated keys are no-ops. Errors on individual keys are caught
  /// and logged so one bad key never prevents the others from migrating.
  static Future<void> migrateAll(SharedPreferences prefs) async {
    for (final key in _migratableKeys) {
      try {
        await EncryptedStore.migrateFromPrefs(prefs, key);
      } catch (e) {
        // Log but continue — a failed migration on one key must never block
        // the others. The key remains in plaintext on this launch; the next
        // launch will retry.
        debugPrint('[StorageMigration] failed to migrate "$key": $e');
      }
    }
    debugPrint('[StorageMigration] migration pass complete.');
  }
}
