import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/models/user_profile.dart';

void main() {
  group('UserProfile serialization', () {
    test('toJson/fromJson round trip preserves supported fields', () {
      const profile = UserProfile(
        username: 'Shawn',
        soberDate: '2026-05-01T08:00:00.000',
        dailySpend: 120.5,
        currency: '\$',
        timezone: 'Africa/Johannesburg',
        pledgeStreak: 4,
        lastPledgeDate: '2026-05-18',
        lastPledgeText: 'I choose clarity.',
        emergencyContact: EmergencyContact(name: 'Ava', phone: '+271234'),
        savingsGoal: 500,
        savingsGoalName: 'Weekend away',
        weeklyGoals: ['Walk outside'],
        myReasons: ['Family'],
        pros: ['Sleep'],
        cons: ['Hangovers'],
        lockMethod: 'pin',
        firedMilestoneDays: [1, 3, 7],
        firedSavingsTiers: [50, 100],
      );

      final decoded = UserProfile.fromJson(
        jsonDecode(profile.toJsonString()) as Map<String, dynamic>,
      );

      expect(decoded.username, 'Shawn');
      expect(decoded.dailySpend, 120.5);
      expect(decoded.currency, '\$');
      expect(decoded.emergencyContact?.name, 'Ava');
      expect(decoded.savingsGoal, 500);
      expect(decoded.lockMethod, 'pin');
      expect(decoded.weeklyGoals, ['Walk outside']);
      expect(decoded.firedMilestoneDays, [1, 3, 7]);
    });

    test('minimal JSON loads safely with defaults', () {
      final profile = UserProfile.fromJson({'username': 'Shawn'});

      expect(profile.username, 'Shawn');
      expect(DateTime.tryParse(profile.soberDate), isNotNull);
      expect(profile.dailySpend, 0);
      expect(profile.currency, 'R');
      expect(profile.lockMethod, 'none');
      expect(profile.weeklyGoals, isEmpty);
    });

    test('old backup/profile shape without optional fields loads safely', () {
      final profile = UserProfile.fromJson({
        'username': 'Shawn',
        'soberDate': '2026-05-01T08:00:00.000',
      });

      expect(profile.lastPledgeText, isNull);
      expect(profile.emergencyContact, isNull);
      expect(profile.savingsGoal, isNull);
      expect(profile.myReasons, isEmpty);
      expect(profile.pros, isEmpty);
      expect(profile.cons, isEmpty);
    });

    test('copyWith can clear nullable fields when null is explicitly passed', () {
      const profile = UserProfile(
        username: 'Shawn',
        soberDate: '2026-05-01T08:00:00.000',
        savingsGoal: 500,
        savingsGoalName: 'Weekend away',
        emergencyContact: EmergencyContact(name: 'Ava', phone: '+271234'),
      );

      final updated = profile.copyWith(
        savingsGoal: null,
        savingsGoalName: null,
        emergencyContact: null,
      );

      expect(updated.savingsGoal, isNull);
      expect(updated.savingsGoalName, isNull);
      expect(updated.emergencyContact, isNull);
    });

    test('copyWith preserves nullable fields when not passed', () {
      const profile = UserProfile(
        username: 'Shawn',
        soberDate: '2026-05-01T08:00:00.000',
        savingsGoal: 500,
        savingsGoalName: 'Weekend away',
        emergencyContact: EmergencyContact(name: 'Ava', phone: '+271234'),
      );

      final updated = profile.copyWith(username: 'Updated');

      expect(updated.username, 'Updated');
      expect(updated.savingsGoal, 500);
      expect(updated.savingsGoalName, 'Weekend away');
      expect(updated.emergencyContact?.name, 'Ava');
    });
  });
}
