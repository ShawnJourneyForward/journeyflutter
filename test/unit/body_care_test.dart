import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/body_care_win.dart';
import 'package:journey_forward/models/planner_activity.dart';
import 'package:journey_forward/models/planner_session.dart';
import 'package:journey_forward/models/planner_weight_log.dart';
import 'package:journey_forward/models/user_profile.dart';
import 'package:journey_forward/screens/body_care_shared.dart';

void main() {
  group('BodyCareWin', () {
    test('round-trips through JSON', () {
      final w = BodyCareWin(
        id: 'w1',
        date: DateTime(2026, 6, 20, 8, 30),
        kind: 'energy',
        note: 'felt light',
      );
      final back = BodyCareWin.fromJson(w.toJson());
      expect(back.id, 'w1');
      expect(back.kind, 'energy');
      expect(back.note, 'felt light');
      expect(back.date, DateTime(2026, 6, 20, 8, 30));
    });

    test('missing / blank kind degrades to custom', () {
      expect(BodyCareWin.fromJson({'id': 'x', 'date': '2026-06-01'}).kind,
          'custom');
      expect(
          BodyCareWin.fromJson({'id': 'x', 'date': '2026-06-01', 'kind': '  '})
              .kind,
          'custom');
    });

    test('a custom win keeps its free text', () {
      final w = BodyCareWin(
          id: 'c', date: DateTime(2026, 6, 1), kind: 'custom', note: 'my words');
      expect(BodyCareWin.fromJson(w.toJson()).note, 'my words');
    });
  });

  group('bodyCarePlantStage', () {
    test('is a small floor before anything is logged', () {
      expect(bodyCarePlantStage(0), 0.04);
    });

    test('grows once care begins and is bounded to 1.0', () {
      expect(bodyCarePlantStage(1), greaterThanOrEqualTo(0.12));
      expect(bodyCarePlantStage(8), greaterThan(bodyCarePlantStage(1)));
      expect(bodyCarePlantStage(16), 1.0);
      expect(bodyCarePlantStage(500), 1.0); // clamped, never overflows
    });

    test('is monotonic (a rest week never shrinks the plant)', () {
      var prev = bodyCarePlantStage(0);
      for (var n = 1; n <= 40; n++) {
        final cur = bodyCarePlantStage(n);
        expect(cur, greaterThanOrEqualTo(prev));
        prev = cur;
      }
    });
  });

  group('bodyCareWeeksTended', () {
    PlannerActivity act(DateTime d) =>
        PlannerActivity(id: 'a$d', date: d, type: SessionType.other, minutes: 20);
    PlannerWeightLog wt(DateTime d) =>
        PlannerWeightLog(id: 'k$d', date: d, weightKg: 80);
    BodyCareWin win(DateTime d) => BodyCareWin(id: 'w$d', date: d, kind: 'energy');

    test('counts DISTINCT Sunday-weeks across all care types', () {
      // Three dates each >7 days apart → three distinct Sunday weeks.
      final n = bodyCareWeeksTended(
        wins: [win(DateTime(2026, 6, 20))],
        weights: [wt(DateTime(2026, 6, 10))],
        activities: [act(DateTime(2026, 6, 1))],
      );
      expect(n, 3);
    });

    test('two actions in the same week count once', () {
      final n = bodyCareWeeksTended(
        wins: [win(DateTime(2026, 6, 1)), win(DateTime(2026, 6, 2))],
        weights: const [],
        activities: [act(DateTime(2026, 6, 3))],
      );
      expect(n, 1);
    });

    test('no care = zero weeks tended', () {
      expect(
          bodyCareWeeksTended(wins: const [], weights: const [], activities: const []),
          0);
    });
  });

  group('bodyCareTendedThisWeek', () {
    test('true when any care landed this week, false otherwise', () {
      final now = DateTime.now();
      expect(
        bodyCareTendedThisWeek(
          wins: [BodyCareWin(id: 'w', date: now, kind: 'showedup')],
          weights: const [],
          activities: const [],
        ),
        isTrue,
      );
      expect(
        bodyCareTendedThisWeek(
          wins: [BodyCareWin(id: 'w', date: DateTime(2020, 1, 1), kind: 'showedup')],
          weights: const [],
          activities: const [],
        ),
        isFalse,
      );
    });
  });

  group('UserProfile body-care fields', () {
    test('default to gate-pending / numbers-shown / no height', () {
      const p = UserProfile(username: 'a', soberDate: '2026-01-01');
      expect(p.weightTrackingMode, '');
      expect(p.hideWeightNumbers, false);
      expect(p.heightCm, isNull);
    });

    test('round-trip through JSON preserves the new fields', () {
      const p = UserProfile(
        username: 'a',
        soberDate: '2026-01-01',
        weightTrackingMode: 'sometimes',
        hideWeightNumbers: true,
        heightCm: 178,
      );
      final back = UserProfile.fromJson(p.toJson());
      expect(back.weightTrackingMode, 'sometimes');
      expect(back.hideWeightNumbers, true);
      expect(back.heightCm, 178);
    });

    test('copyWith updates the new fields and can clear height', () {
      const p = UserProfile(
          username: 'a', soberDate: '2026-01-01', heightCm: 178);
      expect(p.copyWith(weightTrackingMode: 'feelings').weightTrackingMode,
          'feelings');
      expect(p.copyWith(hideWeightNumbers: true).hideWeightNumbers, true);
      // Omitting heightCm keeps it; passing null clears it (sentinel pattern).
      expect(p.copyWith().heightCm, 178);
      expect(p.copyWith(heightCm: null).heightCm, isNull);
    });
  });
}
