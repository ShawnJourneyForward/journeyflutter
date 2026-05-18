# Journey Forward

A compassionate, privacy-first sobriety companion built with Flutter.  
Designed for Android using the **Stillwater Aesthetic System** — calm, warm, and human.

**Current version:** 5.8.0+1 · APK: `build/app/outputs/flutter-apk/app-release.apk`

> **Last session (2026-05-18):** Recovery banner rebuilt (4 labels → 14 milestones with progress bar + next-milestone teaser). Early warning card added (dismissible, shown for first 72 h). Unit test suite extended. Website CSS half-screen gaps fixed.

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart ≥ 3.3) |
| State management | Riverpod 2 (`AsyncNotifierProvider`, `Provider`) |
| Navigation | go_router 14 (`StatefulShellRoute.indexedStack`) |
| Persistence | `shared_preferences` (JSON-encoded strings) |
| Secure storage | `flutter_secure_storage` (PIN hash) |
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

# Analyze (should show 0 errors, benign deprecation info only)
flutter analyze
```

> Release signing: `android/app/src/main/jks/release-key.jks`  
> Keystore password and alias are set in `android/app/build.gradle.kts`.

---

## Architecture

### Navigation
`lib/main.dart` owns all routing via go_router.  
A `StatefulShellRoute.indexedStack` drives the 5-tab bottom nav (Home, Progress, Toolkit, Journal, Settings).  
Deep-link screens (History, Recovery Timeline, etc.) are top-level `GoRoute`s — reached with `context.push('/route')`, dismissed with `Navigator.of(context).pop()`.

### State
`lib/providers/app_providers.dart` is the single source of truth.  
Each data type is an `AsyncNotifierProvider` that reads from and writes to `SharedPreferences`.  
All lists are sorted newest-first on load. Components receive data via `ref.watch(...)`.

### Storage keys

| Key | Type | Contents |
|---|---|---|
| `profile` | JSON object | `UserProfile` — sober date, spend, currency, lock method, notification flags |
| `journal_entries` | JSON array | Mood journal entries (mood 1–5 + text) |
| `gratitude` | JSON array | Daily gratitude entries |
| `slip_log` | JSON array | Slip records with previous streak snapshot |
| `cravings` | JSON array | Craving logs with intensity 1–10 |
| `thoughts` | JSON array | Thought logs (positive / neutral / negative) |
| `activities` | JSON array | Exercise / movement logs |
| `sleep_logs` | JSON array | Sleep hours + quality 1–5 |
| `custom_affirmations` | JSON array | User-written affirmations |
| `vision_board` | JSON array | Vision board image items |
| `early_warning_seen` | bool | Whether the first-72-h early warning card has been dismissed |

---

## Screens

### Bottom Nav (5 tabs)

| Route | Screen | Description |
|---|---|---|
| `/home` | `HomeScreen` | Sober clock, streak, check-in cards (pledge, gratitude), daily mission, money saved. Shows early warning card (first 72 h) and 14-milestone recovery banner with progress bar. |
| `/progress` | `ProgressScreen` | Milestone cards, savings tracker, mood chart, plant growth visual |
| `/emergency` | `EmergencyScreen` | Breathing exercises, meditation guides, CBT tools, grounding |
| `/journal` | `JournalScreen` | Daily mood journal with affirmations and vision board |
| `/settings` | `SettingsScreen` | Profile, notifications, lock, stats, and all deep-link entry cards |

### Deep-link Screens

| Route | Screen | Description |
|---|---|---|
| `/history` | `HistoryScreen` | Full filterable log — journals, cravings, thoughts, exercise, sleep, slips |
| `/recovery` | `RecoveryScreen` | 14-milestone body healing timeline (20 min → 10 years) with Body / Mind / Tip sections |
| `/slip-log` | `SlipLogScreen` | Compassionate read-only slip history |
| `/puzzle` | `PuzzleScreen` | Mindful mini-activities — gratitude jar, colour calm, breathing, puzzles |
| `/milestone` | `MilestoneScreen` | Shareable milestone cards via Canvas API |
| `/crisis` | `CrisisScreen` | Crisis helplines with one-tap call/text |
| `/groups` | `GroupsScreen` | Recovery meeting finders (AA, NA, SMART, etc.) |
| `/backup` | `BackupScreen` | Export / import all data as JSON |
| `/privacy` | `PrivacyScreen` | Privacy policy — fully local, no data leaves device |
| `/cbt` | `CbtScreen` | CBT thought-challenging tools |
| `/insights` | `InsightsScreen` | Mood and craving charts (fl_chart) |
| `/heatmap` | `HeatmapScreen` | Activity heatmap calendar |
| `/slip-support` | `SlipSupportScreen` | Urge surfing and slip support flow |

### Utility Screens

| Route | Screen | Description |
|---|---|---|
| `/onboarding` | `OnboardingScreen` | First-run setup — name, sober date, spend, reasons, PIN |
| `/lock` | `LockScreen` | PIN or biometric lock gate |

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navigation / deep links |
| `shared_preferences` | Primary data store |
| `flutter_secure_storage` | PIN hash (SHA-256) |
| `flutter_local_notifications` | Milestone + daily reminder notifications |
| `local_auth` | Biometric lock |
| `flutter_tts` | Read affirmations aloud, guided meditation |
| `speech_to_text` | Voice journal entry |
| `just_audio` | Ambient audio (rain, forest, ocean, fire) |
| `fl_chart` | Insights charts |
| `share_plus` | Milestone card share + backup export |
| `image_picker` | Vision board camera/gallery |
| `file_picker` | Backup restore (.json) |
| `url_launcher` | Crisis line call buttons |
| `crypto` | SHA-256 PIN hashing |
| `google_fonts` | Fraunces + Inter (cached after first run) |

---

## Design System — Stillwater Aesthetic

All design tokens live in `lib/theme/app_theme.dart`.  
Custom components live in `lib/components/`.

### Colours

| Palette | Usage |
|---|---|
| `AppColors.forest*` (50–800) | Primary — achievements, CTAs, positive states |
| `AppColors.honey*` (50–600) | Accent — current milestone, warm highlights |
| `AppColors.blush*` | Slip / warning indicators |
| `AppColors.stone*` (50–800) | Text and neutral UI |
| `AppColors.cream` / `mintChip` | Backgrounds and compassionate callouts |

### Typography

| Style | Font | Usage |
|---|---|---|
| `displaySmall` / `titleLarge` | Fraunces (serif) | Hero numbers, screen titles |
| `bodyMedium` / `bodySmall` | Inter (sans) | Body text, labels |
| `bodySerif` | Fraunces italic | Compassionate quotes and callouts |
| `overline` / `labelSmall` | Inter, spaced caps | Section labels, chips |
| `moneyNumber` | Fraunces | Large currency display |

### Radius tokens (`AppRadius`)

| Token | Value | Usage |
|---|---|---|
| `sm` | 8px | Tight chips |
| `md` | 12px | Info boxes, tip panels |
| `lg` | 16px | Standard cards |
| `xl` | 20px | Input containers |
| `luxury` | 30px | `LuxuryCard` |
| `pill` | 100px | Label chips, progress bars |

### Components (`lib/components/`)

| Component | File | Description |
|---|---|---|
| `GlassCard` / `SolidCard` | `glass_card.dart` | Frosted / opaque cards |
| `ForestCard` / `HoneyCard` / `BlushCard` | `glass_card.dart` | Themed accent cards |
| `LuxuryCard` | `luxury_widgets.dart` | Configurable card — supports `padding: EdgeInsets.zero` + `Stack` for botanical overlays |
| `IconChip` | `luxury_widgets.dart` | Circular icon container |
| `SectionHeader` | `luxury_widgets.dart` | Section label + optional trailing action |
| `BotanicalBackground` | `luxury_widgets.dart` | Decorative botanical branch (CustomPainter) |
| `SoftDivider` | `luxury_widgets.dart` | Thin stone-coloured divider |
| `SoftInput` | `luxury_widgets.dart` | Tinted multi-line text field |
| `StatNumber` | `luxury_widgets.dart` | Large display number with optional suffix |

---

## Notifications

Managed by `flutter_local_notifications`. Three categories:

| Category | IDs | Trigger |
|---|---|---|
| Motivations / reminders | 1–4 | Scheduled daily at user-set morning/evening times |
| Day milestones | 500 + days | Fired once when streak crosses 1, 7, 14, 30, 60, 90, 180, 365, 730, 1095 days |
| Savings milestones | 600 + tier index | Fired once when money saved crosses R50, R100, R250, R500 … R10 000 |

**Cadence (auto-decay):** `effectiveFrequency()` in `lib/utils/notification_service.dart` returns:
- `gentle` (2/day) for the first 30 days
- `light` (morning only) for days 31–90  
- `minimal` (one-shot 3 days out, re-armed on every launch) for 91+

Milestone and savings tiers that have already fired are stored in `profile.firedMilestoneDays` and `profile.firedSavingsTiers` — they will not re-fire unless a slip resets the streak (which clears those arrays).

---

## Slip / Streak Design

Recording a slip **does not delete any data**.  
`SlipNotifier.record()`:
1. Snapshots current streak into a `Slip` record
2. Resets `soberDate` to now
3. Clears `firedMilestoneDays` / `firedSavingsTiers` so milestone notifications re-fire on the new streak

Previous streaks are preserved in the slip log and feed into best-streak and lifetime-days calculations in `SettingsScreen`.

---

## Localisation

Supported languages: English (en), Afrikaans (af), Zulu (zu), Xhosa (xh), Sotho (st).  
ARB files live in `lib/l10n/`. Add keys to all five `.arb` files before using a new `AppLocalizations.*` reference.  
New hardcoded English content (e.g. detailed recovery milestone text) is kept in Dart — do not add it to l10n unless multilingual support is planned.

---

## Privacy

All data is stored locally on-device using `SharedPreferences`.  
No analytics, no cloud sync, no tracking of any kind.  
Export (`/backup`) produces a plain JSON file the user controls entirely.
