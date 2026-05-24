# Play Store Screenshots — Capture Guide

The Play Store screenshots are the **single biggest conversion driver** on the
listing — most users decide whether to install based on these alone. They must
be real captures from a running device. PowerShell/GDI+ can't render
Flutter's compositor, so this is a manual step.

---

## Required specs

| Field | Value |
|---|---|
| **Format** | PNG or JPEG, 24-bit RGB (no alpha) |
| **Aspect ratio** | Between 16:9 and 9:16 |
| **Short side** | 320–3840 px |
| **Long side** | up to 3840 px |
| **Recommended phone size** | 1080×1920 (or 1080×2400 for modern devices) |
| **Quantity** | **2 minimum, 8 maximum** — aim for 6 |
| **Filename** | `screenshot_01.png`, `screenshot_02.png`, … |

Place finished screenshots into this folder (`play_store_assets/`).

---

## The 6 screens you should ship

These map to the most emotionally-resonant parts of the app, ordered so a
prospective user can scroll through them and "get it" in 10 seconds.

| # | Screen | What it shows | How to set it up |
|---|---|---|---|
| 1 | **Home / Serenity card** | The hero card with the live counter, plant, milestone band. The single most-recognisable view of the app. | Onboard with a sober date about 35 days ago so the counter reads "35 days, 12 hours, …" and the plant glyph is mid-stage. |
| 2 | **Money Reclaimed card** | Real-time money saved + investing-in-yourself copy. | Set daily spend to R120 during onboarding (R4 200 saved at 35 days reads well). |
| 3 | **Journal — Entry detail** | One mood + text entry visible. Shows the diary depth. | Add 3 entries spanning the last week so the date-grouped list shows "Today / Yesterday / This week". Open one. |
| 4 | **Progress — Cravings Heatmap** | The new decorative band + the 28-day heatmap with a few logged cravings. | Log 4–5 cravings in the last week with varying intensities from the home Check-In card. |
| 5 | **Emergency / Calm Toolkit — Meditation tab** | Urge Surfing audio card + the pulse ring. | Open Emergency tab, switch to Meditation tab, tap play once so the player shows progress. |
| 6 | **Settings — Notifications** | The Notifications card expanded, showing the new "System notifications enabled" indicator. | Open Settings, expand Notifications card. |

---

## Capture workflow

### Option A — From a connected Android phone (recommended; real device)

```powershell
# 1. Enable Developer options + USB debugging on the phone
# 2. Plug in, accept the trust prompt
# 3. Verify the device shows up
adb devices

# 4. Install the release APK from this build
adb install -r "C:\Users\shawn\Documents\Personal Docs\Personal\Journey Forward Flutter\build\app\outputs\flutter-apk\app-release.apk"

# 5. For each screen above:
#    - Navigate to it on the phone
#    - Capture from the host (no device chrome, no notification pill clutter):
adb shell screencap -p /sdcard/screenshot_01.png
adb pull /sdcard/screenshot_01.png "C:\Users\shawn\Documents\Personal Docs\Personal\Journey Forward Flutter\play_store_assets\screenshot_01.png"
adb shell rm /sdcard/screenshot_01.png
```

Repeat for each `screenshot_NN.png`.

### Option B — From the Android emulator

```powershell
# 1. Launch a Pixel 7 / Pixel 8 AVD via Android Studio (1080x2400)
# 2. Install the APK
flutter install --release
# 3. Use the emulator's camera-icon side toolbar to capture each screen
#    or run the same adb shell screencap loop above against the emulator.
```

### Option C — Flutter's own screenshot command

```powershell
cd "C:\Users\shawn\Documents\Personal Docs\Personal\Journey Forward Flutter"
flutter run --release
# Then in the running session, press "s" to take a screenshot — saved to
# the project root as flutter_NN.png. Move + rename them into play_store_assets/.
```

---

## Before you upload

1. **Strip the status-bar clutter.** Turn on Do Not Disturb so no system
   notifications appear. Set the time to a clean number (e.g. 9:41). Charge
   the phone (no low-battery icon). Use airplane mode for a clean signal area.
2. **Verify resolution.** Phone screenshots should be ≥ 1080 px on the short
   side. Anything below 320 will be rejected.
3. **No personal info.** Use a pseudonym during onboarding, not your real
   name. Avoid showing any phone number / contact you wouldn't want public.
4. **Keep the same aspect ratio** across all 6 — Play Store presents them in
   a horizontal strip and mixed ratios look amateurish.

---

## Optional polish: add framed device chrome

If you want the screenshots to appear inside a phone frame (raises the
production-value floor significantly), use a free tool like:

- **PreviewMagic** (web) — drag-and-drop, several device templates
- **Screenshots.pro** (web) — Play-Store-optimised templates
- **fastlane snapshot** (CLI) — if you want to script it for future updates

These are entirely optional. Plain raw screenshots are fully acceptable to
Google Play.

---

## Bonus: 7" tablet screenshots

Optional but recommended. Same workflow, run on a tablet emulator at
1200×1920. Place into `play_store_assets/tablet/` if you produce them.
