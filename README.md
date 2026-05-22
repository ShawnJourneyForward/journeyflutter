# Journey Forward

A compassionate, privacy-first sobriety companion built with Flutter.
Designed for Android using the **Stillwater Aesthetic System** — calm, warm, and human.

**Current version:** 5.9.0+1
**Latest release APK:** `build/app/outputs/flutter-apk/app-release.apk` (~67 MB, built locally — produce a signed AAB for Play Store submission)

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x (Dart ≥ 3.3) |
| State management | Riverpod 2 (`AsyncNotifierProvider`, `Provider`) |
| Navigation | go_router 14 (`StatefulShellRoute.indexedStack`) |
| Persistence | `shared_preferences` (JSON-encoded strings) for most data |
| Secure storage | `flutter_secure_storage` (PIN hash, encrypted profile) backed by the Android Keystore via EncryptedSharedPreferences |
| Fonts | Bundled — Fraunces (serif) + Inter (sans). No network round-trip; no `google_fonts` |
| Design system | Stillwater — forest / honey / blush palette |

---

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Build release APK (debug-signed unless android/key.properties is configured)
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk

# Build signed AAB for Play Store (requires android/key.properties)
flutter build appbundle --release

# Verify
flutter analyze   # should report 0 errors
flutter test      # 143/143 passing as of v5.8
```

### Release signing

`android/key.properties` is **not** committed. Create it locally with your
keystore path / passwords / alias to produce a real signed release. Without
it, `flutter build apk --release` falls back to debug-signed output (fine for
sideload testing, not acceptable for Play Store submission).

---

## Architecture

### Navigation
`lib/main.dart` owns all routing via go_router.
A `StatefulShellRoute.indexedStack` drives the 5-tab bottom nav (Home, Progress, Toolkit, Journal, Settings).
Deep-link screens (History, Recovery Timeline, etc.) are top-level `GoRoute`s — reached with `context.push('/route')`, dismissed with `Navigator.of(context).pop()`.

### State
`lib/providers/app_providers.dart` is the single source of truth.
Each data type is an `AsyncNotifierProvider` that reads from and writes to `SharedPreferences` (or `EncryptedStore` for the profile).
All lists are sorted newest-first on load. Components receive data via `ref.watch(...)`.

### Storage keys

| Key | Storage | Contents |
|---|---|---|
| `profile` | **Encrypted** (`EncryptedStore`) | `UserProfile` — sober date, spend, currency, lock method, notification flags, high-contrast pref, pre-craving plan + linked Toolkit routes |
| `has_profile` | Plain prefs | Sentinel "1" so the synchronous router redirect can answer "is there a profile?" without awaiting encrypted storage |
| `profile_sober_date` | Plain prefs | Mirror of `profile.soberDate` so the home-screen widget can render the streak without touching encrypted storage |
| `journal_entries` | Plain prefs | Mood journal (mood 1–5 + text) |
| `gratitude` | Plain prefs | Daily gratitude entries |
| `slip_log` | Plain prefs | Slip records with previous streak snapshot |
| `cravings` | Plain prefs | Craving logs with intensity 1–10 |
| `thoughts` | Plain prefs | Thought logs (positive / neutral / negative) |
| `activities` | Plain prefs | Exercise / movement logs |
| `sleep_logs` | Plain prefs | Sleep hours + quality 1–5 |
| `custom_affirmations` | Plain prefs | User-written affirmations |
| `vision_board` | Plain prefs | Vision board items — icon key (20 vector icons), title, description, optional local photo path |
| `future_letters` | Plain prefs | Sealed letters to future self (v5.8) |
| `hard_days` | Plain prefs | "I made it through a hard day" battle log (v5.8) |
| `thought_records` | Plain prefs | Full CBT thought records — 10-distortion catalogue (v5.8) |
| `meetings` | Plain prefs | Meeting planner entries with reminder slot IDs |
| PIN hash | `flutter_secure_storage` | Salted PBKDF2-style hash. Never plaintext. Never travels in backups. |

---

## Screens

### Bottom Nav (5 tabs)

| Route | Screen | Description |
|---|---|---|
| `/home` | `HomeScreen` | Sober clock, streak, check-in cards, daily mission, money saved. `TodaysStrengthCard` rotates between unopened-letter / detected-craving-pattern / hard-day mark. Journey card: 6-node milestone timeline. |
| `/progress` | `ProgressScreen` | Milestone cards, savings tracker, mood chart, plant growth visual |
| `/emergency` | `EmergencyScreen` | **Your Toolkit** — Breathing library (box, 4-7-8, etc.), grounding, CBT tools, meditations |
| `/journal` | `JournalScreen` | Mood journal + affirmations (personalised + voice-input) + vision board (photo, 20 vector icons, edit) |
| `/settings` | `SettingsScreen` | Profile, recovery stats, lock method, notifications, high-contrast toggle, tools & app links |

### Deep-link Screens

| Route | Screen | Description |
|---|---|---|
| `/history` | `HistoryScreen` | Full filterable log |
| `/recovery` | `RecoveryScreen` | 14-milestone body healing timeline (copy intentionally softened — "many people / research suggests") |
| `/slip-log` | `SlipLogScreen` | Compassionate slip history |
| `/puzzle` | `PuzzleScreen` | Mindful mini-activities |
| `/milestone` | `MilestoneScreen` | Shareable milestone cards via Canvas API |
| `/crisis` | `CrisisScreen` | Crisis helplines with one-tap call/text |
| `/groups` | `GroupsScreen` | Recovery group finders (AA, NA, SMART, etc.) |
| `/meetings` | `MeetingsScreen` | Meeting planner with reminders |
| `/backup` | `BackupScreen` | Export / import — optionally passphrase-encrypted (`.jfwbk`) or plain JSON |
| `/privacy` | `PrivacyScreen` | Privacy policy |
| `/cbt` | `CbtScreen` | Quick CBT thought-challenging tools |
| `/future-letter` | `FutureLetterScreen` | Write a sealed letter to your future sober self; unlocks on a chosen date |
| `/pre-craving-plan` | `PreCravingPlanScreen` | Edit 3-step craving playbook with optional Toolkit exercise links (one-tap open during a craving) |
| `/insights` | `InsightsScreen` | Mood and craving charts (fl_chart) |
| `/heatmap` | `HeatmapScreen` | 13-week activity heatmap |
| `/slip-support` | `SlipSupportScreen` | Urge surfing and slip support flow |

### Utility Screens

| Route | Screen | Description |
|---|---|---|
| `/onboarding` | `OnboardingScreen` | First-run setup |
| `/lock` | `LockScreen` | PIN or biometric lock gate |

---

## Key Dependencies

| Package | Purpose |
|---|---|
| `flutter_riverpod` | State management |
| `go_router` | Navigation / deep links |
| `shared_preferences` | Primary data store |
| `flutter_secure_storage` | PIN hash + encrypted profile |
| `flutter_local_notifications` | Reminders + milestone alerts |
| `local_auth` | Biometric lock |
| `flutter_tts` | Read affirmations aloud, guided meditation |
| `speech_to_text` | Voice journal entry |
| `just_audio` | Procedural ambient audio |
| `fl_chart` | Insights charts |
| `share_plus` | Milestone card share + backup export |
| `image_picker` | Vision board camera/gallery |
| `file_picker` | Backup restore (`.json` and `.jfwbk`) |
| `url_launcher` | Crisis line call buttons |
| `crypto` | PIN hashing + backup encryption primitives |

> Fonts are **bundled** (Fraunces + Inter) — `google_fonts` is **not** a dependency.

---

## Notifications

Managed by `flutter_local_notifications`. Notification ID ranges (disjoint by design — see header comment in `lib/utils/notification_service.dart`):

| Category | ID range | Trigger |
|---|---|---|
| Morning / evening reminders | 1, 2 | Daily at user-set times |
| Day milestones | 10000 + days | Once per crossing of 1, 7, 14, 30, 60, 90, 180, 365, 730, 1095 days |
| Savings milestones | 20000 + tier index | Once per crossing of R50, R100, R250 … R10 000 |
| Meeting reminders | 30000 + folded id | Slot-stable; safe to re-schedule |

### Exact alarms

The app **does not** declare `SCHEDULE_EXACT_ALARM`. `NotificationService` calls `canScheduleExactNotifications()` and gracefully falls back to `inexactAllowWhileIdle` — fine for daily recovery reminders and removes Play Store policy friction.

---

## Slip / Streak Design

Recording a slip **does not delete any data**. `SlipNotifier.record()`:

1. Snapshots current streak into a `Slip` record
2. Resets `soberDate` to now (and mirrors it into `profile_sober_date` for the widget)
3. Clears `firedMilestoneDays` / `firedSavingsTiers` so milestone notifications re-fire on the new streak

Previous streaks are preserved in the slip log and feed best-streak / lifetime-days calculations.

---

## Localisation

Only **English (`en`)** is currently exposed at runtime. The repo also contains `af`, `es`, `pt`, `zu` ARB files, but they're keyword-for-keyword English clones — shipping them as choices would mislead users. Restore them to `MaterialApp.supportedLocales` in `lib/main.dart` once each has a real translation pass.

ARB files live in `lib/l10n/`. Add new keys to `app_en.arb` and run `flutter pub get` to regenerate `AppLocalizations`.

---

## Backup & Encryption

`/backup` exports the user's data to a file they control:

- **Encrypted (`.jfwbk`, recommended)** — passphrase-protected. The implementation is in `lib/utils/backup_crypto.dart`: PBKDF2-HMAC-SHA256 (150 000 iterations) derives two 32-byte keys; one drives an HMAC-SHA256-CTR stream cipher (XOR with the keystream), the other authenticates `salt‖nonce‖ct` with HMAC-SHA256. Wrong passphrase or any tampering → fails fast with `BackupCryptoException`; never returns garbled plaintext.
- **Plain JSON** — same data, no encryption. Convenient for inspection; the user is responsible for storing it safely.

The PIN hash is **never** included in a backup (it lives in `flutter_secure_storage` and can't be migrated). `lockMethod` is forced to `none` on restore so a restored profile can never lock the user out without a hash.

Both formats include `future_letters`, `hard_days`, `thought_records`, and `meetings` as of v5.8.  The `thought_records` key is preserved for backward compatibility (data is not deleted); the Thought Record screen is no longer linked from the Settings UI as of v5.9.

---

## Privacy

- 100% on-device by default — no analytics, no cloud sync, no telemetry, no Firebase, no crash reporting, no ads, no accounts.
- The release `AndroidManifest.xml` does **not** declare `INTERNET`. There is no network surface at runtime.
- Auto Backup is disabled (`allowBackup="false"`) with explicit exclusion rules.
- Fonts are bundled — no font CDN round-trip.
- The PIN is salted and hashed with a slow KDF before storage; the profile lives in Android Keystore-backed encrypted storage.
- The only way data leaves the device is the user explicitly tapping export and sharing the resulting file.

---

## Tests

`flutter test` — 143 tests across unit and widget layers, including:

- Backup encryption round-trip, wrong-passphrase rejection, tamper detection (MAC), unicode + long plaintext (`test/unit/backup_crypto_test.dart`)
- FutureLetter unlock semantics + JSON round-trip
- HardDay same-day idempotency (mark twice → one record)
- Craving pattern detection threshold (no false positives under 5 data points)
- Cognitive distortion catalogue lookup
- PIN hashing (random salt, wrong-PIN rejection, malformed input)
- Smoke tests for onboarding, home, settings, recovery, privacy

---

## Design System — Stillwater Aesthetic

All design tokens live in `lib/theme/app_theme.dart`. Custom components live in `lib/components/`. `buildAppTheme(highContrast: ...)` produces a high-contrast variant for the accessibility toggle in Settings.

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

### Components (`lib/components/`)

| Component | Description |
|---|---|
| `GlassCard` / `SolidCard` | Frosted / opaque cards |
| `ForestCard` / `HoneyCard` / `BlushCard` | Themed accent cards |
| `LuxuryCard` | Configurable card — supports custom padding + Stack overlays |
| `IconChip`, `SectionHeader`, `BotanicalBackground`, `SoftDivider`, `SoftInput`, `StatNumber` | See `luxury_widgets.dart` |
| `TodaysStrengthCard` | Home rotation slot — unopened letter / detected craving pattern / hard-day mark |
| `LuxuryBackButton` | Left-aligned back affordance used across deep-link screens |

---

## Home-screen Widget (Android)

A 2×2 home-screen widget renders the current sober streak. It reads `flutter.profile_sober_date` from plain `SharedPreferences` (mirrored on every profile save) — it never touches encrypted storage from native code. Tap → opens the app and routes through the same lock screen the launcher icon does.

Sources:
- `android/app/src/main/kotlin/com/journeyforward/journey_forward/JourneyWidgetProvider.kt`
- `android/app/src/main/res/layout/journey_widget.xml`
- `android/app/src/main/res/xml/journey_widget_info.xml`
