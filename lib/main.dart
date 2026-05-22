import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'l10n/app_localizations.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';
import 'utils/haptic_service.dart';
import 'utils/notification_service.dart';
import 'utils/secure_window.dart';
// ─── Screen imports ───────────────────────────────────────────────────────────
import 'screens/backup_screen.dart';
import 'screens/crisis_screen.dart';
import 'screens/emergency_screen.dart';
import 'screens/groups_screen.dart';
import 'screens/history_screen.dart';
import 'screens/home_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/journal_screen.dart';
import 'screens/lock_screen.dart';
import 'screens/meetings_screen.dart';
import 'screens/milestone_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/puzzle_screen.dart';
import 'screens/recovery_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/cbt_screen.dart';
import 'screens/future_letter_screen.dart';
import 'screens/heatmap_screen.dart';
import 'screens/pre_craving_plan_screen.dart';
import 'screens/slip_log_screen.dart';
import 'screens/slip_support_screen.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

void main() async {
  // Wrap the entire startup in a guarded zone. Any uncaught exception
  // before runApp() leaves the user on the white launch_background forever
  // — we've been bitten by this twice (notification plugin init, Keystore
  // unavailable right after APK replace). Every pre-runApp call is now
  // individually try/caught with safe defaults so runApp() ALWAYS executes.
  WidgetsFlutterBinding.ensureInitialized();

  // In release mode the default ErrorWidget is a plain grey/blank box, which
  // is indistinguishable from a launch failure. Replace it with a visible
  // fallback so any build-time exception shows something the user can see.
  ErrorWidget.builder = (FlutterErrorDetails details) {
    debugPrint('[ErrorWidget] ${details.exception}\n${details.stack}');
    return Container(
      color: const Color(0xFFF5EFE7),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(24),
      child: const Text(
        'Something went wrong loading this screen.\nPlease restart the app.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Color(0xFF2D6A4F),
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  };

  // Load the full IANA timezone database and point tz.local at the device's
  // real timezone. This is required for correct DST handling — without it,
  // notifications are anchored to the UTC offset at schedule time and drift
  // by ±1 hour when clocks change (UK, EU, US, AUS users are all affected).
  try {
    tz.initializeTimeZones();
    final String deviceTz = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(deviceTz));
  } catch (e) {
    debugPrint('[main] timezone init failed: $e');
  }

  // Initialise notification channel and schedule daily reminders.
  // Both calls already swallow their own errors, but wrap as belt-and-braces.
  try {
    await NotificationService.init();
    // Re-request the POST_NOTIFICATIONS permission on every launch.
    // On Android 13+ the permission can be reset when the APK is replaced
    // (fresh install over existing). requestPermission() is a no-op when
    // the permission is already granted, so this is safe to call every time.
    await NotificationService.requestPermission();
    await NotificationService.scheduleFromPrefs();
  } catch (e) {
    debugPrint('[main] notification setup failed: $e');
  }

  // Lock to portrait
  try {
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  } catch (e) {
    debugPrint('[main] orientation lock failed: $e');
  }

  // Transparent status bar, dark icons on cream background
  try {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: AppColors.card,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
  } catch (e) {
    debugPrint('[main] system UI overlay failed: $e');
  }

  // SharedPreferences is a singleton — caching the instance lets the GoRouter
  // redirect read profile state synchronously on every navigation. This is
  // what prevents the onboarding loop: a stale `hasProfile=false` baked into
  // `initialLocation` at startup would otherwise win after any activity recreate.
  bool hasProfile = false;
  String lockMethod = 'none';
  try {
    final prefs = await SharedPreferences.getInstance();
    _prefsCache = prefs;

    // hasProfile uses the 'has_profile' presence sentinel for current installs
    // and falls back to the legacy 'profile' key (which used to hold the JSON
    // directly) so users who upgrade past the migration boundary land in /home
    // instead of being bounced through onboarding again.
    hasProfile = prefs.getString('has_profile') != null ||
        prefs.getString('profile') != null;
    lockMethod = prefs.getString('lockMethod') ?? 'none';
  } catch (e) {
    // If prefs are unreadable we fall through to onboarding rather than
    // blanking. _prefsCache stays null; the router redirect handles that.
    debugPrint('[main] SharedPreferences load failed: $e');
  }

  runApp(
    ProviderScope(
      child: JourneyForwardApp(
        hasProfile: hasProfile,
        lockMethod: lockMethod,
      ),
    ),
  );
}

/// Synchronous cached SharedPreferences. Set once in main() before runApp.
/// Used by the GoRouter redirect to make routing decisions without async.
SharedPreferences? _prefsCache;

// ─── Root app ─────────────────────────────────────────────────────────────────

class JourneyForwardApp extends ConsumerStatefulWidget {
  const JourneyForwardApp({
    super.key,
    required this.hasProfile,
    required this.lockMethod,
  });

  final bool hasProfile;
  final String lockMethod;

  @override
  ConsumerState<JourneyForwardApp> createState() => _JourneyForwardAppState();
}

class _JourneyForwardAppState extends ConsumerState<JourneyForwardApp>
    with WidgetsBindingObserver {
  // Router is created ONCE and never recreated on rebuilds.
  // Previously JourneyForwardApp was a ConsumerWidget, so every time
  // profileProvider emitted (e.g. when onboarding saved the profile)
  // build() ran again, calling _buildRouter() with hasProfile=false and
  // producing a brand-new GoRouter whose initialLocation='/onboarding' —
  // which reset navigation back to the start (the loop bug).
  late final GoRouter _router;

  /// Tracks when the app went to the background. We use a grace window
  /// (~10 seconds) before forcing a re-lock so quick context switches
  /// (typing a 2FA code, accepting a system dialog) don't kick the user
  /// back to the lock screen.
  DateTime? _backgroundedAt;
  static const _relockGrace = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _router = _buildRouter(
      hasProfile: widget.hasProfile,
      lockMethod: widget.lockMethod,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.hidden:
        _backgroundedAt = DateTime.now();
        break;

      case AppLifecycleState.resumed:
        // Re-lock if (a) the user has a lock configured, (b) we were
        // actually backgrounded (not just inactive for a system dialog),
        // and (c) we exceeded the grace window. This closes the gap where
        // anyone could pick up an unlocked phone and re-foreground the
        // app to see all of the user's recovery data.
        final bgAt = _backgroundedAt;
        _backgroundedAt = null;
        if (bgAt == null) return;
        if (DateTime.now().difference(bgAt) < _relockGrace) return;

        final prefs = _prefsCache;
        if (prefs == null) return;
        final lockMethod = prefs.getString('lockMethod') ?? 'none';
        if (lockMethod == 'none') return;

        // Don't redirect if we're already on the lock screen or onboarding.
        final currentLocation =
            _router.routerDelegate.currentConfiguration.uri.toString();
        if (currentLocation == '/lock' || currentLocation == '/onboarding') {
          return;
        }
        _router.go('/lock');
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Keep H in sync whenever the profile changes — but the router
    // is never touched here, so profile updates can't reset navigation.
    final profile = ref.watch(profileProvider).valueOrNull;
    H.sync(profile?.hapticsEnabled ?? true);

    return MaterialApp.router(
      title: 'Journey Forward',
      theme: buildAppTheme(highContrast: profile?.highContrast ?? false),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Only English is shipped as a real translation. The other .arb files
      // (af/es/pt/zu) currently mirror English verbatim — exposing them would
      // mislead users who pick their language and get English back. Restore
      // here once a locale has a genuine translation pass.
      supportedLocales: const [Locale('en')],
      routerConfig: _router,
    );
  }
}

// ─── Router ───────────────────────────────────────────────────────────────────

GoRouter _buildRouter({
  required bool hasProfile,
  required String lockMethod,
}) {
  final String initialRoute =
      !hasProfile ? '/onboarding' : (lockMethod != 'none' ? '/lock' : '/home');

  return GoRouter(
    initialLocation: initialRoute,
    debugLogDiagnostics: false,
    // ── Router-level redirect ────────────────────────────────────────────────
    // Runs on EVERY navigation. Reads SharedPreferences synchronously via the
    // cached singleton (populated in main()). This is what definitively kills
    // the onboarding loop: even if the Android activity is recreated by an
    // OS dialog (notification permission, exact alarm) and Flutter restarts,
    // any attempt to navigate to /onboarding when a profile is already saved
    // is rewritten to /home. Conversely, any attempt to reach /home without
    // a profile is rewritten to /onboarding — replacing the per-screen guards
    // that used to live in home_screen.dart and settings_screen.dart.
    redirect: (context, state) {
      final prefs = _prefsCache;
      if (prefs == null) return null; // unreachable in practice
      // Same logic as main(): accept either the new 'has_profile' sentinel
      // or the legacy plaintext 'profile' key.
      final hasProfileNow = prefs.getString('has_profile') != null ||
          prefs.getString('profile') != null;
      final loc = state.matchedLocation;

      // No profile yet — only /onboarding is allowed.
      if (!hasProfileNow) {
        return loc == '/onboarding' ? null : '/onboarding';
      }

      // Profile exists — never let the user land back on /onboarding.
      if (loc == '/onboarding') return '/home';

      return null;
    },
    routes: [
      // ── Onboarding ──────────────────────────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (_, __) => const OnboardingScreen(),
      ),

      // ── Lock screen ─────────────────────────────────────────────────────────
      GoRoute(
        path: '/lock',
        builder: (_, __) => const LockScreen(),
      ),

      // ── Main shell (bottom nav) ──────────────────────────────────────────────
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            _AppShell(navigationShell: navigationShell),
        branches: [
          // Tab 0 — Home
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (_, __) => const HomeScreen(),
            ),
          ]),
          // Tab 1 — Progress
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/progress',
              builder: (_, __) => const ProgressScreen(),
            ),
          ]),
          // Tab 2 — Emergency / Calm Toolkit
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/emergency',
              builder: (_, __) => const EmergencyScreen(),
            ),
          ]),
          // Tab 3 — Journal
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/journal',
              builder: (_, __) => const JournalScreen(),
            ),
          ]),
          // Tab 4 — Profile / Settings
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/settings',
              builder: (_, __) => const SettingsScreen(),
            ),
          ]),
        ],
      ),

      // ── Deep-link screens (launched from Home cards or Settings rows) ────────
      GoRoute(
        path: '/milestone',
        builder: (_, __) => const MilestoneScreen(),
      ),
      GoRoute(
        path: '/recovery',
        builder: (_, __) => const RecoveryScreen(),
      ),
      GoRoute(
        path: '/insights',
        builder: (_, __) => const InsightsScreen(),
      ),
      GoRoute(
        path: '/heatmap',
        builder: (_, __) => const HeatmapScreen(),
      ),
      GoRoute(
        path: '/puzzle',
        builder: (_, __) => const PuzzleScreen(),
      ),
      GoRoute(
        path: '/cbt',
        builder: (_, __) => const CbtScreen(),
      ),
      GoRoute(
        path: '/history',
        builder: (_, __) => const HistoryScreen(),
      ),
      GoRoute(
        path: '/slip',
        builder: (_, __) => const SlipSupportScreen(),
      ),
      GoRoute(
        path: '/slip-log',
        builder: (_, __) => const SlipLogScreen(),
      ),
      GoRoute(
        path: '/crisis',
        builder: (_, __) => const CrisisScreen(),
      ),
      GoRoute(
        path: '/groups',
        builder: (_, __) => const GroupsScreen(),
      ),
      GoRoute(
        path: '/meetings',
        builder: (_, __) => const MeetingsScreen(),
      ),
      GoRoute(
        path: '/backup',
        builder: (_, __) => const BackupScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, __) => const PrivacyScreen(),
      ),
      GoRoute(
        path: '/future-letter',
        builder: (_, __) => const FutureLetterScreen(),
      ),
      GoRoute(
        path: '/pre-craving-plan',
        builder: (_, __) => const PreCravingPlanScreen(),
      ),
    ],
  );
}

// ─── App shell (bottom nav bar) ──────────────────────────────────────────────

// Tab index that requires screenshot/recording protection.
const _kSecureTabIndex = 3; // Journal

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  void _onTap(int i) {
    // navigationShell.currentIndex is the tab we're LEAVING — read it before
    // calling goBranch() so we know the direction of the switch.
    final prev = navigationShell.currentIndex;
    if (i == _kSecureTabIndex && prev != _kSecureTabIndex) {
      SecureWindow.enable();
    } else if (i != _kSecureTabIndex && prev == _kSecureTabIndex) {
      SecureWindow.disable();
    }
    navigationShell.goBranch(i, initialLocation: i == prev);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      _NavTab(
          label: l10n.navHome,
          icon: Icons.home_outlined,
          activeIcon: Icons.home_rounded),
      _NavTab(
          label: l10n.navProgress,
          icon: Icons.monitor_heart_outlined,
          activeIcon: Icons.monitor_heart_rounded),
      _NavTab(
          label: l10n.navToolkit,
          icon: Icons.spa_outlined,
          activeIcon: Icons.spa_rounded),
      _NavTab(
          label: l10n.navJournal,
          icon: Icons.menu_book_outlined,
          activeIcon: Icons.menu_book_rounded),
      _NavTab(
          label: l10n.navProfile,
          icon: Icons.person_outline,
          activeIcon: Icons.person_rounded),
    ];
    return Scaffold(
      // Stable test anchor — see test/widget/app_smoke_test.dart. The
      // presence of this key (and only this key) proves the router put
      // us inside the StatefulShellRoute, not on /onboarding or /lock.
      key: const Key('app-shell'),
      body: navigationShell,
      bottomNavigationBar: _StillwaterNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: _onTap,
        tabs: tabs,
      ),
    );
  }
}

class _NavTab {
  const _NavTab({
    required this.label,
    required this.icon,
    required this.activeIcon,
  });
  final String label;
  final IconData icon;
  final IconData activeIcon;
}

// ─── Bottom nav bar — Stillwater style ───────────────────────────────────────

class _StillwaterNavBar extends StatelessWidget {
  const _StillwaterNavBar(
      {required this.currentIndex, required this.onTap, required this.tabs});
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<_NavTab> tabs;

  @override
  Widget build(BuildContext context) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
          child: Container(
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: const BorderRadius.all(Radius.circular(36)),
              border: Border.all(color: AppColors.softBorder),
              boxShadow: AppShadows.luxury,
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final tab = tabs[i];
                final selected = i == currentIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: const BorderRadius.all(Radius.circular(28)),
                    splashColor: AppColors.mintChip,
                    highlightColor: Colors.transparent,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(selected ? tab.activeIcon : tab.icon,
                            size: 24,
                            color: selected
                                ? AppColors.forest
                                : AppColors.mistGrey),
                        const SizedBox(height: 5),
                        Text(tab.label,
                            style: AppTextStyles.caption.copyWith(
                              color: selected
                                  ? AppColors.forest
                                  : AppColors.mistGrey,
                              fontWeight:
                                  selected ? FontWeight.w700 : FontWeight.w500,
                            )),
                        const SizedBox(height: 5),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: selected ? 5 : 0,
                          height: 5,
                          decoration: const BoxDecoration(
                            color: AppColors.forest,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      );
}
