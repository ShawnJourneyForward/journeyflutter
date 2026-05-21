import 'package:flutter_test/flutter_test.dart';
import 'package:journey_forward/utils/plant_logic.dart';

int _stageFromAsset(String asset) {
  final match = RegExp(r'stage_(\d+)\.webp$').firstMatch(asset);
  return int.parse(match!.group(1)!);
}

void main() {
  // Plant images on disk are stage_11.webp .. stage_100.webp; the growth
  // curve starts at stage 11 ("seed just planted") and saturates at 100.
  group('PlantLogic', () {
    test('day 0 returns the initial stage', () {
      expect(PlantLogic.getPlantAsset(0), endsWith('stage_11.webp'));
      expect(PlantLogic.getStageLabel(0), 'The Seed');
    });

    test('early days return early growth stages', () {
      final day1 = _stageFromAsset(PlantLogic.getPlantAsset(1));
      final day7 = _stageFromAsset(PlantLogic.getPlantAsset(7));

      expect(day1, inInclusiveRange(11, 33));
      expect(day7, inInclusiveRange(day1, 33));
    });

    test('mid-range days return a middle stage', () {
      final stage = _stageFromAsset(PlantLogic.getPlantAsset(90));

      expect(stage, inInclusiveRange(35, 99));
      expect(PlantLogic.getStageLabel(90), 'In Full Bloom');
    });

    test('high days return the mature final stage', () {
      expect(PlantLogic.getPlantAsset(365), endsWith('stage_100.webp'));
      expect(PlantLogic.getPlantAsset(5000), endsWith('stage_100.webp'));
      expect(PlantLogic.getStageLabel(5000), 'Heritage Plant');
    });

    test('negative days clamp to the initial stage', () {
      expect(PlantLogic.getPlantAsset(-1), endsWith('stage_11.webp'));
    });

    test('returned stage index always stays in range', () {
      for (final day in [0, 1, 14, 15, 30, 60, 90, 180, 364, 365, 5000]) {
        final stage = _stageFromAsset(PlantLogic.getPlantAsset(day));
        expect(stage, inInclusiveRange(11, 100), reason: 'day $day');
      }
    });

    test('stage progression is monotonically non-decreasing', () {
      int prev = 0;
      for (int day = 0; day <= 365; day++) {
        final stage = _stageFromAsset(PlantLogic.getPlantAsset(day));
        expect(stage, greaterThanOrEqualTo(prev), reason: 'day $day regressed');
        prev = stage;
      }
    });

    test('intermediate day stage falls in expected range', () {
      // Phase 2 days (>30) sit between stages 35 and 100.
      for (final day in [45, 100, 200, 300]) {
        final stage = _stageFromAsset(PlantLogic.getPlantAsset(day));
        expect(stage, inInclusiveRange(35, 100), reason: 'day $day');
      }
    });
  });

  group('PlantLogic.getStageLabel boundaries', () {
    test('day 0 → The Seed', () {
      expect(PlantLogic.getStageLabel(0), 'The Seed');
    });

    test('days 1–3 → First Sprout', () {
      expect(PlantLogic.getStageLabel(1), 'First Sprout');
      expect(PlantLogic.getStageLabel(3), 'First Sprout');
    });

    test('days 4–7 → Taking Root', () {
      expect(PlantLogic.getStageLabel(4), 'Taking Root');
      expect(PlantLogic.getStageLabel(7), 'Taking Root');
    });

    test('days 8–14 → Early Growth', () {
      expect(PlantLogic.getStageLabel(8), 'Early Growth');
      expect(PlantLogic.getStageLabel(14), 'Early Growth');
    });

    test('days 15–30 → Finding Light', () {
      expect(PlantLogic.getStageLabel(15), 'Finding Light');
      expect(PlantLogic.getStageLabel(30), 'Finding Light');
    });

    test('days 31–60 → Growing Strong', () {
      expect(PlantLogic.getStageLabel(31), 'Growing Strong');
      expect(PlantLogic.getStageLabel(60), 'Growing Strong');
    });

    test('days 61–90 → In Full Bloom', () {
      expect(PlantLogic.getStageLabel(61), 'In Full Bloom');
      expect(PlantLogic.getStageLabel(90), 'In Full Bloom');
    });

    test('days 91–180 → Deep Roots', () {
      expect(PlantLogic.getStageLabel(91), 'Deep Roots');
      expect(PlantLogic.getStageLabel(180), 'Deep Roots');
    });

    test('days 181–365 → Flourishing', () {
      expect(PlantLogic.getStageLabel(181), 'Flourishing');
      expect(PlantLogic.getStageLabel(365), 'Flourishing');
    });

    test('days 366+ → Heritage Plant', () {
      expect(PlantLogic.getStageLabel(366), 'Heritage Plant');
      expect(PlantLogic.getStageLabel(3650), 'Heritage Plant');
    });
  });
}
