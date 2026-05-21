class PlantLogic {
  // ── Public API ─────────────────────────────────────────────────────────────

  /// Returns the asset path for the plant image given elapsed sobriety time.
  ///
  /// Uses sub-day (second-level) precision so the first 3 days show visible
  /// stage changes as time passes rather than only updating at midnight.
  static String getPlantAssetForElapsed(Duration elapsed) {
    final stage = plantStageForElapsed(elapsed);
    return 'assets/images/growth_stages/stage_$stage.webp';
  }

  /// Convenience wrapper accepting whole days (used by lock/onboarding screens
  /// that only have an integer day count available).
  static String getPlantAsset(int daysSober) =>
      getPlantAssetForElapsed(Duration(days: daysSober));

  // ── Core growth function ───────────────────────────────────────────────────

  /// Computes the plant stage (11–100) for the given elapsed sobriety duration.
  ///
  /// Growth curve (landmarks):
  ///   0 days   → stage 11  (seed just planted)
  ///   3 days   → stage 25  (rapid early growth)
  ///   7 days   → stage 33  (one week milestone)
  ///   30 days  → stage 35  (one month — growth slows)
  ///   365 days → stage 100 (fully mature heritage plant)
  ///   365+ days → stage 100 (held at maximum)
  ///
  /// The same sobriety duration always produces the same stage.
  static int plantStageForElapsed(Duration elapsed) {
    final days = elapsed.inSeconds / Duration.secondsPerDay;

    if (days <= 0) return 11;
    if (days <= 3) return _lerpStage(days, 0, 3, 11, 25);
    if (days <= 7) return _lerpStage(days, 3, 7, 25, 33);
    if (days <= 30) return _lerpStage(days, 7, 30, 33, 35);
    if (days <= 365) return _lerpStage(days, 30, 365, 35, 100);
    return 100;
  }

  // ── Labels ─────────────────────────────────────────────────────────────────

  /// Returns a short label for the current plant life-stage — used as the
  /// accessibility description and the JourneyCard node caption.
  static String getStageLabel(int daysSober) {
    if (daysSober == 0) return 'The Seed';
    if (daysSober <= 3) return 'First Sprout';
    if (daysSober <= 7) return 'Taking Root';
    if (daysSober <= 14) return 'Early Growth';
    if (daysSober <= 30) return 'Finding Light';
    if (daysSober <= 60) return 'Growing Strong';
    if (daysSober <= 90) return 'In Full Bloom';
    if (daysSober <= 180) return 'Deep Roots';
    if (daysSober <= 365) return 'Flourishing';
    return 'Heritage Plant';
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  static int _lerpStage(
    double days,
    double startDay,
    double endDay,
    int startStage,
    int endStage,
  ) {
    final progress = ((days - startDay) / (endDay - startDay)).clamp(0.0, 1.0);
    return (startStage + (endStage - startStage) * progress)
        .round()
        .clamp(startStage, endStage);
  }
}
