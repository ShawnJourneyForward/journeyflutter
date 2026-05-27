import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/backup_crypto.dart';
import '../utils/encrypted_store.dart';
import '../utils/haptic_service.dart';

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
  // lockMethod is intentionally excluded: the PIN hash lives in secure storage
  // and cannot travel with the backup. Importing lockMethod without a hash
  // would silently break the lock screen.
];

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
      for (final key in _exportKeys) {
        final val = await EncryptedStore.read(key);
        if (val != null) data[key] = val;
      }

      final payload = const JsonEncoder.withIndent('  ').convert({
        'app': 'Journey Forward',
        'version': '1',
        'exportedAt': DateTime.now().toIso8601String(),
        'data': data,
      });

      final fileContents =
          usingEncryption ? BackupCrypto.encrypt(payload, passphrase) : payload;
      final filename = usingEncryption
          ? 'journey_forward_backup.jfwbk'
          : 'journey_forward_backup.json';

      final file = File('${Directory.systemTemp.path}/$filename');
      await file.writeAsString(fileContents);

      await Share.shareXFiles(
        [
          XFile(file.path,
              mimeType: usingEncryption
                  ? 'application/octet-stream'
                  : 'application/json'),
        ],
        subject: usingEncryption
            ? 'Journey Forward Backup (encrypted)'
            : 'Journey Forward Backup',
      );
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
              forExport ? 'Protect your backup?' : 'Enter backup passphrase',
              style: AppTextStyles.titleMedium,
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  forExport
                      ? 'Set a passphrase to encrypt the backup file. Without it, anyone with the file can read your journal.'
                      : 'This file is encrypted. Type the passphrase you used when exporting.',
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone600, height: 1.4),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: ctrl,
                  obscureText: true,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Passphrase',
                    border: OutlineInputBorder(),
                  ),
                ),
                if (forExport) ...[
                  const SizedBox(height: 10),
                  TextField(
                    controller: confirmCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm passphrase',
                      border: OutlineInputBorder(),
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
                child: Text('Cancel',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.stone500)),
              ),
              if (forExport)
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(''),
                  child: Text('Skip (plain JSON)',
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.stone500)),
                ),
              FilledButton(
                style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest700),
                onPressed: () {
                  if (ctrl.text.isEmpty) {
                    setLocal(() => error = 'Passphrase cannot be empty.');
                    return;
                  }
                  if (forExport && ctrl.text != confirmCtrl.text) {
                    setLocal(() => error = 'Passphrases do not match.');
                    return;
                  }
                  if (forExport && ctrl.text.length < 8) {
                    setLocal(() =>
                        error = 'Use at least 8 characters — longer is safer.');
                    return;
                  }
                  Navigator.of(ctx).pop(ctrl.text);
                },
                child: Text(forExport ? 'Encrypt' : 'Unlock',
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
          backgroundColor: Colors.white,
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
      final prefs = await SharedPreferences.getInstance();

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
      //   4. Only after every write has succeeded, delete the keys that
      //      were present pre-restore but absent from the backup. This
      //      gives the user the "true replace" semantics they expect
      //      without risking the half-restored failure mode.

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

      // 4. All writes succeeded — now apply true-replace semantics by
      // deleting keys that existed before but weren't in the backup. Safe
      // to do last: if this step somehow fails, the user still has the
      // restored data plus a few stale extras (not a loss).
      final restoredKeys = writes.keys.toSet();
      for (final key in _exportKeys) {
        if (restoredKeys.contains(key)) continue;
        await EncryptedStore.delete(key);
      }

      // Remove any legacy plaintext data and stale lockMethod from prefs.
      await prefs.remove('profile');
      await prefs.remove('lockMethod');

      // Invalidate the profile provider so the UI reloads from encrypted
      // storage immediately without requiring an app restart.
      ref.invalidate(profileProvider);

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
                  const Icon(Icons.lock_outline_rounded,
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
    this.buttonColor = AppColors.forest600,
  });

  final IconData icon;
  final Color iconColor;
  final Color chipColor;
  final String title;
  final String body;
  final String buttonLabel;
  final bool loading;
  final VoidCallback onTap;
  final Color buttonColor;

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
                  backgroundColor: buttonColor,
                  minimumSize: const Size.fromHeight(48),
                  shape:
                      const RoundedRectangleBorder(borderRadius: AppRadius.lg),
                ),
                child: loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(buttonLabel,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      );
}
