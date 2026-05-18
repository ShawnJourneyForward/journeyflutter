import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

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
  // lockMethod is intentionally excluded: the PIN hash lives in secure storage
  // and cannot travel with the backup. Importing lockMethod without a hash
  // would silently break the lock screen.
];

// ─── Backup Screen ────────────────────────────────────────────────────────────

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  bool _exporting = false;
  bool _importing = false;

  // ── Export ─────────────────────────────────────────────────────────────────

  Future<void> _export() async {
    setState(() => _exporting = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = <String, String>{};
      for (final key in _exportKeys) {
        final val = prefs.getString(key);
        if (val != null) data[key] = val;
      }

      final payload = const JsonEncoder.withIndent('  ').convert({
        'app': 'Journey Forward',
        'version': '1',
        'exportedAt': DateTime.now().toIso8601String(),
        'data': data,
      });

      final file =
          File('${Directory.systemTemp.path}/journey_forward_backup.json');
      await file.writeAsString(payload);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'application/json')],
        subject: 'Journey Forward Backup',
      );
    } catch (e) {
      if (mounted) {
        _showSnack(AppLocalizations.of(context).backupExportFailed, error: true);
      }
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
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
          title: Text(dialogL10n.backupConfirmTitle, style: AppTextStyles.titleMedium),
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
                  style: AppTextStyles.labelMedium
                      .copyWith(color: Colors.white)),
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
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        setState(() => _importing = false);
        return;
      }

      final raw = await File(result.files.single.path!).readAsString();
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
      for (final entry in data.entries) {
        // Never restore lockMethod — the PIN hash is not in the backup file.
        // Restoring it without the hash would silently break the lock screen.
        if (entry.key == 'lockMethod') continue;
        await prefs.setString(entry.key, entry.value as String);
      }
      // Clear any pre-existing lock setting so the app starts unlocked.
      await prefs.remove('lockMethod');

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
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        size: 20, color: AppColors.stone700),
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.of(context).pop();
                    },
                  ),
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
                    (Icons.person_outline_rounded,   l10n.backupItemProfile),
                    (Icons.menu_book_outlined,        l10n.backupItemJournal),
                    (Icons.favorite_border_rounded,   l10n.backupItemGratitude),
                    (Icons.timeline_rounded,          l10n.backupItemSlipLog),
                    (Icons.lock_outline_rounded,      l10n.backupItemSecurity),
                    (Icons.star_outline_rounded,      l10n.backupItemVisionBoard),
                    (Icons.format_quote_rounded,      l10n.backupItemAffirmations),
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
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
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
