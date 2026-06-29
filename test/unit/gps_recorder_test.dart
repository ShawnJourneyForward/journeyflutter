import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/utils/gps_recorder.dart';

void main() {
  group('haversineMeters', () {
    test('same point is zero', () {
      expect(haversineMeters(0, 0, 0, 0), 0);
      expect(haversineMeters(-29.85, 31.02, -29.85, 31.02), 0);
    });

    test('one degree of longitude at the equator is ~111 km', () {
      final d = haversineMeters(0, 0, 0, 1);
      expect(d, closeTo(111195, 100));
    });

    test('is symmetric', () {
      final a = haversineMeters(-29.85, 31.02, -29.86, 31.03);
      final b = haversineMeters(-29.86, 31.03, -29.85, 31.02);
      expect(a, closeTo(b, 0.001));
    });
  });

  group('distanceStepMeters', () {
    // ~5 m due north of the equator origin.
    const lat5m = 5 / 111195;

    test('accepts a normal walking step', () {
      final d = distanceStepMeters(
        prevLat: 0,
        prevLon: 0,
        lat: lat5m,
        lon: 0,
        accuracyM: 8,
        dtSeconds: 3,
      );
      expect(d, closeTo(5, 0.5));
    });

    test('rejects a fix with poor accuracy', () {
      final d = distanceStepMeters(
        prevLat: 0,
        prevLon: 0,
        lat: lat5m,
        lon: 0,
        accuracyM: kMaxUsableAccuracyM + 1,
        dtSeconds: 3,
      );
      expect(d, 0);
    });

    test('rejects sub-jitter movement while standing still', () {
      const lat1m = 1 / 111195;
      final d = distanceStepMeters(
        prevLat: 0,
        prevLon: 0,
        lat: lat1m,
        lon: 0,
        accuracyM: 8,
        dtSeconds: 3,
      );
      expect(d, 0);
    });

    test('rejects an unrealistic speed spike', () {
      // ~5 m in 0.1 s = 50 m/s, well over the cap.
      final d = distanceStepMeters(
        prevLat: 0,
        prevLon: 0,
        lat: lat5m,
        lon: 0,
        accuracyM: 8,
        dtSeconds: 0.1,
      );
      expect(d, 0);
    });

    test('skips the speed check when dt is unknown', () {
      final d = distanceStepMeters(
        prevLat: 0,
        prevLon: 0,
        lat: lat5m,
        lon: 0,
        accuracyM: 8,
        dtSeconds: 0,
      );
      expect(d, closeTo(5, 0.5));
    });
  });
}
