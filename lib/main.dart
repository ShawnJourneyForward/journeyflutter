import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;

import 'l10n/app_localizations.dart';
import 'providers/app_providers.dart';
import 'theme/app_theme.dart';
import 'utils/haptic_service.dart';
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
import 'screens/milestone_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/privacy_screen.dart';
import 'screens/progress_screen.dart';
import 'screens/puzzle_screen.dart';
import 'screens/recovery_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/cbt_screen.dart';
import 'screens/heatmap_screen.dart';
import 'screens/slip_log_screen.dart';
import 'screens/slip_support_screen.dart';

// ─── Entry point ─────────────────────────────────────────────────────────────

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Timezone data required by flutter_local_notifications
  tz.initializeTimeZones();

  // Lock to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Transparent status bar, dark icons on cream background
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: AppColors.card,
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  final prefs = await SharedPreferences.getInstance();
  final hasProfile = prefs.getString('profile') != null;
  final lockMethod = prefs.getString('lockMethod') ?? 'none';

  runApp(
    ProviderScope(
      child: JourneyForwardApp(
        hasProfile: hasProfile,
        lockMethod: lockMethod,
      ),
    ),
  );
}

// ─── Root app ─────────────────────────────────────────────────────────────────

class JourneyForwardApp extends ConsumerWidget {
  const JourneyForwardApp({
    super.key,
    required this.hasProfile,
    required this.lockMethod,
  });

  final bool hasProfile;
  final String lockMethod;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keep H in sync whenever the profile changes.
    final profile = ref.watch(profileProvider).valueOrNull;
    H.sync(profile?.hapticsEnabled ?? true);

    return MaterialApp.router(
      title: 'Journey Forward',
      theme: buildAppTheme(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      routerConfig: _buildRouter(hasProfile: hasProfile, lockMethod: lockMethod),
    );
  }
}

// ─── Router ───────────────────────────────────────────────────────────────────

GoRouter _buildRouter({
  required bool hasProfile,
  required String lockMethod,
}) {
  final String initialRoute = !hasProfile
      ? '/onboarding'
      : (lockMethod != 'none' ? '/lock' : '/home');

  return GoRouter(
    initialLocation: initialRoute,
    debugLogDiagnostics: false,
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
        path: '/backup',
        builder: (_, __) => const BackupScreen(),
      ),
      GoRoute(
        path: '/privacy',
        builder: (_, __) => const PrivacyScreen(),
      ),
    ],
  );
}

// ─── App shell (bottom nav bar) ──────────────────────────────────────────────

class _AppShell extends StatelessWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      _NavTab(label: l10n.navHome,     icon: Icons.home_outlined,          activeIcon: Icons.home_rounded),
      _NavTab(label: l10n.navProgress, icon: Icons.monitor_heart_outlined,  activeIcon: Icons.monitor_heart_rounded),
      _NavTab(label: l10n.navToolkit,  icon: Icons.spa_outlined,            activeIcon: Icons.spa_rounded),
      _NavTab(label: l10n.navJournal,  icon: Icons.menu_book_outlined,      activeIcon: Icons.menu_book_rounded),
      _NavTab(label: l10n.navProfile,  icon: Icons.person_outline,          activeIcon: Icons.person_rounded),
    ];
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: _StillwaterNavBar(
        currentIndex: navigationShell.currentIndex,
        onTap: (i) => navigationShell.goBranch(
          i,
          initialLocation: i == navigationShell.currentIndex,
        ),
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
  const _StillwaterNavBar({required this.currentIndex, required this.onTap, required this.tabs});
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
                      color: selected ? AppColors.forest : AppColors.mistGrey),
                    const SizedBox(height: 5),
                    Text(tab.label,
                      style: AppTextStyles.caption.copyWith(
                        color: selected ? AppColors.forest : AppColors.mistGrey,
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
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

