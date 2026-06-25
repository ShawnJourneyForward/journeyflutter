/// Strava API app credentials for the running/planner integration.
///
/// The user (app owner) pastes their own Strava API application credentials
/// here, taken from https://www.strava.com/settings/api after creating an API
/// application.
///
/// SECURITY NOTE: Strava's OAuth does NOT support PKCE, so the
/// [stravaClientSecret] must be embedded in the app to complete the
/// authorization-code token exchange. An embedded secret is extractable from a
/// distributed binary — this is an accepted limitation of Strava's mobile flow.
/// The requested [stravaScope] is READ-ONLY (`read,activity:read`), which keeps
/// the blast radius of a leaked secret to read access on the connected account.
///
/// Leave the credential strings empty to disable the feature: [stravaConfigured]
/// returns false and the UI surfaces a "not configured" state instead of
/// attempting an OAuth handshake.
library;

/// Strava API application Client ID (numeric, shown as a string).
///
/// BLANKED for the offline launch — no live credential is compiled into the
/// shipped binary. To re-enable Strava, refill from a build-time --dart-define
/// or an untracked config rather than a committed const, and ROTATE the secret
/// first (the previous value is exposed in git history). See [kStravaEnabled].
const String stravaClientId = "";

/// Strava API application Client Secret. Embedded/extractable — see file header.
/// BLANKED for the offline launch (see [stravaClientId]).
const String stravaClientSecret = "";

/// Custom URL scheme registered for the OAuth redirect.
///
/// MUST be an RFC-3986-valid scheme: a letter followed by letters/digits/`+`/
/// `-`/`.` ONLY — no underscore, no uppercase. The in-app browser tab refuses
/// to redirect to an invalid scheme, so an underscore here silently breaks the
/// callback (this is why we do NOT reuse the applicationId
/// `com.journeyforward.journey_forward`, which contains an underscore).
///
/// This EXACT string must also be declared as the `flutter_web_auth_2`
/// CallbackActivity `<data android:scheme>` in
/// android/app/src/main/AndroidManifest.xml (and iOS CFBundleURLSchemes). Keep
/// all three in lock-step.
const String stravaCallbackScheme = "com.journeyforward.oauth";

/// Full redirect URI handed to Strava's authorize endpoint. Derived from
/// [stravaCallbackScheme] so the two can never drift. Only the HOST
/// (`localhost`) must match the "Authorization Callback Domain" configured in
/// the Strava API app — the scheme itself is ours to choose.
const String stravaRedirectUri = "$stravaCallbackScheme://localhost";

/// Read-only scope: lets us list and read activities, never write.
const String stravaScope = "read,activity:read";

/// Master on/off switch for the ENTIRE Strava integration.
///
/// Set to false to ship a build with NO Strava surface at all — no "Connect
/// with Strava" action (Plan or Settings), no source chips, no "Powered by
/// Strava" attribution, no import — while leaving the credentials and all the
/// Strava code untouched. Flip back to true to re-enable the feature; nothing
/// else needs to change. (Disabled for now so the new manual logging + insights
/// can be tested on a clean, Strava-free slate.)
const bool kStravaEnabled = false;

/// True only when the integration is enabled AND both halves of the credential
/// pair are filled in. Gate every Strava network/OAuth call AND every Strava UI
/// surface behind this so a disabled build degrades to a clean, Strava-free UI.
bool get stravaConfigured =>
    kStravaEnabled &&
    stravaClientId.isNotEmpty &&
    stravaClientSecret.isNotEmpty;
