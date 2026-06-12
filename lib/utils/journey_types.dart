// Journey types — what the user is stepping away from. Picked once during
// onboarding (changeable in Settings), stored on UserProfile.journeyType.
//
// The healing timelines are deliberately gentle: "many people" phrasing, no
// medical promises, day counts drawn from widely published recovery patterns
// (e.g. CDC/NHS smoking cessation timelines, alcohol liver-fat studies).
// They exist to give the user a felt sense of "my body is doing something
// good right now" — not to diagnose.
//
// English-only for now, like the settings/emergency screens — content moves
// to ARB files in the pending l10n pass.

import 'package:flutter/material.dart';

class JourneyBenefit {
  final int day;
  final String title;
  final String body;
  const JourneyBenefit(this.day, this.title, this.body);
}

class JourneyType {
  final String slug;

  /// Chip label in onboarding/settings ("Alcohol", "Gambling"...).
  final String label;

  /// Short adjective form for headers ("Alcohol-free", "Smoke-free"...).
  final String freeLabel;
  final IconData icon;
  final List<JourneyBenefit> benefits;

  const JourneyType({
    required this.slug,
    required this.label,
    required this.freeLabel,
    required this.icon,
    required this.benefits,
  });
}

const kJourneyTypes = <JourneyType>[
  JourneyType(
    slug: 'alcohol',
    label: 'Alcohol',
    freeLabel: 'Alcohol-free',
    icon: Icons.no_drinks_rounded,
    benefits: [
      JourneyBenefit(1, 'Your body starts rebalancing',
          'Blood sugar and hydration begin to steady within the first day.'),
      JourneyBenefit(3, 'The hardest physical days pass',
          'For many people the sharpest physical withdrawal eases around now.'),
      JourneyBenefit(7, 'Sleep starts to deepen',
          'Alcohol fragments sleep. A week in, nights often grow longer and more restful.'),
      JourneyBenefit(14, 'Your liver is recovering',
          'Liver fat can begin to reduce measurably within two weeks of stopping.'),
      JourneyBenefit(30, 'Skin, blood pressure, clarity',
          'A month in, many people see clearer skin, steadier blood pressure and brighter mood.'),
      JourneyBenefit(90, 'A steadier baseline',
          'Energy and mood often level out around three months as brain chemistry resettles.'),
      JourneyBenefit(365, 'A year of healing',
          'Long-term risks to your heart and liver are measurably lower than when you started.'),
    ],
  ),
  JourneyType(
    slug: 'smoking',
    label: 'Smoking',
    freeLabel: 'Smoke-free',
    icon: Icons.smoke_free_rounded,
    benefits: [
      JourneyBenefit(1, 'Carbon monoxide is gone',
          'Within a day, oxygen levels in your blood return to normal.'),
      JourneyBenefit(3, 'Nicotine has left your body',
          'Around 72 hours, breathing starts to feel easier as airways relax.'),
      JourneyBenefit(14, 'Circulation is improving',
          'From two weeks, walking and exercise begin to feel noticeably easier.'),
      JourneyBenefit(30, 'Your lungs are clearing',
          'The lungs\' tiny cleaning hairs regrow — coughing and congestion ease in the coming weeks.'),
      JourneyBenefit(90, 'Lung function rising',
          'Circulation and lung function can improve significantly by three months.'),
      JourneyBenefit(365, 'Heart risk halved',
          'After a year smoke-free, the added risk of coronary heart disease is about half a smoker\'s.'),
    ],
  ),
  JourneyType(
    slug: 'vaping',
    label: 'Vaping',
    freeLabel: 'Vape-free',
    icon: Icons.cloud_off_rounded,
    benefits: [
      JourneyBenefit(1, 'Nicotine is leaving',
          'Levels fall quickly — cravings peak early, then begin to soften.'),
      JourneyBenefit(3, 'Through the sharpest cravings',
          'Around day three many people are past the most intense pull.'),
      JourneyBenefit(7, 'Taste and smell sharpen',
          'Senses dulled by nicotine start returning within the first week.'),
      JourneyBenefit(30, 'Easier breathing',
          'Airway irritation eases over the first month for many people.'),
      JourneyBenefit(90, 'Steadier focus and mood',
          'Nicotine-driven dips in attention smooth out as your baseline resets.'),
    ],
  ),
  JourneyType(
    slug: 'cannabis',
    label: 'Cannabis',
    freeLabel: 'Cannabis-free',
    icon: Icons.grass_rounded,
    benefits: [
      JourneyBenefit(3, 'Through the edgiest days',
          'Irritability and restlessness often peak in the first few days, then ease.'),
      JourneyBenefit(7, 'Appetite and sleep rebalancing',
          'Your body starts finding its own rhythm again this week.'),
      JourneyBenefit(14, 'Dreams return',
          'REM sleep rebounds — vivid dreams are a sign your sleep is recovering.'),
      JourneyBenefit(30, 'Sharper memory and focus',
          'Many people notice clearer short-term memory around the one-month mark.'),
      JourneyBenefit(90, 'Motivation rising',
          'The brain\'s reward signalling keeps recovering over the first months.'),
    ],
  ),
  JourneyType(
    slug: 'gambling',
    label: 'Gambling',
    freeLabel: 'Bet-free',
    icon: Icons.casino_outlined,
    benefits: [
      JourneyBenefit(1, 'The losses stop today',
          'Every day clean is money that stays yours.'),
      JourneyBenefit(7, 'The urgency quietens',
          'The pull to chase losses starts losing its grip in the first week.'),
      JourneyBenefit(30, 'Financial clarity',
          'A month in, the picture of your money becomes honest again — that clarity is recovery.'),
      JourneyBenefit(90, 'The rush rewires',
          'The brain\'s response to near-misses and big-win cues measurably calms over months.'),
      JourneyBenefit(180, 'Trust rebuilding',
          'Relationships strained by gambling now have six months of steady evidence.'),
    ],
  ),
  JourneyType(
    slug: 'pornography',
    label: 'Pornography',
    freeLabel: 'Free and present',
    icon: Icons.visibility_off_outlined,
    benefits: [
      JourneyBenefit(7, 'The reset begins',
          'The first week is the steepest — urges are loud, but they pass.'),
      JourneyBenefit(14, 'Sensitivity returning',
          'Everyday pleasures often start registering more strongly.'),
      JourneyBenefit(30, 'Clearer focus',
          'Time and attention reclaimed — the compulsive loop weakens each week.'),
      JourneyBenefit(90, 'Deeper connection',
          'Around three months many people report real-world closeness and confidence improving.'),
    ],
  ),
  JourneyType(
    slug: 'other',
    label: 'My own journey',
    freeLabel: 'Free',
    icon: Icons.spa_outlined,
    benefits: [
      JourneyBenefit(1, 'Day one is the bravest day',
          'Starting is the hardest part, and you\'ve already done it.'),
      JourneyBenefit(7, 'A week of new patterns',
          'Your brain has started writing new routines around old triggers.'),
      JourneyBenefit(30, 'A month of evidence',
          'You now have thirty days of proof that you can do this.'),
      JourneyBenefit(66, 'Habits take root',
          'Research suggests new habits take roughly two months to feel automatic.'),
      JourneyBenefit(90, 'A new baseline',
          'Sleep, mood and focus often feel noticeably steadier by now.'),
    ],
  ),
];

/// Lookup with safe fallback — unknown/empty slugs resolve to 'other' so the
/// healing timeline always has something kind to say.
JourneyType journeyTypeFor(String? slug) => kJourneyTypes.firstWhere(
      (t) => t.slug == slug,
      orElse: () => kJourneyTypes.last,
    );
