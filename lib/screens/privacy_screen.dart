import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Privacy Screen ───────────────────────────────────────────────────────────

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final sections = _buildSections(l10n);
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          cacheExtent: 500,
          slivers: [

            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: AppColors.stone700),
                      onPressed: () {
                        H.light();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 4),
                    Text(l10n.privacyTitle,
                        style: AppTextStyles.titleLarge
                            .copyWith(color: AppColors.forest700)),
                  ],
                ),
              ),
            ),

            // ── Hero commitment ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: LuxuryCard(
                  backgroundColor: AppColors.forest800,
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.lock_rounded,
                          color: AppColors.forest300, size: 28),
                      const SizedBox(height: 12),
                      Text(l10n.privacyAbsoluteHeadline,
                          style: AppTextStyles.headlineSerif
                              .copyWith(color: Colors.white, fontSize: 20)),
                      const SizedBox(height: 8),
                      Text(l10n.privacyCommitment,
                        style: AppTextStyles.bodyMedium
                            .copyWith(color: AppColors.forest200, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Sections ────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 48),
              sliver: SliverList.separated(
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemCount: sections.length,
                itemBuilder: (_, i) => RepaintBoundary(child: _PrivacySection(section: sections[i])),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section data ─────────────────────────────────────────────────────────────

class _Section {
  const _Section({
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;
}

List<_Section> _buildSections(AppLocalizations l10n) => [
  _Section(icon: Icons.smartphone_outlined,    title: l10n.privacyAllDataOnDevice,     body: l10n.privacyAllDataOnDeviceBody),
  _Section(icon: Icons.wifi_off_rounded,       title: l10n.privacyNoInternet,          body: l10n.privacyNoInternetBody),
  _Section(icon: Icons.analytics_outlined,     title: l10n.privacyNoAnalytics,         body: l10n.privacyNoAnalyticsBody),
  _Section(icon: Icons.contact_emergency_outlined, title: l10n.privacyEmergencyContacts, body: l10n.privacyEmergencyContactsBody),
  _Section(icon: Icons.backup_outlined,        title: l10n.privacyBackupRestore,       body: l10n.privacyBackupRestoreBody),
  _Section(icon: Icons.lock_outline_rounded,   title: l10n.privacyPINBiometric,        body: l10n.privacyPINBiometricBody),
  _Section(icon: Icons.delete_outline_rounded, title: l10n.privacyHowToDelete,         body: l10n.privacyHowToDeleteBody),
  _Section(icon: Icons.child_care_outlined,    title: l10n.privacyChildrenPrivacy,     body: l10n.privacyChildrenPrivacyBody),
  _Section(icon: Icons.update_rounded,         title: l10n.privacyPolicyUpdates,       body: l10n.privacyPolicyUpdatesBody),
];

// ─── Privacy section card ─────────────────────────────────────────────────────

class _PrivacySection extends StatelessWidget {
  const _PrivacySection({required this.section});
  final _Section section;

  @override
  Widget build(BuildContext context) => SolidCard(
    borderRadius: AppRadius.xl,
    padding: const EdgeInsets.all(18),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.forest50,
            borderRadius: AppRadius.md,
          ),
          child: Icon(section.icon,
              color: AppColors.forest600, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(section.title, style: AppTextStyles.titleSmall),
              const SizedBox(height: 8),
              Text(section.body,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone600, height: 1.55)),
            ],
          ),
        ),
      ],
    ),
  );
}
