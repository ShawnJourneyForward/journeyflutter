# Privacy Policy — Journey Forward

**Effective date:** 27 May 2026
**App:** Journey Forward (Android)
**Developer:** Shawn Fourie / Stillwater Studios
**Contact:** shawn@journeyforward.app

---

## Your data stays on your device.

**Journey Forward stores everything on your device, and sends nothing to any server of ours.**

This policy explains, in plain language, exactly what data the app handles, where it goes, and how to control it. The short version: it stays on your phone, and only you can see it.

> **This release (6.3.0) is fully offline.** It ships with **no `INTERNET` permission** and makes **no network connection of any kind** — there is nothing to send and no way to send it. The optional **Strava** integration described below (§2, §5, §5a, §6 and the dependency notes) is **disabled and not present in this build**; those sections apply only to a future build that re-enables it. For Google Play **Data safety**, this app collects **no data** and shares **no data**.

There are two opt-in exceptions, and both are entirely under your control:

- **Voice dictation (§5).** If you use the optional voice-dictation feature for journaling, your spoken audio is handed to your phone's own speech-recognition service, which on many Android devices is provided by Google and may process audio in the cloud. That's an OS-level service we don't control; everything the app itself does is local.
- **Strava (§2 and §5a).** If — and only if — you choose to connect Strava in the Planner, the app talks to Strava over the internet to sign you in and download *your own* activities. This happens directly between your phone and Strava; nothing is routed through, copied to, or seen by a server of ours. If you never connect Strava, the app never touches the network.

---

## 1. What data Journey Forward stores

You can enter the following information into Journey Forward:

- Your username, sober date, daily spend amount, currency, and savings goal
- Daily pledges, gratitude entries, and intention check-ins
- Journal entries (mood, text, tags, prompts), including optional voice-to-text dictation
- Craving logs (intensity, triggers, notes)
- Slip / setback records
- Thought records (CBT-style reframes)
- Activity and sleep logs
- Vision board entries (text and photos you choose from your gallery)
- Custom affirmations
- Weekly recovery-capital check-ins
- Future-letter and pre-craving-plan entries
- Recovery-meeting reminders (title, time, location)
- Emergency contact name and phone number (optional)
- Lock method preference (PIN or biometric) — the PIN itself is salted and hashed, never stored as plaintext
- Notification preferences (morning/evening times, motivation/reminder/milestone toggles)

**Where it lives.** All of the above is stored locally on your device using the operating system's standard app storage. Sensitive collections (journal, cravings, thoughts, slips, intentions, etc.) are written through Android's **Keystore-encrypted shared preferences** so they remain encrypted at rest. On most modern Android devices the encryption key is held in a hardware-backed secure element (TEE or StrongBox); on older or lower-end hardware Android may keep the key in a software-backed Keystore. Either way the key is managed by the OS and never leaves the Keystore boundary into Journey Forward's own memory.

**What we collect.** Nothing. None of this information leaves your device. There is no account to sign up for, no profile to create on a server, and no copy of your data held by us, by Google, by Stillwater Studios, or by any third party.

---

## 2. Offline by default — one opt-in network feature

Journey Forward works fully offline out of the box. It makes **no** network connection of its own unless you deliberately connect Strava.

- All fonts (Inter, Fraunces) and visual assets are bundled inside the app.
- There are no analytics SDKs, crash reporters, advertising IDs, telemetry, or cloud sync — nothing that quietly phones home in the background, ever.
- The app **does** request the `INTERNET` permission in its Android manifest. It uses it for exactly one purpose: the optional Strava connection described in **§5a**. Until you tap **Connect Strava**, the app makes no network requests at all.
- When you do connect Strava, the traffic goes **directly between your phone and Strava over HTTPS** (`usesCleartextTraffic` is disabled, so plain-text connections are never allowed). It downloads only *your own* activities, and it does **not** pass through, store on, or expose your data to any server operated by us — there is no Journey Forward server in the path.
- If you tap a link to a crisis line, support group, or external resource, your device opens it in your system browser or dialer — outside of Journey Forward — and your interaction there is subject to that destination's own privacy policy.
- The optional voice-dictation feature in the journal hands audio to your phone's built-in speech-recognition service (commonly Google's Speech Services on Android). That service — not Journey Forward — may transmit audio to the cloud depending on your device and OS settings. See §5 for the full explanation, and deny the microphone permission if you'd rather not use this feature at all.

---

## 3. No analytics or tracking

There are no analytics SDKs, crash reporters, advertising IDs, or usage trackers in this app. Specifically, Journey Forward does **not** include:

- Google Analytics, Firebase Analytics, Crashlytics, or any other analytics service
- Facebook SDK, AppsFlyer, Adjust, or other attribution SDKs
- Any third-party advertising network
- Any custom telemetry written by the developer

We do not collect any data about how you use the app, how often you open it, which features you use, or how long you stay in it.

---

## 4. Permissions Journey Forward requests, and why

Journey Forward requests the minimum permissions necessary to function. Each is used **only** for the purpose listed and **only on your device**.

| Permission | Why |
|---|---|
| `POST_NOTIFICATIONS` (Android 13+) | Daily check-in reminders, milestone alerts, and meeting reminders |
| `RECEIVE_BOOT_COMPLETED` | Re-arms your scheduled reminders after a phone reboot or app update |
| `VIBRATE` | Optional haptic feedback when you tap buttons |
| `USE_BIOMETRIC` / `USE_FINGERPRINT` | Optional fingerprint / face unlock for the in-app lock |
| `RECORD_AUDIO` | Optional voice dictation for journal entries — handled by your phone's built-in speech recognition; audio is never recorded to disk by Journey Forward |
| `READ_MEDIA_IMAGES` (Android 13+) / `READ_EXTERNAL_STORAGE` (Android 12 and lower) | Lets you pick photos from your gallery to add to your Vision Board |
| `INTERNET` | Used **only** when you opt in to connecting Strava — to sign you in and download your own activities directly from Strava over HTTPS (see §5a). Unused until then. |

Journey Forward does **not** request: camera, location, contacts, SMS, phone state, or calendar.

---

## 5. Voice dictation and speech recognition

The voice-input feature uses your **device's built-in speech recognition service**. On Android, this is provided by Google's Speech Services (or whichever speech service you have set as your default).

- Audio is processed by the OS, not by Journey Forward.
- Journey Forward only receives the final transcribed text and stores it on your device.
- Whether the transcription happens on-device or in Google's cloud depends entirely on your Android version and device settings — that behaviour is controlled by Android, not by us.
- You can disable voice input entirely by denying the microphone permission.

---

## 5a. Strava connection (optional)

The Planner includes an **optional** integration with [Strava](https://www.strava.com/). It is off by default and only ever activates when you tap **Connect Strava**. If you never connect it, this section does not apply to you and the app never touches the network.

When you do connect Strava:

- **Direct device-to-Strava only.** Sign-in and data transfer happen directly between your phone and Strava's own servers over HTTPS. **Nothing is routed through, copied to, logged by, or visible to any server operated by Journey Forward or Stillwater Studios** — there is no backend of ours in the path, because we don't run one.
- **What we request from Strava.** Read-only access (`read` and `activity:read` scopes). The app downloads *your own* activities — typically the date, distance, duration, pace, and activity type, and where present the route/GPS fields associated with those activities — so they can appear in your Planner history and insights. Journey Forward cannot post, edit, or delete anything on your Strava account, and cannot see other people's data.
- **Tokens stay on your device.** The OAuth access and refresh tokens Strava issues are stored in your device's **Keystore-encrypted secure storage** — the same protected store used for your journal and PIN — and are used solely to fetch your activities. They are never transmitted to us.
- **Imported activities live on-device.** Once downloaded, your Strava activities are stored locally alongside the rest of your Planner data and are subject to everything else in this policy. They are never re-shared.
- **Disconnecting is clean and complete.** Tapping **Disconnect** in the Planner deletes the stored tokens from your device **and** deauthorizes Journey Forward at Strava, so the app can make no further requests on your behalf. You can also revoke access at any time from your Strava account settings (Settings → My Apps).
- **Strava's own privacy policy applies on their side.** Your relationship with Strava — the account, what they store, their terms — is governed by [Strava's Privacy Policy](https://www.strava.com/legal/privacy). Journey Forward is "Powered by Strava" and uses the Strava API under Strava's API Agreement.

**Play Data Safety note.** Because the Strava feature can bring fitness activity (and, where your activities include them, location/GPS route fields) onto the device, the Play Store **Data safety** form declares **Fitness and wellness** data — and **Location** data if any activity GPS fields are imported — as *collected*. In every case the data is **kept on your device, not shared**, and collection only occurs after you opt in by connecting Strava.

---

## 6. Emergency contact

If you add an emergency contact, their name and phone number are stored only on your device as part of your profile. This information is never shared, never synced, and never automatically backed up. Tapping the call button uses your phone's standard dialer.

---

## 7. Backup and restore

Journey Forward includes an opt-in, manual backup feature:

- When you tap **Backup → Export**, the app produces a file containing your data and shares it via your device's standard share sheet — the same way you share photos.
- You can choose an **encrypted** backup (`.jfwbk`, protected by a passphrase you set, using PBKDF2-SHA256 key derivation and an AEAD-style stream cipher) or a plain JSON file.
- Journey Forward does **not** receive a copy of this file. **You control where it goes** — your email, cloud drive, USB stick, anywhere.
- We have separately disabled Android's automatic Google Drive backup (`allowBackup="false"` plus full exclusion in `dataExtractionRules.xml` and `backup_rules.xml`), so your data is never silently swept into a Google account backup or a device-to-device transfer without you explicitly exporting it.

---

## 8. PIN and biometric lock

If you set a PIN in Settings:

- The PIN is **never stored as plaintext**.
- It is concatenated with a per-install random salt and hashed via a slow key-derivation function (PBKDF2-HMAC-SHA256 with 150,000 iterations).
- The salt and hash are written to Android's Keystore-encrypted secure storage.
- When you enter your PIN to unlock, we re-derive the hash and compare in constant time.

If you choose biometric unlock:

- We call your device's native biometric authentication framework (BiometricPrompt).
- Journey Forward **never** accesses, reads, or stores your fingerprint, face, or any biometric template. That data stays inside your phone's secure enclave and is handled entirely by the operating system.

The Journal tab is additionally screenshot-protected on Android (`FLAG_SECURE`), so it doesn't appear in the Recents thumbnail and cannot be screen-captured or screen-recorded.

---

## 9. How to delete your data

Two options, both 100% effective:

1. **Uninstall the app.** All data stored by Journey Forward is removed when the app is uninstalled from your device.
2. **Clear app data.** In Android Settings → Apps → Journey Forward → Storage → "Clear data", which wipes every key without uninstalling.

There is no account to delete because **there is no account**. There is no data to request because **we never received any**.

---

## 10. Children's privacy

Journey Forward is designed for adults aged 18 and over. The app is not directed at children and does not knowingly collect any information from anyone under the age of 18. Recovery content can be intense and is intended for adult users.

---

## 11. Third-party services in the app binary

For transparency, Journey Forward is built with the following open-source Flutter packages. Except for the Strava integration noted below, they run **on your device only** and transmit none of your data:

- `flutter_local_notifications` — schedules and displays the reminder notifications
- `flutter_secure_storage` — Android Keystore-backed encrypted storage
- `local_auth` — biometric unlock via your phone's native APIs
- `speech_to_text` — wraps your phone's built-in speech recognition (see §5)
- `just_audio` — plays the bundled urge-surfing meditation audio file
- `share_plus` — opens your phone's system share sheet
- `image_picker` / `file_picker` — opens your phone's gallery/file picker
- `url_launcher` — opens crisis-line phone numbers in your dialer and external URLs in your browser
- `flutter_riverpod`, `go_router`, `fl_chart`, `intl`, `uuid`, `crypto` — internal app plumbing with no network behaviour
- `flutter_web_auth_2` / `http` — **network-capable**, used **only** for the optional Strava connection (see §5a). They open the Strava sign-in page in your system browser and fetch your own activities directly from Strava over HTTPS. They are dormant until you connect Strava, and they never communicate with any server of ours.

The full list is in [`pubspec.yaml`](pubspec.yaml).

---

## 12. Policy updates

If this privacy policy changes, the update will be included in a new app version. Because we collect no data, changes will only reflect improvements in transparency, new features added to the app, or clarifications. The "Effective date" at the top of this document will reflect the most recent change.

---

## 13. Contact

Questions about this policy?

**Shawn Fourie / Stillwater Studios**
Email: shawn@journeyforward.app

---

*Journey Forward is a free sobriety-support app that works offline by default — the only time it goes online is when you choose to connect Strava, and even then your data goes straight to Strava, never to us. We will never sell your data because we don't have your data.*
