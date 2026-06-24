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
import 'l10n/app_locales.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';
import 'utils/haptic_service.dart';
import 'utils/locale_format.dart';
import 'utils/notification_service.dart';
import 'utils/secure_window.dart';
import 'utils/storage_migration.dart';
import 'utils/vision_image_store.dart';
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
import 'screens/hundred_day_challenge_screen.dart';
import 'screens/learned_screen.dart';
import 'screens/pre_craving_plan_screen.dart';
import 'screens/slip_log_screen.dart';
import 'screens/slip_support_screen.dart';
import 'screens/tipp_screen.dart';
import 'screens/urge_timer_screen.dart';
import 'screens/weekly_care_summary_screen.dart';

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

  // Initialise notification channel and re-schedule any already-saved
  // reminders. We DO NOT request POST_NOTIFICATIONS here — that prompt is
  // raised inside the onboarding "notifications" step (after the user has
  // chosen what they want reminded about) and inside Settings when the
  // user toggles a reminder on. Asking at cold-start surprises the user
  // and is the kind of permission ask Play reviewers flag.
  try {
    await NotificationService.init();
    final scheduleResult = await NotificationService.scheduleFromPrefs();
    if (!scheduleResult.success) {
      debugPrint(
          '[main] notification scheduling failed: ${scheduleResult.error}');
    }
  } catch (e) {
    debugPrint('[main] notification setup failed: $e');
  }

  // Prepare the Vision Board image directory and cache its path so photo
  // rendering can resolve persisted filenames synchronously. Guarded — a
  // failure here must never block startup (it only degrades photo display).
  try {
    await VisionImageStore.init();
  } catch (e) {
    debugPrint('[main] vision image store init failed: $e');
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

  // Wire intl to the active locale so dates and money follow the chosen
  // language (not en_US). Pre-load date symbols for every enabled language,
  // then point Intl at the saved/device locale before the first frame.
  try {
    await initIntlDateFormatting();
    final device = WidgetsBinding.instance.platformDispatcher.locale;
    applyIntlLocale(
        effectiveLocaleTag(LocaleNotifier.fromRaw(initialLocaleRaw), device));
  } catch (e) {
    debugPrint('[main] intl locale init failed: $e');
  }

  // Transparent status bar, dark icons on cream background
  try {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
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

    // One-shot migration: move all sensitive collections from plain
    // SharedPreferences into EncryptedStore (Android Keystore-backed).
    // Idempotent — already-migrated keys are no-ops.
    await StorageMigration.migrateAll(prefs);

    // hasProfile uses the 'has_profile' presence sentinel for current installs
    // and falls back to the legacy 'profile' key (which used to hold the JSON
    // directly) so users who upgrade past the migration boundary land in /home
    // instead of being bounced through onboarding again.
    hasProfile = prefs.getString('has_profile') != null ||
        prefs.getString('profile') != null;
    lockMethod = prefs.getString('lockMethod') ?? 'none';
    initialThemeModeRaw = prefs.getString(ThemeModeNotifier.prefsKey);
    initialLocaleRaw = prefs.getString(LocaleNotifier.prefsKey);
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

  // Whether we've raised FLAG_SECURE for the current background excursion, so
  // the app-switcher / Recents thumbnail shows a blank tile for EVERY screen
  // (not just the per-tab-protected Journal). Guards against double-counting
  // when both `paused` and `hidden` fire for one background cycle.
  bool _backgroundSecured = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Cold-start consistency: with a lock configured the initial route is
    // /lock, but the gate flag has to be up too — otherwise programmatic
    // navigation (e.g. the SOS widget's route below) could land past the
    // lock before the user has authenticated.
    LockGate.locked = widget.lockMethod != 'none';
    // A configured lock means the user wants privacy → hold FLAG_SECURE for the
    // whole session. This covers EVERY screen (including CBT, thought records,
    // journal detail, heatmap, vision detail, future letter — which have no
    // per-screen SecureScreen) against screenshots and the Recents preview,
    // not just the per-tab-protected Journal. Reference-counted, so it composes
    // with the per-tab toggle and the background blank.
    if (widget.lockMethod != 'none') {
      SecureWindow.enable();
    }
    _router = _buildRouter(
      hasProfile: widget.hasProfile,
      lockMethod: widget.lockMethod,
    );
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _consumeWidgetRoute());
  }

  static const _widgetRouteChannel =
      MethodChannel('com.journeyforward/widget_route');

  /// Drains a route requested by a home-screen widget tap (SOS → urge
  /// timer). Only exact, known-safe routes are honoured — the Intent extra
  /// must never become a general navigation surface.
  Future<void> _consumeWidgetRoute() async {
    try {
      final route =
          await _widgetRouteChannel.invokeMethod<String>('takePendingRoute');
      if (route == '/urge-timer') _router.go('/urge-timer');
    } catch (_) {
      // Channel unavailable (tests, non-Android) — widget routing is
      // best-effort.
    }
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
        // Blank the Recents/app-switcher snapshot for the whole app.
        if (!_backgroundSecured) {
          _backgroundSecured = true;
          SecureWindow.enable();
        }
        break;

      case AppLifecycleState.resumed:
        // Release the background blank (returns to each screen's own secure
        // state via SecureWindow's reference count).
        if (_backgroundSecured) {
          _backgroundSecured = false;
          SecureWindow.disable();
        }
        // Drain any widget-tap route once the re-lock logic below has
        // settled (post-frame, so it sees the final lock state).
        WidgetsBinding.instance
            .addPostFrameCallback((_) => _consumeWidgetRoute());

        // Travel / timezone refresh — the user may have crossed time zones
        // (or the OS may have updated its zone) while we were backgrounded.
        // tz.local was only set once at app start, so without this call the
        // 08:00 / 20:00 reminders would keep firing at the *previous*
        // location's wall-clock time. The call is a cheap no-op when the
        // zone hasn't changed.
        // Fire-and-forget — we don't want to block the resume path on it.
        NotificationService.refreshTimezoneAndReschedule();

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
        // Set the route-level gate BEFORE navigating so any in-flight
        // navigation (deep link, back gesture) is also caught by the
        // redirect, not only this go() call. Crisis-allowed surfaces
        // (/crisis, /emergency, /urge-timer) keep the gate up but are not
        // yanked away — pulling someone off a crisis line or mid urge-ride
        // to ask for a PIN is the wrong call.
        LockGate.locked = true;
        if (!LockGate.isAllowedWhileLocked(currentLocation)) {
          _router.go('/lock');
        }
        break;

      case AppLifecycleState.inactive:
      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void didChangePlatformBrightness() {
    // Re-evaluate ThemeMode.system when the OS toggles light/dark.
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Keep H in sync whenever the profile changes — but the router
    // is never touched here, so profile updates can't reset navigation.
    final profile = ref.watch(profileProvider).valueOrNull;
    H.sync(profile?.hapticsEnabled ?? true);

    // Resolve the effective brightness and switch the Stillwater token
    // palette BEFORE any descendant builds — every AppColors/AppTextStyles
    // getter below this point resolves against the chosen palette.
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            WidgetsBinding.instance.platformDispatcher.platformBrightness ==
                Brightness.dark);
    AppColors.setDark(isDark);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      systemNavigationBarColor: AppColors.card,
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    // Keep intl's formatting locale in lock-step with the displayed language so
    // a runtime switch re-localizes every DateFormat / money amount too.
    final chosenLocale = ref.watch(localeProvider);
    applyIntlLocale(effectiveLocaleTag(
        chosenLocale, WidgetsBinding.instance.platformDispatcher.locale));

    return MaterialApp.router(
      title: 'Journey Forward',
      theme: buildAppTheme(
        highContrast: profile?.highContrast ?? false,
        dark: isDark,
      ),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      // Language is driven by lib/l10n/app_locales.dart (kSupportedLanguages),
      // so the picker and the framework can never drift apart. `locale` null =
      // follow the device; the Settings → Language picker overrides it. To add
      // a language: drop a translated app_<code>.arb in lib/l10n, run
      // `flutter gen-l10n`, and add one entry to kSupportedLanguages.
      locale: chosenLocale,
      supportedLocales: kSupportedLocales,
      routerConfig: _router,
    );
  }
}

// ─── Global lock gate ────────────────────────────────────────────────────────
//
// A single bit of "are we currently locked?" state shared between the
// lifecycle handler (which sets it true on resume after the grace window),
// the lock screen (which clears it on successful auth), and the GoRouter
// redirect (which uses it to enforce route-level protection).
//
// Without this, nothing stops a deep link / external intent from landing
// the user inside the app while the lock screen was supposed to be active.
// /emergency is intentionally allowlisted — in the worst moment of a user's
// week we don't want auth friction between them and a crisis line.
class LockGate {
  LockGate._();
  static bool locked = false;

  // /emergency hosts the warmline list; /crisis hosts the immediate-danger
  // phone numbers (988, SAMHSA, local lines). Both must be reachable while
  // the app is locked — withholding either behind biometric auth is the
  // wrong call ethically. /urge-timer joins them: it's the SOS widget's
  // target and exposes nothing private beyond a lifetime win count.
  static const _crisisAllowedWhenLocked = {
    '/lock',
    '/emergency',
    '/crisis',
    '/urge-timer',
    '/tipp',
  };
  static bool isAllowedWhileLocked(String location) =>
      _crisisAllowedWhenLocked.contains(location);
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

      // Global lock guard — when the lifecycle observer has flagged the app
      // as locked, allow only the lock screen + the crisis screen. /emergency
      // is intentionally available even while locked because withholding
      // crisis numbers behind biometric auth is the wrong call ethically.
      if (LockGate.locked && !LockGate.isAllowedWhileLocked(loc)) {
        return '/lock';
      }

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
        path: '/urge-timer',
        builder: (_, __) => const UrgeTimerScreen(),
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
      GoRoute(
        path: '/learned',
        builder: (_, __) => const LearnedScreen(),
      ),
      GoRoute(
        path: '/tipp',
        builder: (_, __) => const TippScreen(),
      ),
      GoRoute(
        path: '/challenge',
        builder: (_, __) => const HundredDayChallengeScreen(),
      ),
      GoRoute(
        path: '/weekly-care-summary',
        builder: (_, __) => const WeeklyCareSummaryScreen(),
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
                          decoration: BoxDecoration(
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
