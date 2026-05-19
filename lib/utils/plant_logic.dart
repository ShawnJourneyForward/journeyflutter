import 'dart:math' as math;

class PlantLogic {
  static String getPlantAsset(int daysSober) {
    final safeDay = daysSober.clamp(0, 999999);
    int stage = 1;

    // ==========================================
    // PHASE 1: The First 14 Days (Stages 1 to 30)
    // Custom mapping to ensure intense early visual rewards
    // ==========================================
    if (safeDay <= 14) {
      const earlyStages = [
        1,  // Day 0: The Seed
        5,  // Day 1: Sprouting quickly (+4 stages)
        8,  // Day 2: Fast growth (+3 stages)
        11, // Day 3: Fast growth (+3 stages)
        14, // Day 4: (+3 stages)
        16, // Day 5: Slowing slightly (+2 stages)
        18, // Day 6: (+2 stages)
        20, // Day 7 (1 Week): (+2 stages)
        22, // Day 8: (+2 stages)
        24, // Day 9: (+2 stages)
        25, // Day 10: Slower growth (+1 stage)
        26, // Day 11: (+1 stage)
        27, // Day 12: (+1 stage)
        28, // Day 13: (+1 stage)
        30  // Day 14 (2 Weeks): Big visual jump for the milestone
      ];
      stage = earlyStages[safeDay];
    }
    // ==========================================
    // PHASE 2: The Long Haul (Days 15 to 365)
    // ==========================================
    else if (safeDay >= 365) {
      stage = 100; // Fully grown Heritage plant
    }
    else {
      // 70 images spread over 351 days using Quadratic Ease-Out so growth
      // feels fast early on and tapers as the user approaches a full year.
      double progress = (safeDay - 14) / (365 - 14);
      double curve = 1.0 - math.pow(1.0 - progress, 2);
      stage = 30 + (curve * 70).round();
    }

    stage = stage.clamp(1, 100);
    return 'assets/images/growth_stages/stage_$stage.webp';
  }

  /// Returns a short label for the current plant life-stage — used as
  /// the accessibility description and the JourneyCard node label.
  static String getStageLabel(int daysSober) {
    if (daysSober == 0)   return 'The Seed';
    if (daysSober <= 3)   return 'First Sprout';
    if (daysSober <= 7)   return 'Taking Root';
    if (daysSober <= 14)  return 'Early Growth';
    if (daysSober <= 30)  return 'Finding Light';
    if (daysSober <= 60)  return 'Growing Strong';
    if (daysSober <= 90)  return 'In Full Bloom';
    if (daysSober <= 180) return 'Deep Roots';
    if (daysSober <= 365) return 'Flourishing';
    return 'Heritage Plant';
  }
}
