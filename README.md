# Journey Forward

A compassionate, privacy-first sobriety companion built with Flutter.  
Designed for Android using the **Stillwater Aesthetic System** — calm, warm, and human.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State management | Riverpod (`AsyncNotifierProvider`, `Provider`) |
| Navigation | go_router (`StatefulShellRoute.indexedStack`) |
| Persistence | `shared_preferences` (JSON-encoded strings) |
| Design system | Stillwater — Fraunces serif + Inter sans, forest/honey/blush palette |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build release APK
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Analyze (should show 0 errors, 2 benign warnings)
flutter analyze
```

---

## Architecture

### Navigation
`lib/main.dart` owns all routing via go_router.  
A `StatefulShellRoute.indexedStack` drives the 5-tab bottom nav (Home, Progress, Toolkit, Journal, Profile).  
Deep-link screens (History, Recovery Timeline, etc.) are top-level `GoRoute`s — reached with `context.push('/route')`, dismissed with `Navigator.of(context).pop()`.

### State
`lib/providers/app_providers.dart` is the single source of truth.  
Each data type is an `AsyncNotifierProvider` that reads from and writes to `SharedPreferences`.  
All lists are sorted newest-first on load. Components receive data via `ref.watch(...)`.

### Storage keys

| Key | Type | Contents |
|---|---|---|
| `profile` | JSON object | `UserProfile` — sober date, spend, lock method, etc. |
| `journal_entries` | JSON array | Mood journal entries |
| `gratitude` | JSON array | Daily gratitude entries |
| `slip_log` | JSON array | Slip records with previous streak snapshot |
| `cravings` | JSON array | Craving logs with intensity 1–10 |
| `thoughts` | JSON array | Thought logs (positive / neutral / negative) |
| `activities` | JSON array | Exercise / movement logs |
| `sleep_logs` | JSON array | Sleep hours + quality 1–5 |
| `custom_affirmations` | JSON array | User-written affirmations |
| `vision_board` | JSON array | Vision board items |

---

## Screens

### Bottom Nav (5 tabs)

| Route | Screen | Description |
|---|---|---|
| `/home` | `HomeScreen` | Sober clock, streak, check-in sheets, daily mission, pledge |
| `/progress` | `ProgressScreen` | Milestone cards, savings tracker, mood chart, plant growth |
| `/emergency` | `EmergencyScreen` | Breathing exercises, meditation guides, CBT tools, grounding |
| `/journal` | `JournalScreen` | Daily mood journal with affirmations and vision board |
| `/settings` | `SettingsScreen` | Profile, notifications, lock, stats, and all deep-link cards |

### Deep-link Screens

| Route | Screen | Description |
|---|---|---|
| `/history` | `HistoryScreen` | Full filterable log — journals, cravings, thoughts, exercise, sleep, slips |
| `/recovery` | `RecoveryScreen` | Body healing timeline from 20 min to 10 years |
| `/slip-log` | `SlipLogScreen` | Compassionate read-only slip history |
| `/puzzle` | `PuzzleScreen` | Mindful mini-activities — gratitude jar, colour calm, breathing, puzzles |
| `/milestone` | `MilestoneScreen` | Shareable milestone cards via Canvas API |
| `/crisis` | `CrisisScreen` | Crisis helplines with one-tap call/text |
| `/groups` | `GroupsScreen` | Recovery meeting finders (AA, NA, SMART, etc.) |
| `/backup` | `BackupScreen` | Export / import all data as JSON |
| `/privacy` | `PrivacyScreen` | Privacy policy — fully local, no data ever leaves the device |

### Utility Screens

| Route | Screen | Description |
|---|---|---|
| `/onboarding` | `OnboardingScreen` | First-run setup — name, sober date, spend, reasons, PIN |
| `/lock` | `LockScreen` | PIN or biometric lock gate |

---

## Design System — Stillwater Aesthetic

All design tokens live in `lib/theme/app_theme.dart` and `lib/components/`.

### Colours

| Palette | Usage |
|---|---|
| `AppColors.forest*` | Primary — achievements, CTAs, positive states |
| `AppColors.honey*` | Accent — current milestone, warm highlights |
| `AppColors.blush*` | Slip / warning indicators |
| `AppColors.stone*` | Text and neutral UI |
| `AppColors.cream` / `mintChip` | Backgrounds and compassionate callouts |

### Typography

| Style | Font | Usage |
|---|---|---|
| `displaySmall` / `titleLarge` | Fraunces (serif) | Hero numbers, screen titles |
| `bodyMedium` / `bodySmall` | Inter (sans) | Body text, labels |
| `bodySerif` | Fraunces italic | Compassionate quotes and callouts |
| `overline` / `labelSmall` | Inter, spaced caps | Section labels, chips |

### Components (`lib/components/`)

| Component | File | Description |
|---|---|---|
| `GlassCard` | `glass_card.dart` | Frosted white card (default) |
| `SolidCard` | `glass_card.dart` | Opaque card with border |
| `ForestCard` / `HoneyCard` / `BlushCard` | `glass_card.dart` | Themed coloured cards |
| `LuxuryCard` | `luxury_widgets.dart` | Configurable `backgroundColor`, used for hero panels |
| `IconChip` | `luxury_widgets.dart` | Circular icon container |
| `SectionHeader` | `luxury_widgets.dart` | Section label + optional action |
| `BotanicalBackground` | `luxury_widgets.dart` | Decorative botanical element |

---

## Slip / Streak Design

Recording a slip **does not delete any data**.  
`SlipNotifier.record()`:
1. Snapshots the current streak into a `Slip` record
2. Resets `soberDate` to now
3. Clears `firedMilestoneDays` / `firedSavingsTiers` so milestone notifications re-fire on the new streak

Previous streaks are preserved in the slip log and feed into best-streak and lifetime-days calculations in `SettingsScreen`.

---

## Still Placeholder (coming soon)

- `/insights` — Mood and craving pattern insights
- `/heatmap` — Activity heatmap calendar
- `/slip` — Slip support / urge surfing flow

---

## Privacy

All data is stored locally on-device using `SharedPreferences`.  
No analytics, no cloud sync, no tracking of any kind.  
Export (`/backup`) produces a plain JSON file the user controls entirely.
