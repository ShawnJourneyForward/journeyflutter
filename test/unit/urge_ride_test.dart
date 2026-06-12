import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/urge_ride.dart';

void main() {
  group('UrgeRide', () {
    test('JSON round-trip preserves all fields', () {
      final ride = UrgeRide(
        id: '42',
        date: DateTime(2026, 6, 12, 3, 14),
        seconds: 600,
      );
      final restored = UrgeRide.fromJson(ride.toJson());
      expect(restored.id, '42');
      expect(restored.date, DateTime(2026, 6, 12, 3, 14));
      expect(restored.seconds, 600);
    });

    test('fromJson tolerates seconds stored as a double', () {
      final r = UrgeRide.fromJson({
        'id': '1',
        'date': '2026-06-12T03:14:00.000',
        'seconds': 90.0,
      });
      expect(r.seconds, 90);
    });
  });
}
