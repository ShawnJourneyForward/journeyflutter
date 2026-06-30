// GPS recorder for the walk / run tracker — the OFFLINE replacement for the
// removed Strava sync. It listens to the device's position stream, totals the
// distance travelled (great-circle between consecutive accepted fixes), and
// times the moving portion. Coordinates are used only on-device to accumulate
// the distance — nothing is transmitted (the app ships no INTERNET permission)
// and no path / coordinates are persisted: only the resulting distance and
// duration are handed to the save sheet.
//
// The maths (haversine + the jitter / accuracy / implied-speed filter) is
// factored into pure functions so it can be unit-tested without a device.

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// Earth mean radius in metres (haversine).
const double _earthRadiusM = 6371000.0;

/// A fix whose reported accuracy is worse than this (metres) is treated as
/// unreliable: it never contributes to distance and flips the "weak GPS"
/// indicator on.
const double kMaxUsableAccuracyM = 30.0;

/// At or below this accuracy (metres) the GPS is considered "ready".
const double kGoodAccuracyM = 20.0;

/// Movement between two consecutive fixes smaller than this (metres) is
/// discarded as standing-still jitter rather than added to the distance.
const double kMinStepM = 2.5;

/// Implied speed (metres / second) above which a step is rejected as a GPS
/// glitch. ~12 m/s ≈ 43 km/h — comfortably above any walk or run, so real
/// movement is always kept while teleport spikes are dropped.
const double kMaxSpeedMps = 12.0;

/// Great-circle distance in metres between two lat/lng points (haversine).
double haversineMeters(
    double lat1, double lon1, double lat2, double lon2) {
  final dLat = _deg2rad(lat2 - lat1);
  final dLon = _deg2rad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(_deg2rad(lat1)) *
          math.cos(_deg2rad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return _earthRadiusM * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

double _deg2rad(double d) => d * math.pi / 180.0;

/// Decide how much distance a new fix adds, given the previous accepted fix.
/// Returns the metres to add (0 when the step is rejected as jitter, a bad-
/// accuracy fix, or an unrealistic speed spike). [dtSeconds] is the time gap
/// between the two fixes; pass a non-positive value to skip the speed check.
double distanceStepMeters({
  required double prevLat,
  required double prevLon,
  required double lat,
  required double lon,
  required double accuracyM,
  required double dtSeconds,
}) {
  if (accuracyM > kMaxUsableAccuracyM) return 0;
  final d = haversineMeters(prevLat, prevLon, lat, lon);
  if (d < kMinStepM) return 0;
  if (dtSeconds > 0 && d / dtSeconds > kMaxSpeedMps) return 0;
  return d;
}

/// The outcome of asking for permission + location services.
enum LocationGate { ready, serviceDisabled, denied, deniedForever }

/// Request location services + permission in one shot, returning a single
/// status the UI can branch on.
Future<LocationGate> requestLocationGate() async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    return LocationGate.serviceDisabled;
  }
  var perm = await Geolocator.checkPermission();
  if (perm == LocationPermission.denied) {
    perm = await Geolocator.requestPermission();
  }
  if (perm == LocationPermission.deniedForever) {
    return LocationGate.deniedForever;
  }
  if (perm == LocationPermission.denied) return LocationGate.denied;
  return LocationGate.ready;
}

enum RecorderStatus { idle, acquiring, recording, paused, finished }

/// Owns one recording session: the position subscription, the accumulated
/// distance and the moving-time clock. While recording, the position stream
/// runs as an Android FOREGROUND SERVICE (started in [start] with a wake lock +
/// ongoing notification) so a walk/run keeps recording with the screen off or
/// the app backgrounded. The service is started only while the app is visible,
/// so it runs under the "while using the app" grant — there is deliberately NO
/// background-location permission.
class GpsRecorder extends ChangeNotifier {
  StreamSubscription<Position>? _sub;
  Timer? _ticker;

  RecorderStatus _status = RecorderStatus.idle;
  RecorderStatus get status => _status;

  double _distanceMeters = 0;
  double get distanceMeters => _distanceMeters;
  double get distanceKm => _distanceMeters / 1000.0;

  /// Accuracy (metres) of the most recent fix, or null before the first fix.
  double? _accuracyM;
  double? get accuracyM => _accuracyM;

  /// True once a usable fix has arrived.
  bool get hasFix => _accuracyM != null && _accuracyM! <= kMaxUsableAccuracyM;
  bool get gpsGood => _accuracyM != null && _accuracyM! <= kGoodAccuracyM;

  // Moving-time clock: total = _accumulated + (recording ? now - _since : 0).
  Duration _accumulated = Duration.zero;
  DateTime? _since;

  // Previous accepted fix for the distance step.
  double? _prevLat;
  double? _prevLon;
  DateTime? _prevAt;

  Duration get elapsed {
    if (_status == RecorderStatus.recording && _since != null) {
      return _accumulated + DateTime.now().difference(_since!);
    }
    return _accumulated;
  }

  /// Pace in seconds per km, or null until enough distance to be meaningful.
  double? get paceSecPerKm {
    if (_distanceMeters < 50) return null;
    final secs = elapsed.inSeconds;
    if (secs <= 0) return null;
    return secs / distanceKm;
  }

  /// Begin listening for fixes WITHOUT counting distance yet, so the UI can
  /// show a live "finding GPS / ready" state before the user taps Start.
  void warmUp() {
    if (_sub != null) return;
    _status = RecorderStatus.acquiring;
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).listen(_onPosition, onError: (_) {/* transient — keep waiting */});
    notifyListeners();
  }

  /// Begin recording. Re-subscribes the position stream as a FOREGROUND SERVICE
  /// (with a wake lock + an ongoing notification) so the walk/run keeps
  /// recording when the screen turns off or the app is backgrounded. The
  /// service is started here — while the app is visible — so it runs under the
  /// normal "while using the app" grant and needs no background-location
  /// permission. [notifTitle]/[notifText] localise the persistent notification.
  void start({required String notifTitle, required String notifText}) {
    _distanceMeters = 0;
    _accumulated = Duration.zero;
    _since = DateTime.now();
    _prevLat = null;
    _prevLon = null;
    _prevAt = null;
    _sub?.cancel();
    _sub = Geolocator.getPositionStream(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
        foregroundNotificationConfig: ForegroundNotificationConfig(
          notificationTitle: notifTitle,
          notificationText: notifText,
          notificationChannelName: notifTitle,
          enableWakeLock: true,
          setOngoing: true,
        ),
      ),
    ).listen(_onPosition, onError: (_) {/* transient — keep waiting */});
    _status = RecorderStatus.recording;
    _startTicker();
    notifyListeners();
  }

  void pause() {
    if (_status != RecorderStatus.recording) return;
    _accumulated = elapsed; // freeze
    _since = null;
    _status = RecorderStatus.paused;
    _ticker?.cancel();
    notifyListeners();
  }

  void resume() {
    if (_status != RecorderStatus.paused) return;
    _since = DateTime.now();
    // Drop the stale previous fix so the gap while paused isn't added.
    _prevLat = null;
    _prevLon = null;
    _prevAt = null;
    _status = RecorderStatus.recording;
    _startTicker();
    notifyListeners();
  }

  /// Stop recording and freeze the totals. The subscription is closed; the
  /// accumulated distance / elapsed remain readable for the save sheet.
  void finish() {
    if (_status == RecorderStatus.recording) _accumulated = elapsed;
    _since = null;
    _status = RecorderStatus.finished;
    _ticker?.cancel();
    _sub?.cancel();
    _sub = null;
    notifyListeners();
  }

  void _startTicker() {
    _ticker?.cancel();
    // Drives the 1-second UI refresh of the clock / pace.
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_status == RecorderStatus.recording) notifyListeners();
    });
  }

  void _onPosition(Position p) {
    _accuracyM = p.accuracy;
    if (_status == RecorderStatus.recording && p.accuracy <= kMaxUsableAccuracyM) {
      final now = p.timestamp;
      if (_prevLat != null && _prevLon != null) {
        final dt = _prevAt != null
            ? now.difference(_prevAt!).inMilliseconds / 1000.0
            : 0.0;
        _distanceMeters += distanceStepMeters(
          prevLat: _prevLat!,
          prevLon: _prevLon!,
          lat: p.latitude,
          lon: p.longitude,
          accuracyM: p.accuracy,
          dtSeconds: dt,
        );
      }
      _prevLat = p.latitude;
      _prevLon = p.longitude;
      _prevAt = now;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}
