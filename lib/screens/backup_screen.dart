import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/backup_crypto.dart';
import '../utils/encrypted_store.dart';
import '../utils/haptic_service.dart';
import '../utils/vision_image_store.dart';

// ─── Keys exported in a backup ────────────────────────────────────────────────

const _exportKeys = [
  'profile',
  'journal_entries',
  'gratitude',
  'slip_log',
  'vision_board',
  'custom_affirmations',
  'cravings',
  'thoughts',
  'activities',
  'sleep_logs',
  // v5.8 feature data — must travel with the backup or the user silently
  // loses these on restore.
  'future_letters',
  'hard_days',
  'thought_records',
  'meetings',
  // v5.9 clinical features
  'daily_intentions',
  'recovery_capital',
  // v6.0 — urge timer wins
  'urge_rides',
  // v6.3 — 100-day challenge grid (ticked days + emoji stickers)
  'hundred_day_challenge',
  // v6.4 planner — goals, sessions, weight logs, activities, settings
  'planner_goals',
  'planner_sessions',
  'planner_weight_logs',
  'planner_activities',
  'planner_settings',
  // lockMethod is intentionally excluded: the PIN hash lives in secure storage
  // and cannot travel with the backup. Importing lockMethod without a hash
  // would silently break the lock screen.
  //
  // strava_tokens is also intentionally excluded: OAuth tokens live in
  // flutter_secure_storage and never travel in a backup (mirrors lockMethod) —
  // tokens are device-bound and re-granted by re-connecting Strava on restore.
];

/// Public alias of [_exportKeys] so tests can assert the backup roundtrip
/// against the REAL exported-key list rather than a hand-maintained copy.
const List<String> kBackupExportKeys = _exportKeys;

// ─── Backup Screen ────────────────────────────────────────────────────────────

class BackupScreen extends ConsumerStatefulWidget {
  const BackupScreen({super.key});

  @override
  ConsumerState<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends ConsumerState<BackupScreen> {
  bool _exporting = false;
  bool _importing = false;

  // ── Export ─────────────────────────────────────────────────────────────────

  Future<void> _export() async {
    final l10n = AppLocalizations.of(context);
    // Ask up-front whether to passphrase-protect. Default is unprotected to
    // preserve the long-standing v1 backup format users already have on disk,
    // but the recommended choice is encrypted — phones get lost / shared.
    final passphrase = await _promptPassphrase(forExport: true);
    if (passphrase == null) return; // user cancelled the dialog
    final usingEncryption = passphrase.isNotEmpty;

    setState(() => _exporting = true);
    try {
      final data = <String, String>{};

      // All sensitive data now lives in EncryptedStore (migrated at startup).
      // Plain SharedPreferences no longer holds any personal content.
      // readStrict THROWS on a transient Keystore failure (vs. returning null
      // for a genuinely-absent key), so a collection we can't read aborts the
      // whole export instead of being silently dropped from the file — caught
      // below and surfaced as "export failed".
      for (final key in _exportKeys) {
        final val = await EncryptedStore.readStrict(key);
        if (val != null) data[key] = val;
      }

      // Bundle the Vision Board photo BYTES (not just the filenames). Without
      // this, a backup restored on a NEW install references image files that
      // don't exist and every vision photo renders blank — the primary backup
      // use case silently losing data. Additive: stored under a new top-level
      // key, old importers ignore it.
      final images = <String, String>{};
      for (final name in _collectVisionImageNames(data['vision_board'])) {
        final b64 = await VisionImageStore.readBytesB64(name);
        if (b64 != null) images[name] = b64;
      }

      final payload = const JsonEncoder.withIndent('  ').convert({
        'app': 'Journey Forward',
        'version': '1',
        'exportedAt': DateTime.now().toIso8601String(),
        'data': data,
        if (images.isNotEmpty) 'images': images,
      });

      final fileContents =
          usingEncryption ? BackupCrypto.encrypt(payload, passphrase) : payload;
      final filename = usingEncryption
          ? 'journey_forward_backup.jfwbk'
          : 'journey_forward_backup.json';

      final file = File('${Directory.systemTemp.path}/$filename');
      await file.writeAsString(fileContents);

      final shareResult = await Share.shareXFiles(
        [
          XFile(file.path,
              mimeType: usingEncryption
                  ? 'application/octet-stream'
                  : 'application/json'),
        ],
        subject: usingEncryption
            ? l10n.backupShareSubjectEncrypted
            : l10n.backupShareSubject,
      );

      // Stamp the backup date (plain pref — not sensitive) so the home
      // screen's milestone-time nudge knows the streak is protected.
      if (shareResult.status != ShareResultStatus.dismissed) {
        final prefs = await ref.read(prefsProvider.future);
        await prefs.setString(
            'last_backup_date', DateTime.now().toIso8601String());
      }
    } catch (e) {
      if (mounted) {
        _showSnack(AppLocalizations.of(context).backupExportFailed,
            error: true);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }

  // ── Passphrase prompt ─────────────────────────────────────────────────────
  //
  // Returns:
  //   • a non-empty string  → user wants encryption with that passphrase
  //   • an empty string     → user chose "skip" (plaintext backup)
  //   • null                → user cancelled the dialog
  Future<String?> _promptPassphrase({required bool forExport}) async {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    String? error;
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setLocal) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
            title: Text(
              forExport
                  ? l10n.backupProtectTitle
                  : l10n.backupEnterPassphraseTitle,
              style: AppTextStyles.titleMedium,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forExport
                      ? l10n.backupProtectDesc
                      : l10n.backupEnterPassphraseDesc,
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone600, height: 1.4),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: ctrl,
                  obscureText: true,
                  autofocus: true,
                  decoration: InputDecoration(
                    labelText: l10n.backupPassphraseLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (forExport) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.backupConfirmPassphraseLabel,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
                if (error != null) ...[
                  const SizedBox(height: 8),
                  Text(error!,
                      style: AppTextStyles.caption
                          .copyWith(color: AppColors.blush600)),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(null),
                child: Text(l10n.commonCancel,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.stone500)),
              ),
              if (forExport)
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(''),
                  child: Text(l10n.backupSkipPlainJson,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.stone500)),
                ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest700),
                onPressed: () {
                  if (ctrl.text.isEmpty) {
                    setLocal(() => error = l10n.backupPassphraseEmptyError);
                    return;
                  }
                  if (forExport && ctrl.text != confirmCtrl.text) {
                    setLocal(() => error = l10n.backupPassphraseMismatchError);
                    return;
                  }
                  if (forExport && ctrl.text.length < 8) {
                    setLocal(() => error = l10n.backupPassphraseTooShortError);
                    return;
                  }
                  Navigator.of(ctx).pop(ctrl.text);
                },
                child: Text(
                    forExport ? l10n.backupEncryptButton : l10n.backupUnlockButton,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );
    ctrl.dispose();
    confirmCtrl.dispose();
    H.light();
    return result;
  }

  // ── Import ─────────────────────────────────────────────────────────────────

  Future<void> _import() async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) {
        final dialogL10n = AppLocalizations.of(ctx);
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
          title: Text(dialogL10n.backupConfirmTitle,
              style: AppTextStyles.titleMedium),
          content: Text(
            dialogL10n.backupConfirmMessage,
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(dialogL10n.commonCancel,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.stone500)),
            ),
            FilledButton(
              style:
                  FilledButton.styleFrom(backgroundColor: AppColors.forest600),
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(dialogL10n.commonRestore,
                  style:
                      AppTextStyles.labelMedium.copyWith(color: Colors.white)),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    setState(() => _importing = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json', 'jfwbk'],
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _importing = false);
        return;
      }

      var raw = await File(result.files.single.path!).readAsString();

      // Encrypted backup? Prompt for the passphrase and decrypt before
      // attempting the JSON shape check.
      if (BackupCrypto.looksEncrypted(raw)) {
        if (!mounted) return;
        final pass = await _promptPassphrase(forExport: false);
        if (pass == null || pass.isEmpty) {
          setState(() => _importing = false);
          return;
        }
        try {
          raw = BackupCrypto.decrypt(raw, pass);
        } on BackupCryptoException catch (e) {
          if (mounted) _showSnack(e.message, error: true);
          setState(() => _importing = false);
          return;
        }
      }

      final parsed = jsonDecode(raw) as Map<String, dynamic>;

      if (parsed['app'] != 'Journey Forward') {
        if (mounted) {
          _showSnack(l10n.backupInvalidFile, error: true);
        }
        setState(() => _importing = false);
        return;
      }

      final data = parsed['data'] as Map<String, dynamic>;
      final prefs = await ref.read(prefsProvider.future);

      // ── Transactional restore ───────────────────────────────────────────
      // Trust matters more than throughput on this path. If any single
      // EncryptedStore write fails midway, the user must end the operation
      // in the SAME state they started — either fully restored, or fully
      // unchanged. Never half-restored.
      //
      // Algorithm:
      //   1. Snapshot every current value of every restorable key.
      //   2. Stage the incoming writes in memory (sanitised profile etc.).
      //   3. Apply all writes. If any throws, restore every key from the
      //      snapshot and surface the error — no data loss.
      //   Restore is ADDITIVE: keys absent from the backup are left untouched,
      //   so restoring an older or partial export can never erase data the
      //   backup simply didn't contain (e.g. collections added in a later app
      //   version). A restore can only add or update — never delete.

      // 1. Snapshot
      final snapshot = <String, String?>{};
      for (final key in _exportKeys) {
        snapshot[key] = await EncryptedStore.read(key);
      }
      final priorHasProfile = prefs.getString('has_profile');

      // 2. Stage
      final writes = <String, String>{};
      for (final entry in data.entries) {
        if (entry.key == 'lockMethod') continue; // never restore lock state
        if (entry.key == 'profile') continue; // sanitised below
        // Allowlist-driven: only ever write keys we snapshotted for rollback.
        // A key not in _exportKeys was never captured in the snapshot, so a
        // failed write could not be rolled back — and an attacker-crafted or
        // foreign backup could otherwise smuggle in unsanctioned keys (e.g.
        // strava_tokens, which deliberately never travels in a backup). Skip
        // anything outside the sanctioned set.
        if (!_exportKeys.contains(entry.key)) continue;
        if (entry.value is String) {
          writes[entry.key] = entry.value as String;
        }
      }

      final profileRaw = data['profile'] as String?;
      if (profileRaw != null) {
        // Force lockMethod=none in the incoming profile blob — the PIN hash
        // never travels in a backup, so restoring a locked profile would
        // leave the user locked out with no way back in.
        String safeProfile = profileRaw;
        try {
          final profileMap = jsonDecode(profileRaw) as Map<String, dynamic>;
          profileMap['lockMethod'] = 'none';
          safeProfile = jsonEncode(profileMap);
        } catch (_) {
          // Corrupt blob — write as-is; ProfileNotifier handles it on load.
        }
        writes['profile'] = safeProfile;
      }

      // 3. Apply, with rollback on any failure
      try {
        for (final entry in writes.entries) {
          await EncryptedStore.write(entry.key, entry.value);
        }
        if (writes.containsKey('profile')) {
          // Update the router sentinel so the app routes to /home on restart.
          await prefs.setString('has_profile', '1');
        }
      } catch (e) {
        debugPrint('[backup] restore failed mid-write, rolling back: $e');
        for (final entry in snapshot.entries) {
          try {
            if (entry.value == null) {
              await EncryptedStore.delete(entry.key);
            } else {
              await EncryptedStore.write(entry.key, entry.value!);
            }
          } catch (_) {
            // Best-effort rollback. If it fails too, we've at most lost the
            // single key whose write failed — never a whole-device wipe.
          }
        }
        if (priorHasProfile == null) {
          await prefs.remove('has_profile');
        } else {
          await prefs.setString('has_profile', priorHasProfile);
        }
        if (mounted) _showSnack(l10n.backupRestoreFailed, error: true);
        return;
      }

      // Restore is additive (see header note): we deliberately do NOT delete
      // keys that exist on-device but are missing from the backup. Restoring an
      // older/partial backup must never silently erase newer data. A restore
      // overwrites what the backup contains and leaves everything else intact.

      // Re-materialise any bundled Vision Board photo files so restored vision
      // items resolve their images on a fresh install. Best-effort and additive
      // — backups made before this feature simply have no 'images' block.
      final imagesBlock = parsed['images'];
      if (imagesBlock is Map) {
        for (final entry in imagesBlock.entries) {
          final name = entry.key;
          final b64 = entry.value;
          if (name is String && b64 is String) {
            await VisionImageStore.writeBytesB64(name, b64);
          }
        }
      }

      // Remove any legacy plaintext data and stale lockMethod from prefs.
      await prefs.remove('profile');
      await prefs.remove('lockMethod');

      // Invalidate EVERY provider backed by a restored key — not just the
      // profile. The collection notifiers live in the shell's IndexedStack and
      // keep their pre-restore (often empty) cache otherwise; the UI would show
      // stale data AND, because each mutator writes [new, ...state], the user's
      // next edit would persist that stale list straight over the freshly
      // restored key — silently discarding the whole restore. Refreshing all of
      // them rebuilds each from the just-written encrypted storage.
      _invalidateRestoredProviders();

      if (mounted) {
        _showSnack(l10n.backupRestoredSuccess);
      }
    } catch (e) {
      if (mounted) {
        _showSnack(l10n.backupRestoreFailed, error: true);
      }
    } finally {
      if (mounted) setState(() => _importing = false);
    }
  }

  /// Collect the bare managed image filenames referenced by the vision_board
  /// JSON, so their bytes can be bundled into the backup. Ignores legacy
  /// absolute paths (anything containing a path separator).
  Set<String> _collectVisionImageNames(String? visionRaw) {
    final names = <String>{};
    if (visionRaw == null) return names;
    try {
      final list = jsonDecode(visionRaw) as List<dynamic>;
      for (final item in list) {
        if (item is Map<String, dynamic>) {
          final paths = item['imagePaths'];
          if (paths is List) {
            for (final p in paths) {
              if (p is String &&
                  p.isNotEmpty &&
                  !p.contains('/') &&
                  !p.contains(r'\')) {
                names.add(p);
              }
            }
          }
        }
      }
    } catch (_) {
      // Malformed vision_board JSON — nothing to bundle, export still proceeds.
    }
    return names;
  }

  /// Refresh every provider whose underlying storage key can be overwritten by
  /// a restore, so the live UI reflects the restored data and no stale cached
  /// list can be written back over it. Keep in sync with [_exportKeys].
  void _invalidateRestoredProviders() {
    ref.invalidate(profileProvider);
    ref.invalidate(journalProvider);
    ref.invalidate(gratitudeProvider);
    ref.invalidate(allGratitudeProvider);
    ref.invalidate(slipProvider);
    ref.invalidate(visionBoardProvider);
    ref.invalidate(affirmationProvider);
    ref.invalidate(cravingProvider);
    ref.invalidate(thoughtProvider);
    ref.invalidate(activityProvider);
    ref.invalidate(sleepProvider);
    ref.invalidate(futureLetterProvider);
    ref.invalidate(hardDayProvider);
    ref.invalidate(thoughtRecordProvider);
    ref.invalidate(meetingsProvider);
    ref.invalidate(intentionProvider);
    ref.invalidate(recoveryCapitalProvider);
    ref.invalidate(urgeRideProvider);
    ref.invalidate(hundredDayChallengeProvider);
    // v6.4 planner
    ref.invalidate(plannerGoalProvider);
    ref.invalidate(plannerSessionProvider);
    ref.invalidate(plannerWeightProvider);
    ref.invalidate(plannerActivityProvider);
    ref.invalidate(plannerSettingsProvider);
  }

  void _showSnack(String msg, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
      backgroundColor: error ? AppColors.blush600 : AppColors.forest700,
      behavior: SnackBarBehavior.floating,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 4),
    ));
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 48),
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(-12, 12, 0, 0),
              child: Row(
                children: [
                  const LuxuryBackButton(),
                  const SizedBox(width: 4),
                  Text(l10n.backupTitle,
                      style: AppTextStyles.titleLarge
                          .copyWith(color: AppColors.forest700)),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Export card
            _ActionCard(
              icon: Icons.upload_outlined,
              iconColor: AppColors.forest600,
              chipColor: AppColors.forest50,
              title: l10n.backupExportTitle,
              body: l10n.backupExportDesc,
              buttonLabel: l10n.backupExportButton,
              loading: _exporting,
              onTap: _export,
            ),

            const SizedBox(height: 16),

            // Import card
            _ActionCard(
              icon: Icons.download_outlined,
              iconColor: AppColors.honey600,
              chipColor: AppColors.honey50,
              title: l10n.backupRestoreTitle,
              body: l10n.backupRestoreDesc,
              buttonLabel: l10n.backupRestoreButton,
              loading: _importing,
              onTap: _import,
              buttonColor: AppColors.honey500,
            ),

            const SizedBox(height: 24),

            // What's included
            SolidCard(
              borderRadius: AppRadius.xl,
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(l10n.backupWhatsIncludedTitle,
                      style: AppTextStyles.titleSmall),
                  const SizedBox(height: 14),
                  for (final item in [
                    (Icons.person_outline_rounded, l10n.backupItemProfile),
                    (Icons.menu_book_outlined, l10n.backupItemJournal),
                    (Icons.spa_outlined, l10n.backupItemGratitude),
                    (Icons.timeline_rounded, l10n.backupItemSlipLog),
                    (Icons.lock_outline_rounded, l10n.backupItemSecurity),
                    (Icons.star_outline_rounded, l10n.backupItemVisionBoard),
                    (Icons.format_quote_rounded, l10n.backupItemAffirmations),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: Row(children: [
                        Icon(item.$1, size: 16, color: AppColors.forest600),
                        const SizedBox(width: 10),
                        Text(item.$2, style: AppTextStyles.bodyMedium),
                      ]),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Privacy note
            LuxuryCard(
              backgroundColor: AppColors.stone100,
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.lock_outline_rounded,
                      size: 16, color: AppColors.stone500),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n.backupPrivacyWarning,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone600),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action card ──────────────────────────────────────────────────────────────

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.iconColor,
    required this.chipColor,
    required this.title,
    required this.body,
    required this.buttonLabel,
    required this.loading,
    required this.onTap,
    this.buttonColor,
  });

  final IconData icon;
  final Color iconColor;
  final Color chipColor;
  final String title;
  final String body;
  final String buttonLabel;
  final bool loading;
  final VoidCallback onTap;
  final Color? buttonColor;

  @override
  Widget build(BuildContext context) => SolidCard(
        borderRadius: AppRadius.xl,
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: AppRadius.md,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 14),
              Text(title, style: AppTextStyles.titleSmall),
            ]),
            const SizedBox(height: 12),
            Text(body,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone600, height: 1.5)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: loading ? null : onTap,
                style: FilledButton.styleFrom(
                  backgroundColor: buttonColor ?? AppColors.forest600,
                  minimumSize: const Size.fromHeight(48),
                  shape:
                      const RoundedRectangleBorder(borderRadius: AppRadius.lg),
                ),
                child: loading
                    ? SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: AppColors.onForest, strokeWidth: 2))
                    : Text(buttonLabel,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: AppColors.onForest)),
              ),
            ),
          ],
        ),
      );
}
