// Shared metadata for the Vision Board feature: the icon palette and the
// per-category presentation. Extracted so the detail screen and the journal
// screen can both depend on it without a circular import.

import 'package:flutter/material.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

// ─── Icon palette ────────────────────────────────────────────────────────────
// 20 icons that mirror the Journey Forward Vision Icons SVG design system.
// `key` is the stable identifier persisted to JSON; never rename a key.

class VisionIconOption {
  const VisionIconOption({
    required this.key,
    required this.icon,
    required this.label,
    required this.color,
  });
  final String key;
  final IconData icon;
  final String label;
  final Color color;
}

const kVisionIcons = <VisionIconOption>[
  VisionIconOption(
      key: 'guide',
      icon: Icons.auto_awesome_rounded,
      label: 'Guide',
      color: AppColors.honey400),
  VisionIconOption(
      key: 'strength',
      icon: Icons.fitness_center_rounded,
      label: 'Strength',
      color: AppColors.forest500),
  VisionIconOption(
      key: 'love',
      icon: Icons.spa_rounded,
      label: 'Love',
      color: Color(0xFFD97272)),
  VisionIconOption(
      key: 'home',
      icon: Icons.home_rounded,
      label: 'Home',
      color: AppColors.forest600),
  VisionIconOption(
      key: 'family',
      icon: Icons.group_rounded,
      label: 'Family',
      color: AppColors.forest500),
  VisionIconOption(
      key: 'savings',
      icon: Icons.account_balance_wallet_rounded,
      label: 'Savings',
      color: AppColors.honey500),
  VisionIconOption(
      key: 'learn',
      icon: Icons.school_rounded,
      label: 'Learn',
      color: AppColors.forest600),
  VisionIconOption(
      key: 'growth',
      icon: Icons.eco_rounded,
      label: 'Growth',
      color: AppColors.forest500),
  VisionIconOption(
      key: 'journey',
      icon: Icons.explore_rounded,
      label: 'Journey',
      color: AppColors.forest600),
  VisionIconOption(
      key: 'create',
      icon: Icons.palette_rounded,
      label: 'Create',
      color: AppColors.honey400),
  VisionIconOption(
      key: 'move',
      icon: Icons.directions_run_rounded,
      label: 'Move',
      color: AppColors.forest500),
  VisionIconOption(
      key: 'stillness',
      icon: Icons.self_improvement_rounded,
      label: 'Stillness',
      color: AppColors.forest400),
  VisionIconOption(
      key: 'wisdom',
      icon: Icons.menu_book_rounded,
      label: 'Wisdom',
      color: AppColors.honey500),
  VisionIconOption(
      key: 'aim',
      icon: Icons.my_location_rounded,
      label: 'Aim',
      color: AppColors.forest600),
  VisionIconOption(
      key: 'hope',
      icon: Icons.wb_twilight_rounded,
      label: 'Hope',
      color: AppColors.honey400),
  VisionIconOption(
      key: 'peace',
      icon: Icons.spa_rounded,
      label: 'Peace',
      color: AppColors.forest400),
  VisionIconOption(
      key: 'support',
      icon: Icons.handshake_rounded,
      label: 'Support',
      color: AppColors.forest500),
  VisionIconOption(
      key: 'bloom',
      icon: Icons.local_florist_rounded,
      label: 'Bloom',
      color: AppColors.honey400),
  VisionIconOption(
      key: 'milestone',
      icon: Icons.emoji_events_rounded,
      label: 'Milestone',
      color: AppColors.honey500),
  VisionIconOption(
      key: 'spark',
      icon: Icons.local_fire_department_rounded,
      label: 'Spark',
      color: AppColors.honey400),
];

VisionIconOption visionOptionFor(String key) => kVisionIcons
    .firstWhere((o) => o.key == key, orElse: () => kVisionIcons.first);

/// Effective accent — per-card override wins, otherwise fall back to the icon's
/// natural colour. Keeps cards looking coherent even before a user customises.
Color visionAccent(VisionItem item) => item.accentColor != null
    ? Color(item.accentColor!)
    : visionOptionFor(item.emoji).color;

// ─── Category metadata ───────────────────────────────────────────────────────

class VisionCategoryInfo {
  const VisionCategoryInfo({
    required this.category,
    required this.label,
    required this.icon,
    required this.color,
  });
  final VisionCategory category;
  final String label;
  final IconData icon;
  final Color color;
}

const kCategoryInfo = <VisionCategoryInfo>[
  VisionCategoryInfo(
      category: VisionCategory.health,
      label: 'Health',
      icon: Icons.favorite_outline_rounded,
      color: AppColors.forest500),
  VisionCategoryInfo(
      category: VisionCategory.family,
      label: 'Family',
      icon: Icons.group_rounded,
      color: AppColors.forest600),
  VisionCategoryInfo(
      category: VisionCategory.career,
      label: 'Career',
      icon: Icons.work_outline_rounded,
      color: AppColors.honey500),
  VisionCategoryInfo(
      category: VisionCategory.growth,
      label: 'Growth',
      icon: Icons.eco_rounded,
      color: AppColors.forest500),
  VisionCategoryInfo(
      category: VisionCategory.freedom,
      label: 'Freedom',
      icon: Icons.air_rounded,
      color: AppColors.forest400),
  VisionCategoryInfo(
      category: VisionCategory.adventure,
      label: 'Adventure',
      icon: Icons.terrain_rounded,
      color: AppColors.honey400),
  VisionCategoryInfo(
      category: VisionCategory.service,
      label: 'Service',
      icon: Icons.volunteer_activism_rounded,
      color: AppColors.forest500),
  VisionCategoryInfo(
      category: VisionCategory.creativity,
      label: 'Creativity',
      icon: Icons.palette_rounded,
      color: AppColors.honey500),
  VisionCategoryInfo(
      category: VisionCategory.none,
      label: 'Uncategorised',
      icon: Icons.bookmark_outline_rounded,
      color: AppColors.stone400),
];

VisionCategoryInfo categoryInfoFor(VisionCategory c) => kCategoryInfo
    .firstWhere((i) => i.category == c, orElse: () => kCategoryInfo.last);

// ─── Starter prompts for the empty state ─────────────────────────────────────

class VisionStarter {
  const VisionStarter({
    required this.title,
    required this.iconKey,
    required this.category,
    this.affirmation = '',
  });
  final String title;
  final String iconKey;
  final VisionCategory category;
  final String affirmation;
}

const kStarterPrompts = <VisionStarter>[
  VisionStarter(
    title: 'One year of freedom',
    iconKey: 'milestone',
    category: VisionCategory.freedom,
    affirmation: 'I am building a life I love, one sober day at a time.',
  ),
  VisionStarter(
    title: 'Be the parent I want to be',
    iconKey: 'family',
    category: VisionCategory.family,
    affirmation:
        'I am present, patient, and proud of how I show up for my family.',
  ),
  VisionStarter(
    title: 'Run a 5K',
    iconKey: 'move',
    category: VisionCategory.health,
    affirmation:
        'I am strong, I move with purpose, and my body is reclaiming itself.',
  ),
  VisionStarter(
    title: 'Save for something meaningful',
    iconKey: 'savings',
    category: VisionCategory.freedom,
    affirmation:
        'Every day sober is money in my pocket and possibility in my future.',
  ),
  VisionStarter(
    title: 'Learn a new skill',
    iconKey: 'learn',
    category: VisionCategory.growth,
    affirmation: 'I am curious, I am capable, and I keep growing.',
  ),
  VisionStarter(
    title: 'Heal a relationship',
    iconKey: 'support',
    category: VisionCategory.family,
    affirmation:
        'I lead with honesty and humility. The right people are coming closer.',
  ),
];

// ─── Affirmation auto-suggest ────────────────────────────────────────────────
// Light-touch template engine: turns a goal title into a present-tense
// "I am…" reframe. Not magic — just a useful starting point the user edits.

String suggestAffirmationForTitle(String title) {
  final t = title.trim();
  if (t.isEmpty) return 'I am becoming the person I want to be.';
  final lower = t.toLowerCase();

  // Common verb-led patterns. Order matters — first match wins.
  if (lower.startsWith('be more ') || lower.startsWith('be ')) {
    final what = t.replaceFirst(RegExp(r'^[Bb]e( more)?\s+'), '');
    return 'I am $what.';
  }
  if (lower.startsWith('stop ') || lower.startsWith('quit ')) {
    final what =
        t.replaceFirst(RegExp(r'^(stop|quit)\s+', caseSensitive: false), '');
    return 'I am free from $what.';
  }
  if (lower.startsWith('learn ')) {
    final what = t.substring(6);
    return 'I am learning $what, and I get better every day.';
  }
  if (lower.startsWith('save ') || lower.startsWith('save for ')) {
    return 'I am building financial freedom with every sober day.';
  }
  if (lower.startsWith('run ') ||
      lower.startsWith('walk ') ||
      lower.startsWith('move ')) {
    return 'I am strong, and my body carries me forward.';
  }
  if (lower.startsWith('write ') ||
      lower.startsWith('create ') ||
      lower.startsWith('build ')) {
    final what = t.replaceFirst(
        RegExp(r'^(write|create|build)\s+', caseSensitive: false), '');
    return 'I am creating $what — one focused step at a time.';
  }
  if (lower.contains('family') ||
      lower.contains('kid') ||
      lower.contains('child')) {
    return 'I am present and patient with the people I love.';
  }
  if (lower.contains('sober') ||
      lower.contains('clean') ||
      lower.contains('freedom')) {
    return 'I am free, and every day strengthens that freedom.';
  }

  // Fallback: lower-case and use it as the predicate.
  return 'I am working toward $t — and I trust the process.';
}
