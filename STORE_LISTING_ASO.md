# Journey Forward — Store Listing & ASO (privacy-first)

This is a ready-to-paste Google Play listing kit. The whole strategy leads with
the one thing competitors in this category can't honestly claim: **your recovery
data never leaves your phone.** No account, no cloud, no analytics SDK, no ads.

> Verify before publishing: the differentiator claims below are only true while
> the app keeps `allowBackup=false`, requests **no `INTERNET` permission**, and
> bundles no analytics/ads SDK. Re-confirm the merged manifest before each
> release (see "Privacy claims — keep them true").

---

## 0. Identity (Play Console)

- **Developer / publisher name (public, shown under the app):** `Still Water`
- **App name:** `Journey Forward`
- **Package / app ID:** `com.journeyforward.journey_forward`
- **Contact email (public on listing):** pick ONE and use it everywhere —
  site currently says `shawn@journeyforward.app`, the web bundle said `hello@…`.

> "Still Water" is the house brand (no "Studios"); "Journey Forward" is the app.
> The developer name is hard to change after registration — register it as
> `Still Water` exactly.

---

## 1. App title & subtitle

- **Title (30 char max):** `Journey Forward: Sober Days`
- **Short description (80 char max):**
  `Private sobriety companion. Counter, cravings toolkit & journal — all on-device.`

Alternate short descriptions to A/B test:
- `Track sober days, ride out cravings, journal — 100% private, no account, no ads.`
- `Your calm recovery companion. Works offline. Nothing leaves your phone.`

---

## 2. Full description (Play, 4000 char max)

> Journey Forward is a calm, private companion for staying sober — built around
> one promise: **what you write here stays on your phone.** No account to make,
> no cloud to trust, no ads, no trackers. Open it offline on day one and it just
> works.
>
> **See your progress add up.**
> A live counter shows the days, hours and minutes you've reclaimed, the money
> you've saved, and the milestones ahead — from your first 24 hours to a year and
> beyond. Set a future quit date and it counts you down to day one.
>
> **Get through the hard moments.**
> A calm toolkit is one tap away: paced breathing, grounding, an urge-surfing
> timer, and **TIPP** — the fast, body-based crisis-survival skills (cool down,
> move, breathe, release) for when distress spikes past thinking. Crisis lines
> stay reachable even when the app is locked.
>
> **Learn what actually works — for you.**
> Log a craving and what you did about it, and Journey Forward quietly surfaces
> your own patterns: which responses kept you sober, the hours of day you're most
> tender, and what tends to be underneath. Your personal "What I've learned"
> safety plan is built entirely on your device from your own check-ins.
>
> **Reflect and grow.**
> A private journal with gentle prompts, daily gratitude, a vision board for the
> life you're building, future-self letters, and a weekly care summary you can
> export.
>
> **Built to be trusted.**
> • No internet permission — it can't phone home.
> • Optional PIN or biometric lock, with the screen hidden from the app switcher.
> • No account, no email, no analytics, no ads — ever.
> • Your data is yours: back it up to an encrypted file you control.
>
> Recovery is hard enough. Your tools should be calm, kind, and completely
> yours. Journey Forward is.
>
> *Journey Forward is a self-help companion, not medical treatment. If you're in
> danger, contact your local emergency number or a crisis line.*

---

## 3. ASO keyword themes

Primary intent (work into title/short/long naturally — Play indexes the listing):
`sobriety` · `sober days counter` · `sober tracker` · `quit drinking` ·
`recovery` · `addiction recovery` · `cravings` · `urge surfing` · `relapse
prevention` · `clean time`

Differentiator keywords (low competition, high trust value):
`private` · `offline` · `no account` · `no ads` · `on-device` · `journal`

Avoid trademarked program names (e.g. specific 12-step brand terms) in metadata.

---

## 4. "What's new" (this release)

```
A calmer, smarter companion:
• New: "What I've learned" — a private safety plan built from your own check-ins.
• New: TIPP — fast, body-based skills for when distress spikes.
• Easier for everyone: clearer screen-reader support on the counter, charts and heatmap.
Everything still stays on your phone.
```

---

## 5. Screenshot plan (8 frames, phone)

Each frame = real UI + one short benefit caption (white text, forest band).
1. **Live counter** — "Every second sober, counted."
2. **Calm toolkit grid** — "Get through the moment."
3. **TIPP module (expanded)** — "Fast skills when it spikes."
4. **What I've learned** — "Your own patterns, on your phone."
5. **Journal + prompt** — "A diary only you can open."
6. **Progress / milestones** — "Watch it all add up."
7. **Vision board** — "Picture the life you're building."
8. **Privacy panel / lock** — "No account. No cloud. No ads."

Feature graphic (1024×500): the leaf mark on cream, tagline *"Recovery that stays
yours."*

---

## 6. Data safety form (Play Console answers)

- **Data collected / shared:** None.
- **Data processed:** All on-device; not transmitted off the device.
- **Encrypted in transit:** N/A (no transmission).
- **Deletion:** User can clear all data in-app / by uninstalling.
- These answers are only valid while there's no `INTERNET` permission and no
  analytics/ads SDK. If that ever changes, this form MUST change with it.

---

## 7. Privacy claims — keep them true (release checklist)

Before each release, confirm:
- [ ] Merged `AndroidManifest.xml` has **no `android.permission.INTERNET`**.
- [ ] `allowBackup=false` still set.
- [ ] No analytics / crash-reporting / ads dependency added to `pubspec.yaml`.
- [ ] `share_plus` / `url_launcher` are user-initiated only (share sheet, dialing
      a crisis line) — they don't transmit recovery data anywhere automatically.

---

## 8. Proposal — ethical one-time "Supporter" unlock

> **DECISION (2026-06-23): declined — the app stays 100% free.** No IAP, no
> billing permission. This section is kept only as a record of the option if it
> is ever reconsidered. The listing above stands as written.


A way to fund the app without betraying the privacy promise: a **single,
one-time in-app purchase** ("Support Journey Forward") that unlocks a few
cosmetic extras (e.g. extra themes / a supporter badge). No subscription, no
ads, no paywalled recovery features — every safety tool stays free forever.

**Why this is flagged, not built:**
1. It **reverses a deliberate decision.** `in_app_purchase` and the old tip jar
   were intentionally removed before launch (see launch-readiness notes). I won't
   silently re-add them.
2. It **adds a permission** (`com.android.vending.BILLING`) and a Google billing
   dependency — which weakens the "nothing to phone home" story and changes the
   Data safety form.
3. It's a **business decision**, not a bug fix.

If you want it, say so and I'll implement it as: one consumable/non-consumable
SKU, restore-purchases support, graceful offline handling, and zero gating of any
coping or safety feature. Otherwise the app stays 100% free and the listing above
stands as written.
