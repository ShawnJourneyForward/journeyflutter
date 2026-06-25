// On-device Strava integration — OAuth authorization-code flow + activity
// import. There is NO Journey Forward server in this path: the phone talks
// directly to Strava, the access/refresh tokens live only in the device's
// hardware-backed secure store, and the requested scope is read-only.
//
// Token storage uses the SAME FlutterSecureStorage options as
// lib/utils/encrypted_store.dart (Android EncryptedSharedPreferences +
// iOS first_unlock keychain accessibility) — never the library defaults — so
// the tokens are protected exactly like the rest of the app's sensitive data.
//
// PKCE: deliberately NOT used. Strava's OAuth ignores PKCE; the documented,
// accepted flow embeds the client secret (see strava_config.dart header) and
// constrains blast radius via the read-only scope.

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';
import 'package:http/http.dart' as http;

import '../models/planner_activity.dart';
import '../models/planner_session.dart';
import 'strava_config.dart';

/// Signals a Strava 429 (rate limited). Retained as a public type, but the fetch
/// path no longer THROWS it: a 429 mid-pagination is reported via
/// [StravaFetchResult.rateLimited] so the pages already fetched are kept. The UI
/// surfaces `plannerStravaRateLimited` when that flag is set.
class StravaRateLimited implements Exception {
  const StravaRateLimited();
  @override
  String toString() => 'StravaRateLimited';
}

/// Result of an activity fetch. Carries whatever pages were successfully
/// fetched plus a [rateLimited] flag when a 429 cut pagination short. The
/// caller imports [activities] regardless, so a rate limit mid-pagination NEVER
/// discards the pages already fetched.
class StravaFetchResult {
  const StravaFetchResult(this.activities, {this.rateLimited = false});
  final List<PlannerActivity> activities;
  final bool rateLimited;
}

/// On-device Strava client. Stateless apart from the secure-store token bundle.
class StravaService {
  StravaService._();

  /// Secure-storage key holding the JSON token bundle
  /// `{access_token, refresh_token, expires_at}`.
  static const String _tokenKey = 'strava_tokens';

  // Strava REST endpoints.
  static const String _authorizeUrl = 'https://www.strava.com/oauth/authorize';
  static const String _tokenUrl = 'https://www.strava.com/oauth/token';
  static const String _deauthUrl = 'https://www.strava.com/oauth/deauthorize';
  static const String _activitiesUrl =
      'https://www.strava.com/api/v3/athlete/activities';

  // Refresh this many seconds BEFORE the stamped expiry so a request never
  // races the boundary and 401s on a token that expired in flight.
  static const int _refreshSafetyMarginSeconds = 60;

  static const int _perPage = 30;

  // Hard ceiling on pages fetched in a single sync, so a heavy multi-year
  // account can't walk hundreds of blocking pages (and near-guarantee a 429)
  // in one go. A capped sync persists its progress, so the NEXT sync resumes
  // from where this one stopped rather than restarting from scratch.
  static const int _maxPagesPerSync = 20; // 20 × 30 = 600 activities / sync

  // On the very first sync (no prior `after`), only look back this far instead
  // of walking the entire account history.
  static const Duration _firstSyncWindow = Duration(days: 365);

  // SAME options as EncryptedStore — do NOT fall back to defaults.
  static const FlutterSecureStorage _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );

  // ─── Connect ────────────────────────────────────────────────────────────

  /// Run the OAuth authorization-code flow and persist the resulting tokens.
  ///
  /// Returns false fast when the build is unconfigured, when the user cancels
  /// the in-app browser tab, or when the token exchange fails. Returns true
  /// only once a usable token bundle has been written to secure storage.
  static Future<bool> connect() async {
    if (!stravaConfigured) return false;

    final authUrl = Uri.parse(_authorizeUrl).replace(queryParameters: {
      'client_id': stravaClientId,
      'redirect_uri': stravaRedirectUri,
      'response_type': 'code',
      'approval_prompt': 'auto',
      'scope': stravaScope,
    }).toString();

    final String code;
    try {
      final result = await FlutterWebAuth2.authenticate(
        url: authUrl,
        callbackUrlScheme: stravaCallbackScheme,
      );
      final returned = Uri.parse(result).queryParameters['code'];
      if (returned == null || returned.isEmpty) {
        debugPrint('[StravaService] connect: no code in callback');
        return false;
      }
      code = returned;
    } catch (e) {
      // User cancelled the tab, or the auth flow failed — degrade quietly.
      debugPrint('[StravaService] connect: auth flow aborted: $e');
      return false;
    }

    try {
      final resp = await http.post(Uri.parse(_tokenUrl), body: {
        'client_id': stravaClientId,
        'client_secret': stravaClientSecret,
        'code': code,
        'grant_type': 'authorization_code',
      });
      if (resp.statusCode != 200) {
        debugPrint('[StravaService] token exchange ${resp.statusCode}');
        return false;
      }
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      await _persistTokens(json);
      return true;
    } catch (e) {
      debugPrint('[StravaService] token exchange failed: $e');
      return false;
    }
  }

  // ─── Disconnect ───────────────────────────────────────────────────────────

  /// Best-effort deauthorize at Strava, THEN delete the local token bundle.
  /// A network failure on the deauthorize call is ignored — the local tokens
  /// are always cleared so the device forgets the account either way.
  static Future<void> disconnect() async {
    final token = await _currentAccessToken();
    if (token != null) {
      try {
        await http.post(
          Uri.parse(_deauthUrl),
          headers: {'Authorization': 'Bearer $token'},
        );
      } catch (e) {
        debugPrint('[StravaService] deauthorize failed (ignored): $e');
      }
    }
    await _secure.delete(key: _tokenKey);
  }

  // ─── Fetch activities ─────────────────────────────────────────────────────

  /// Fetch logged activities newer than [after], mapped to [PlannerActivity].
  ///
  /// Pages through `per_page=30` until a short/empty page is returned, capped at
  /// [_maxPagesPerSync] pages per call. When [after] is null (the first sync)
  /// the lookback is bounded to [_firstSyncWindow] so a heavy account doesn't
  /// walk its entire history in one blocking pass.
  ///
  /// On a 401 it forces a single refresh and retries that page once. On a 429 it
  /// STOPS but returns every page already fetched with `rateLimited: true` set —
  /// the caller imports the partial result and advances the sync cursor, so a
  /// rate limit never discards work and a retry resumes instead of restarting.
  /// Returns an empty result when the build is unconfigured or no valid token is
  /// available.
  static Future<StravaFetchResult> fetchActivities({DateTime? after}) async {
    if (!stravaConfigured) return const StravaFetchResult([]);

    var token = await _validToken();
    if (token == null) return const StravaFetchResult([]);

    // Bound the first sync (no prior cursor) to a recent window.
    final effectiveAfter =
        after ?? DateTime.now().toUtc().subtract(_firstSyncWindow);

    final results = <PlannerActivity>[];
    var page = 1;
    var refreshedOn401 = false;

    while (page <= _maxPagesPerSync) {
      final params = <String, String>{
        'per_page': '$_perPage',
        'page': '$page',
        'after':
            '${effectiveAfter.toUtc().millisecondsSinceEpoch ~/ 1000}',
      };
      final uri = Uri.parse(_activitiesUrl).replace(queryParameters: params);

      final resp = await http.get(
        uri,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (resp.statusCode == 401 && !refreshedOn401) {
        // Token may have been revoked or rotated out-of-band — force ONE
        // refresh and retry the SAME page once before giving up.
        refreshedOn401 = true;
        final refreshed = await _forceRefresh();
        if (refreshed == null) return StravaFetchResult(results);
        token = refreshed;
        continue;
      }
      if (resp.statusCode == 429) {
        // Keep every page fetched so far; let the caller import + advance the
        // cursor and try again later rather than throwing it all away.
        return StravaFetchResult(results, rateLimited: true);
      }
      if (resp.statusCode != 200) {
        debugPrint('[StravaService] activities page $page -> ${resp.statusCode}');
        break;
      }

      final decoded = jsonDecode(resp.body);
      if (decoded is! List || decoded.isEmpty) break;

      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final activity = _mapActivity(item);
          if (activity != null) results.add(activity);
        }
      }

      if (decoded.length < _perPage) break; // last page
      page++;
    }

    return StravaFetchResult(results);
  }

  // ─── Token lifecycle ──────────────────────────────────────────────────────

  /// Read the stored bundle and return a non-expired access token, refreshing
  /// when within the safety margin of expiry. Null when there is no usable
  /// token (no bundle, or a refresh that failed).
  static Future<String?> _validToken() async {
    final bundle = await _readTokens();
    if (bundle == null) return null;

    final accessToken = bundle['access_token'] as String?;
    final expiresAt = (bundle['expires_at'] as num?)?.toInt();
    if (accessToken == null) return _forceRefresh();

    final nowSec = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    if (expiresAt == null ||
        nowSec >= expiresAt - _refreshSafetyMarginSeconds) {
      return _forceRefresh();
    }
    return accessToken;
  }

  /// Exchange the stored refresh token for a fresh access token, persist the
  /// new bundle, and return the new access token. Null on failure.
  static Future<String?> _forceRefresh() async {
    final bundle = await _readTokens();
    final refreshToken = bundle?['refresh_token'] as String?;
    if (refreshToken == null || refreshToken.isEmpty) return null;

    try {
      final resp = await http.post(Uri.parse(_tokenUrl), body: {
        'client_id': stravaClientId,
        'client_secret': stravaClientSecret,
        'grant_type': 'refresh_token',
        'refresh_token': refreshToken,
      });
      if (resp.statusCode != 200) {
        debugPrint('[StravaService] refresh -> ${resp.statusCode}');
        return null;
      }
      final json = jsonDecode(resp.body) as Map<String, dynamic>;
      await _persistTokens(json);
      return json['access_token'] as String?;
    } catch (e) {
      debugPrint('[StravaService] refresh failed: $e');
      return null;
    }
  }

  /// The current access token without refreshing — used only on the
  /// disconnect path where we just want the latest token for deauthorize.
  static Future<String?> _currentAccessToken() async {
    final bundle = await _readTokens();
    return bundle?['access_token'] as String?;
  }

  static Future<void> _persistTokens(Map<String, dynamic> json) async {
    final bundle = <String, dynamic>{
      'access_token': json['access_token'],
      'refresh_token': json['refresh_token'],
      'expires_at': json['expires_at'],
    };
    await _secure.write(key: _tokenKey, value: jsonEncode(bundle));
  }

  static Future<Map<String, dynamic>?> _readTokens() async {
    try {
      final raw = await _secure.read(key: _tokenKey);
      if (raw == null || raw.isEmpty) return null;
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('[StravaService] read tokens failed: $e');
      return null;
    }
  }

  // ─── Mapping ──────────────────────────────────────────────────────────────

  /// Map one Strava activity JSON object to a [PlannerActivity]. Returns null
  /// when the payload lacks an id (nothing usable to dedupe / store).
  static PlannerActivity? _mapActivity(Map<String, dynamic> j) {
    final rawId = j['id'];
    if (rawId == null) return null;
    final stravaId = rawId.toString();

    final movingSeconds = (j['moving_time'] as num?)?.toInt() ?? 0;
    final meters = (j['distance'] as num?)?.toDouble() ?? 0.0;
    final date = _parseStartDate(j['start_date']);

    return PlannerActivity(
      // Stable, deterministic id so a re-sync maps to the SAME record (the
      // provider also dedupes on stravaId — this keeps ids reproducible).
      id: 'strava_$stravaId',
      date: date,
      type: _mapType(j),
      discipline: _mapDiscipline(j),
      minutes: (movingSeconds / 60).round(),
      distanceKm: meters > 0 ? meters / 1000.0 : null,
      avgHeartRate: (j['average_heartrate'] as num?)?.round(),
      source: ActivitySource.strava,
      stravaId: stravaId,
    );
  }

  /// Derive an [ActivityDiscipline] from Strava's `sport_type` (newer) or `type`
  /// (legacy) string — finer-grained than [_mapType] so a new import keeps rides,
  /// gym and yoga distinct instead of collapsing them all to cross-training.
  static ActivityDiscipline _mapDiscipline(Map<String, dynamic> j) {
    final raw = (j['sport_type'] ?? j['type'])?.toString().toLowerCase() ?? '';
    if (raw.contains('swim')) return ActivityDiscipline.swim;
    if (raw.contains('run')) return ActivityDiscipline.run;
    if (raw.contains('ride') ||
        raw.contains('bike') ||
        raw.contains('cycl') ||
        raw.contains('ebike')) {
      return ActivityDiscipline.ride;
    }
    if (raw.contains('hike')) return ActivityDiscipline.hike;
    if (raw.contains('walk')) return ActivityDiscipline.walk;
    if (raw.contains('yoga') || raw.contains('pilates')) {
      return ActivityDiscipline.yoga;
    }
    if (raw.contains('weight') ||
        raw.contains('strength') ||
        raw.contains('crossfit') ||
        raw.contains('workout')) {
      return ActivityDiscipline.gym;
    }
    if (raw.contains('row') ||
        raw.contains('elliptical') ||
        raw.contains('stair') ||
        raw.contains('hiit')) {
      return ActivityDiscipline.cardio;
    }
    return ActivityDiscipline.other;
  }

  /// Derive a [SessionType] from Strava's `sport_type` (newer) or `type`
  /// (legacy) string. Falls back to [SessionType.other].
  static SessionType _mapType(Map<String, dynamic> j) {
    final raw =
        (j['sport_type'] ?? j['type'])?.toString().toLowerCase() ?? '';
    if (raw.contains('swim')) return SessionType.swim;
    if (raw.contains('run')) return SessionType.easyRun;
    if (raw.contains('ride') ||
        raw.contains('bike') ||
        raw.contains('cycl') ||
        raw.contains('virtualride') ||
        raw.contains('ebike')) {
      return SessionType.crossTrain;
    }
    if (raw.contains('walk') ||
        raw.contains('hike') ||
        raw.contains('elliptical') ||
        raw.contains('weight') ||
        raw.contains('workout') ||
        raw.contains('crossfit') ||
        raw.contains('yoga') ||
        raw.contains('rowing')) {
      return SessionType.crossTrain;
    }
    return SessionType.other;
  }

  static DateTime _parseStartDate(Object? v) {
    if (v is String) {
      final parsed = DateTime.tryParse(v);
      if (parsed != null) return parsed.toLocal();
    }
    return DateTime.now();
  }
}
