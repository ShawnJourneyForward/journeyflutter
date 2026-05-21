import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/back_button.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Milestone data ───────────────────────────────────────────────────────────

class _Milestone {
  const _Milestone({
    required this.minutes,
    required this.label,
    required this.title,
    required this.body,
    required this.icon,
    required this.system,
    required this.mind,
    required this.experience,
    required this.tip,
  });
  final int minutes; // elapsed minutes required to achieve this
  final String label;
  final String title;
  final String body;
  final IconData icon;
  final String system;
  final String mind;
  final String experience;
  final String tip;
}

// This timeline is educational and reflects general recovery patterns only.
// Individual recovery varies. Journey Forward is not a medical device.
List<_Milestone> _buildTimeline(AppLocalizations l10n) => [
      _Milestone(
        minutes: 720,
        label: l10n.recoveryM1Label,
        title: l10n.recoveryM1Title,
        body: l10n.recoveryM1Body,
        icon: Icons.water_drop_outlined,
        system: l10n.recoveryM1System,
        mind:
            'You might feel a mix of relief and anxiety as your daily routine shifts. This is the normal friction of change.',
        experience:
            'The first urges may appear. They can feel urgent, but they are temporary waves.',
        tip:
            'Drink a large glass of water. When an urge hits, focus only on getting through the next hour.',
      ),
      _Milestone(
        minutes: 1440,
        label: l10n.recoveryM2Label,
        title: l10n.recoveryM2Title,
        body: l10n.recoveryM2Body,
        icon: Icons.favorite_outline_rounded,
        system: l10n.recoveryM2System,
        mind:
            'Your brain\'s reward circuitry is noticing the absence of its usual chemical trigger, which can cause irritability or a low mood.',
        experience:
            'You may feel emotionally raw, tired, or slightly restless.',
        tip:
            'Sleep and rest are your best allies right now. Keep your evening routine calm, quiet, and consistent.',
      ),
      _Milestone(
        minutes: 2880,
        label: l10n.recoveryM3Label,
        title: l10n.recoveryM3Title,
        body: l10n.recoveryM3Body,
        icon: Icons.self_improvement_outlined,
        system: l10n.recoveryM3System,
        mind:
            'Your system is seeking balance. The intensity you feel right now is the feeling of that adjustment taking place.',
        experience:
            'Restlessness and strong urges are common here. You might feel “wired” or on edge.',
        tip:
            'Be exceptionally gentle with yourself today. If you experience shaking, confusion, hallucinations, seizures, severe agitation, or feel unsafe, seek urgent medical support.',
      ),
      _Milestone(
        minutes: 4320,
        label: l10n.recoveryM4Label,
        title: l10n.recoveryM4Title,
        body: l10n.recoveryM4Body,
        icon: Icons.spa_outlined,
        system: l10n.recoveryM4System,
        mind:
            'The mental fog often begins to thin. Neurotransmitter production starts to slowly adjust, paving the way for more natural energy.',
        experience:
            'A small window of calm may emerge. You might feel a quiet, cautious optimism taking root.',
        tip:
            'Reaching 72 hours is meaningful. Mark it with comfort, care, and support.',
      ),
      _Milestone(
        minutes: 10080,
        label: l10n.recoveryM5Label,
        title: l10n.recoveryM5Title,
        body: l10n.recoveryM5Body,
        icon: Icons.bedtime_outlined,
        system: l10n.recoveryM5System,
        mind:
            'You may notice unusually vivid dreams — this can be a sign that your brain is adjusting to the deep neurological rest it has been missing.',
        experience:
            'Improved clarity, though your mood may still naturally swing up and down.',
        tip:
            'Anchor yourself in routine. A predictable morning and evening structure is a powerful tool right now.',
      ),
      _Milestone(
        minutes: 20160,
        label: l10n.recoveryM6Label,
        title: l10n.recoveryM6Title,
        body: l10n.recoveryM6Body,
        icon: Icons.directions_run_outlined,
        system: l10n.recoveryM6System,
        mind:
            'Concentration and short-term memory begin to sharpen. You are actively building new, healthier neural pathways.',
        experience:
            'You might start feeling surprisingly well, though random moments of emptiness are still normal.',
        tip:
            'This is when overconfidence can sneak in. Stay connected to your daily practices and support systems.',
      ),
      _Milestone(
        minutes: 43200,
        label: l10n.recoveryM7Label,
        title: l10n.recoveryM7Title,
        body: l10n.recoveryM7Body,
        icon: Icons.healing_outlined,
        system: l10n.recoveryM7System,
        mind:
            'The brain systems involved in impulse control, decision-making, and emotional regulation may begin to feel steadier over time.',
        experience:
            'Emotional regulation continues to improve, and building resilience becomes a steady practice.',
        tip:
            'Review your journey so far. Note the situations that still feel tricky, and plan how you will navigate them gracefully.',
      ),
      _Milestone(
        minutes: 129600,
        label: l10n.recoveryM8Label,
        title: l10n.recoveryM8Title,
        body: l10n.recoveryM8Body,
        icon: Icons.psychology_outlined,
        system: l10n.recoveryM8System,
        mind:
            'Dopamine pathways are gradually adjusting. The ability to find genuine satisfaction in simple, everyday activities may begin to return.',
        experience:
            'Many people describe feeling more like themselves again. Motivation may feel more available, though it can still rise and fall.',
        tip:
            'Continue to cultivate your environment. Hobbies, nature, and relationships are deeply protective elements of your growth.',
      ),
      _Milestone(
        minutes: 259200,
        label: l10n.recoveryM9Label,
        title: l10n.recoveryM9Title,
        body: l10n.recoveryM9Body,
        icon: Icons.shield_outlined,
        system: l10n.recoveryM9System,
        mind: 'Urges may become less frequent or easier to move through.',
        experience:
            'The highs and lows of early recovery begin to smooth out into a more consistent rhythm.',
        tip:
            'Take a moment to honor the quiet days. Peace and stability are among the quiet rewards of this process.',
      ),
      _Milestone(
        minutes: 525960,
        label: l10n.recoveryM10Label,
        title: l10n.recoveryM10Title,
        body: l10n.recoveryM10Body,
        icon: Icons.favorite_rounded,
        system: l10n.recoveryM10System,
        mind:
            'You have lived through many seasons, routines, and emotional moments with more awareness and care.',
        experience:
            'Support may still matter, and needing it does not diminish your progress.',
        tip:
            'Reflect on the person you were twelve months ago. Write them a letter from where you stand today.',
      ),
      _Milestone(
        minutes: 1051920,
        label: l10n.recoveryM11Label,
        title: l10n.recoveryM11Title,
        body: l10n.recoveryM11Body,
        icon: Icons.star_outline_rounded,
        system: l10n.recoveryM11System,
        mind:
            'Recovery may feel less like something you are forcing and more like a way of living you have grown into.',
        experience: '',
        tip:
            'Your story may become a source of comfort for someone else. When the moment feels right, share your strength with someone just beginning their path.',
      ),
    ];

// ─── Recovery Screen ──────────────────────────────────────────────────────────

class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final timeline = _buildTimeline(l10n);
    // soberDaysProvider only ticks at midnight; the recovery timeline never
    // changes mid-second, so the 1-second tick of soberStatsProvider would
    // just rebuild the whole CustomScrollView for nothing (visible jitter).
    final stats = ref.watch(soberDaysProvider);
    final elapsedMinutes = stats?.elapsed.inMinutes.clamp(0, 99999999) ?? 0;
    final achievedCount =
        timeline.where((m) => elapsedMinutes >= m.minutes).length;

    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Header ──────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(8, 12, 20, 0),
                child: Row(
                  children: [
                    const LuxuryBackButton(),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(l10n.recoveryTitle,
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: AppColors.forest700)),
                          Text(l10n.recoverySubtitle,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Hero stats card ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: _HeroCard(
                  days: stats?.days ?? 0,
                  achievedCount: achievedCount,
                  total: timeline.length,
                ),
              ),
            ),

            // ── Medical disclaimer ───────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.honey50,
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: AppColors.honey200),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          size: 16, color: AppColors.honey600),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Journey Forward is not a medical device and does not diagnose, treat, cure, or prevent any medical condition. '
                          'This timeline is educational and reflects general recovery patterns only. '
                          'Individual recovery varies. If you drink heavily, have a history of withdrawal, seizures, hallucinations, confusion, '
                          'or feel physically unsafe, speak with a healthcare professional before stopping suddenly or seek urgent medical care.',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.honey600,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Timeline ─────────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 28, 20, 48),
              sliver: SliverList.builder(
                itemCount: timeline.length,
                itemBuilder: (_, i) {
                  final m = timeline[i];
                  final achieved = elapsedMinutes >= m.minutes;
                  final isCurrent = achieved &&
                      (i == timeline.length - 1 ||
                          elapsedMinutes < timeline[i + 1].minutes);
                  return _TimelineTile(
                    milestone: m,
                    achieved: achieved,
                    isCurrent: isCurrent,
                    isLast: i == timeline.length - 1,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Hero card ─────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({
    required this.days,
    required this.achievedCount,
    required this.total,
  });
  final int days;
  final int achievedCount;
  final int total;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final pct = (achievedCount / total * 100).round();
    return LuxuryCard(
      backgroundColor: AppColors.forest800,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.recoveryHeroLabel,
                    style: AppTextStyles.overline
                        .copyWith(color: AppColors.forest300, fontSize: 10)),
                const SizedBox(height: 8),
                Text(l10n.recoveryDaysSober(days),
                    style: AppTextStyles.displaySmall
                        .copyWith(color: Colors.white, fontSize: 26)),
                const SizedBox(height: 6),
                Text(l10n.recoveryMilestonesReached(achievedCount, total),
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.forest200)),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: AppRadius.pill,
                  child: LinearProgressIndicator(
                    value: achievedCount / total,
                    minHeight: 5,
                    backgroundColor: AppColors.forest700,
                    color: AppColors.honey400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: AppColors.forest700,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.forest600),
            ),
            child: Center(
              child: Text('$pct%',
                  style: AppTextStyles.titleMedium
                      .copyWith(color: AppColors.honey300)),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Timeline tile ─────────────────────────────────────────────────────────────

class _TimelineTile extends StatefulWidget {
  const _TimelineTile({
    required this.milestone,
    required this.achieved,
    required this.isCurrent,
    required this.isLast,
  });
  final _Milestone milestone;
  final bool achieved;
  final bool isCurrent;
  final bool isLast;

  @override
  State<_TimelineTile> createState() => _TimelineTileState();
}

class _TimelineTileState extends State<_TimelineTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.isCurrent; // current milestone starts open
  }

  @override
  Widget build(BuildContext context) {
    final m = widget.milestone;
    final achieved = widget.achieved;
    final isCurrent = widget.isCurrent;

    final nodeColor = achieved
        ? (isCurrent ? AppColors.honey100 : AppColors.forest50)
        : Colors.white;
    final nodeBorder = achieved
        ? (isCurrent ? AppColors.honey300 : AppColors.forest200)
        : AppColors.stone100;
    final iconColor = achieved
        ? (isCurrent ? AppColors.honey600 : AppColors.forest500)
        : AppColors.stone300;
    final labelBg = achieved
        ? (isCurrent ? AppColors.honey50 : AppColors.forest50)
        : AppColors.stone50;
    final labelBorder = achieved
        ? (isCurrent ? AppColors.honey200 : AppColors.forest100)
        : AppColors.stone100;
    final labelText = achieved
        ? (isCurrent ? AppColors.honey600 : AppColors.forest600)
        : AppColors.stone400;
    final titleColor = achieved ? AppColors.stone800 : AppColors.stone400;
    final lineColor =
        achieved && !isCurrent ? AppColors.forest200 : AppColors.stone100;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Left: node + connector ──────────────────────────────────────
          SizedBox(
            width: 52,
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: nodeColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: nodeBorder, width: isCurrent ? 2.0 : 1.0),
                    boxShadow: isCurrent
                        ? [
                            BoxShadow(
                              color: AppColors.honey400.withOpacity(0.28),
                              blurRadius: 14,
                              spreadRadius: 0,
                            )
                          ]
                        : null,
                  ),
                  child: Icon(m.icon, size: 18, color: iconColor),
                ),
                if (!widget.isLast)
                  Expanded(
                    child: Container(width: 2, color: lineColor),
                  ),
              ],
            ),
          ),

          // ── Right: content ───────────────────────────────────────────────
          Expanded(
            child: GestureDetector(
              onTap: () {
                H.selection();
                setState(() => _expanded = !_expanded);
              },
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),

                    // Label chip
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: labelBg,
                        borderRadius: AppRadius.pill,
                        border: Border.all(color: labelBorder),
                      ),
                      child: Text(m.label,
                          style: AppTextStyles.labelSmall
                              .copyWith(color: labelText, letterSpacing: 0.6)),
                    ),

                    const SizedBox(height: 6),

                    // Title row
                    Row(
                      children: [
                        Expanded(
                          child: Text(m.title,
                              style: AppTextStyles.titleSmall
                                  .copyWith(color: titleColor)),
                        ),
                        if (achieved)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Icon(
                              isCurrent
                                  ? Icons.radio_button_checked_rounded
                                  : Icons.check_circle_rounded,
                              size: 16,
                              color: isCurrent
                                  ? AppColors.honey500
                                  : AppColors.forest400,
                            ),
                          ),
                        if (!achieved && !_expanded)
                          const Icon(Icons.expand_more_rounded,
                              size: 16, color: AppColors.stone300),
                        if (!achieved && _expanded)
                          const Icon(Icons.expand_less_rounded,
                              size: 16, color: AppColors.stone300),
                      ],
                    ),

                    // Body — collapsible
                    AnimatedCrossFade(
                      duration: const Duration(milliseconds: 220),
                      crossFadeState: _expanded
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      firstChild: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Body
                            Text(m.body,
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.stone600, height: 1.6)),
                            const SizedBox(height: 6),
                            Text(m.system.toUpperCase(),
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: achieved
                                        ? AppColors.forest400
                                        : AppColors.stone300,
                                    letterSpacing: 0.8)),

                            // Mind section
                            const SizedBox(height: 14),
                            Row(children: [
                              Icon(Icons.psychology_outlined,
                                  size: 13,
                                  color: achieved
                                      ? AppColors.forest500
                                      : AppColors.stone300),
                              const SizedBox(width: 5),
                              Text('MIND',
                                  style: AppTextStyles.labelSmall.copyWith(
                                      color: achieved
                                          ? AppColors.forest500
                                          : AppColors.stone300,
                                      letterSpacing: 0.8)),
                            ]),
                            const SizedBox(height: 5),
                            Text(m.mind,
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.stone600, height: 1.6)),
                            if (m.experience.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Text(m.experience,
                                  style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.stone500,
                                      height: 1.5,
                                      fontStyle: FontStyle.italic)),
                            ],

                            // Tip box
                            const SizedBox(height: 14),
                            Container(
                              padding:
                                  const EdgeInsets.fromLTRB(12, 10, 12, 10),
                              decoration: BoxDecoration(
                                color: isCurrent
                                    ? AppColors.honey50
                                    : AppColors.stone50,
                                borderRadius: AppRadius.md,
                                border: Border.all(
                                    color: isCurrent
                                        ? AppColors.honey200
                                        : AppColors.stone100),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.lightbulb_outline_rounded,
                                      size: 15,
                                      color: isCurrent
                                          ? AppColors.honey600
                                          : AppColors.stone400),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(m.tip,
                                        style: AppTextStyles.bodySmall.copyWith(
                                            color: isCurrent
                                                ? AppColors.honey600
                                                : AppColors.stone500,
                                            height: 1.5)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),

                    const SizedBox(height: 2),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
