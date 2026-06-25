// Strava connect / privacy bottom sheet.
//
// A privacy-first explainer for the optional Strava import: it states plainly
// that activities are fetched directly device-to-Strava with no Journey
// Forward server, then offers the brand-compliant "Connect with Strava"
// action (or a "Disconnect Strava" action when already connected). The
// connect flow runs the on-device OAuth handshake in StravaService, marks the
// settings flag, imports recent activities, and confirms the count.
//
// All copy comes from the l10n getters — no hardcoded prose. Visual idiom
// matches the meetings editor sheet (card surface, rounded top, grabber).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../services/strava_config.dart';
import '../services/strava_service.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

/// Strava brand orange — fixed by Strava's brand guidelines, NOT a Stillwater
/// palette token (the palette intentionally has no orange/blue).
const Color _kStravaOrange = Color(0xFFFC4C02);

/// Present the Strava connect / privacy bottom sheet.
Future<void> showStravaSheet(BuildContext context, WidgetRef ref) async {
  H.light();
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _StravaSheet(),
  );
}

class _StravaSheet extends ConsumerStatefulWidget {
  const _StravaSheet();

  @override
  ConsumerState<_StravaSheet> createState() => _StravaSheetState();
}

class _StravaSheetState extends ConsumerState<_StravaSheet> {
  bool _busy = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: AppTextStyles.bodyMedium),
        backgroundColor: AppColors.forest700,
      ),
    );
  }

  Future<void> _connect() async {
    final l10n = AppLocalizations.of(context);

    if (!stravaConfigured) {
      _snack(l10n.plannerStravaNotConfigured);
      return;
    }

    H.medium();
    setState(() => _busy = true);
    try {
      final ok = await StravaService.connect();
      if (!ok) {
        // Cancelled or failed — leave state untouched, no noisy error.
        if (mounted) setState(() => _busy = false);
        return;
      }

      await ref.read(plannerSettingsProvider.notifier).setStravaConnected(true);

      // Import everything since the last sync (null = bounded window first time).
      final lastSync =
          ref.read(plannerSettingsProvider).valueOrNull?.lastStravaSync;
      final result = await StravaService.fetchActivities(after: lastSync);
      final activityNotifier = ref.read(plannerActivityProvider.notifier);
      for (final a in result.activities) {
        await activityNotifier.addImported(a);
      }
      final imported = result.activities.length;

      // Advance the sync cursor so a retry RESUMES instead of restarting. Use
      // the newest imported activity's date when we have one (so a rate-limited
      // partial sync still moves forward); otherwise stamp now.
      DateTime? newest;
      for (final a in result.activities) {
        if (newest == null || a.date.isAfter(newest)) newest = a.date;
      }
      await ref
          .read(plannerSettingsProvider.notifier)
          .setLastStravaSync(newest ?? DateTime.now());

      if (mounted) {
        // Surface the rate-limit notice but still confirm what we DID import.
        if (result.rateLimited) _snack(l10n.plannerStravaRateLimited);
        _snack(l10n.plannerStravaImported(imported));
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _disconnect() async {
    H.medium();
    setState(() => _busy = true);
    try {
      await StravaService.disconnect();
      await ref.read(plannerSettingsProvider.notifier).disconnectStrava();
    } finally {
      if (mounted) {
        setState(() => _busy = false);
        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final connected =
        ref.watch(plannerSettingsProvider).valueOrNull?.stravaConnected ??
            false;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grabber
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: AppColors.stone200,
                    borderRadius: AppRadius.pill,
                  ),
                ),
              ),

              Text(
                l10n.plannerStravaPrivacyTitle,
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.forest700),
              ),
              const SizedBox(height: 10),
              Text(
                l10n.plannerStravaPrivacyBody,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone600),
              ),
              const SizedBox(height: 18),

              // Privacy assurances
              _Bullet(
                icon: Icons.visibility_off_rounded,
                label: l10n.plannerStravaReadOnly,
              ),
              const SizedBox(height: 10),
              _Bullet(
                icon: Icons.phonelink_lock_rounded,
                label: l10n.plannerStravaDirect,
              ),
              const SizedBox(height: 10),
              _Bullet(
                icon: Icons.cloud_off_rounded,
                label: l10n.plannerStravaNoServer,
              ),
              const SizedBox(height: 24),

              // Primary action
              if (connected)
                _DisconnectButton(onPressed: _busy ? null : _disconnect)
              else
                _ConnectButton(onPressed: _busy ? null : _connect, busy: _busy),

              const SizedBox(height: 18),

              // Powered-by-Strava attribution mark (brand requirement).
              Center(
                child: Text(
                  l10n.plannerPoweredByStrava,
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.stone400,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A single privacy assurance row: forest-tinted icon chip + label.
class _Bullet extends StatelessWidget {
  const _Bullet({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.mintChip,
            borderRadius: AppRadius.md,
          ),
          alignment: Alignment.center,
          child: Icon(icon, size: 18, color: AppColors.forest700),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.titleSmall
                .copyWith(color: AppColors.stoneText),
          ),
        ),
      ],
    );
  }
}

/// Brand-compliant orange "Connect with Strava" button. Prefers the official
/// Strava brand asset when bundled; otherwise renders a styled fallback.
class _ConnectButton extends StatelessWidget {
  const _ConnectButton({required this.onPressed, required this.busy});

  final VoidCallback? onPressed;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: Material(
        color: _kStravaOrange,
        borderRadius: AppRadius.lg,
        child: InkWell(
          borderRadius: AppRadius.lg,
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 14),
            child: Center(
              child: busy
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.4,
                      ),
                    )
                  : Image.asset(
                      // Official Strava "Connect with Strava" button asset.
                      // TODO: drop official Strava brand asset here for store
                      // compliance (assets/strava/btn_strava_connect.png).
                      'assets/strava/btn_strava_connect.png',
                      height: 24,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Text(
                        l10n.plannerConnectStrava,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white),
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Outlined "Disconnect Strava" action shown when already connected.
class _DisconnectButton extends StatelessWidget {
  const _DisconnectButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.blush600,
          side: BorderSide(color: AppColors.blush100, width: 1.5),
          minimumSize: const Size.fromHeight(50),
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
        ),
        child: Text(
          l10n.plannerStravaDisconnect,
          style: AppTextStyles.labelLarge.copyWith(color: AppColors.blush600),
        ),
      ),
    );
  }
}
