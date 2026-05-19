import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

// Timelines are drawn from population-level research. Individual experience
// varies — recovery pathways differ and some people, especially those with
// heavy or long-term use, should seek medical guidance during early withdrawal.
List<_Milestone> _buildTimeline(AppLocalizations l10n) => [
  _Milestone(
    minutes: 20,
    label: l10n.recoveryM1Label,
    title: l10n.recoveryM1Title,
    body: l10n.recoveryM1Body,
    icon: Icons.favorite_outline_rounded,
    system: l10n.recoveryM1System,
    mind: 'The first urges and self-doubt begin here. Your mind may question the decision — that voice is the addiction talking, not you.',
    experience: 'You may feel restless, irritable, or on edge.',
    tip: 'Focus on the next hour only. Tell someone you trust what you\'re doing right now.',
  ),
  _Milestone(
    minutes: 720,
    label: l10n.recoveryM2Label,
    title: l10n.recoveryM2Title,
    body: l10n.recoveryM2Body,
    icon: Icons.air_outlined,
    system: l10n.recoveryM2System,
    mind: 'Anxiety and mood dips are common as your brain adjusts to absence of the substance. This is normal neurochemistry shifting, not weakness.',
    experience: 'Cravings may peak and feel overwhelming. They typically last only 3–5 minutes before subsiding.',
    tip: 'Ride the wave — cravings always pass. Try box breathing or drink a cold glass of water slowly.',
  ),
  _Milestone(
    minutes: 1440,
    label: l10n.recoveryM3Label,
    title: l10n.recoveryM3Title,
    body: l10n.recoveryM3Body,
    icon: Icons.monitor_heart_outlined,
    system: l10n.recoveryM3System,
    mind: 'Your brain\'s reward circuitry is recalibrating. Dopamine levels are fluctuating, which causes the irritability and low mood you may be feeling.',
    experience: 'You may feel emotionally raw, tired, or have difficulty concentrating.',
    tip: 'Sleep is your best ally tonight. Avoid caffeine after 2pm and keep your bedtime routine consistent.',
  ),
  _Milestone(
    minutes: 2880,
    label: l10n.recoveryM4Label,
    title: l10n.recoveryM4Title,
    body: l10n.recoveryM4Body,
    icon: Icons.self_improvement_outlined,
    system: l10n.recoveryM4System,
    mind: 'Peak withdrawal for many substances occurs around 48 hours. Your nervous system is working hard to rebalance. This intensity is temporary.',
    experience: 'Anxiety, restlessness, and strong cravings are at their most intense now. For alcohol, this is the highest-risk window.',
    tip: 'If you\'ve been a heavy or long-term user, please have someone check on you. Medical support is wise at this stage.',
  ),
  _Milestone(
    minutes: 4320,
    label: l10n.recoveryM5Label,
    title: l10n.recoveryM5Title,
    body: l10n.recoveryM5Body,
    icon: Icons.spa_outlined,
    system: l10n.recoveryM5System,
    mind: 'The acute phase begins to lift. Your brain is starting to normalise neurotransmitter production. The worst is typically behind you now.',
    experience: 'A small window of calm may emerge. Many people feel a quiet, cautious optimism at this point.',
    tip: 'Celebrate 72 hours — it\'s a real physiological milestone. Do something genuinely kind for yourself today.',
  ),
  _Milestone(
    minutes: 10080,
    label: l10n.recoveryM6Label,
    title: l10n.recoveryM6Title,
    body: l10n.recoveryM6Body,
    icon: Icons.bedtime_outlined,
    system: l10n.recoveryM6System,
    mind: 'Post-acute withdrawal symptoms (PAWS) may begin — mood swings, disrupted sleep, and cravings in waves. This phase is normal and can last weeks to months.',
    experience: 'Improved clarity alongside bouts of emptiness or unexpected craving is common at this stage.',
    tip: 'Establish a daily routine. Structure is one of the most powerful relapse-prevention tools available to you.',
  ),
  _Milestone(
    minutes: 20160,
    label: l10n.recoveryM7Label,
    title: l10n.recoveryM7Title,
    body: l10n.recoveryM7Body,
    icon: Icons.directions_run_outlined,
    system: l10n.recoveryM7System,
    mind: 'Brain fog starts to lift noticeably. Concentration and memory improve as neurochemistry stabilises. You are building new neural pathways every single day.',
    experience: 'Energy levels begin to return. Some people feel surprisingly well; others still experience mood dips — both are normal.',
    tip: 'This is when overconfidence can sneak in. Stay connected to your support system even — especially — when you feel strong.',
  ),
  _Milestone(
    minutes: 43200,
    label: l10n.recoveryM8Label,
    title: l10n.recoveryM8Title,
    body: l10n.recoveryM8Body,
    icon: Icons.healing_outlined,
    system: l10n.recoveryM8System,
    mind: 'One month is a turning point. The brain\'s prefrontal cortex — governing decision-making and impulse control — shows measurable early recovery.',
    experience: 'Most physical symptoms have resolved. Emotional regulation is improving, though stress can still trigger cravings.',
    tip: 'Review your triggers. Write down three high-risk situations and your specific plan for each one.',
  ),
  _Milestone(
    minutes: 129600,
    label: l10n.recoveryM9Label,
    title: l10n.recoveryM9Title,
    body: l10n.recoveryM9Body,
    icon: Icons.psychology_outlined,
    system: l10n.recoveryM9System,
    mind: 'The 90-day mark is clinically significant. Research suggests the brain\'s dopamine system has substantially stabilised for many people, and relapse risk tends to drop meaningfully at this point.',
    experience: 'Many people report feeling more like themselves again. Sleep, mood, and motivation are often notably improved.',
    tip: 'Build your recovery capital — relationships, hobbies, purpose. These are as protective as any clinical treatment.',
  ),
  _Milestone(
    minutes: 259200,
    label: l10n.recoveryM10Label,
    title: l10n.recoveryM10Title,
    body: l10n.recoveryM10Body,
    icon: Icons.shield_outlined,
    system: l10n.recoveryM10System,
    mind: 'Research suggests deep neurological repair continues at six months. White matter density and cognitive function tend to improve — though the pace and extent varies by individual.',
    experience: 'Cravings are often less frequent and shorter in duration. Emotional resilience tends to grow and life may feel more manageable.',
    tip: 'Milestones can paradoxically trigger complacency. Reaffirm your "why" today and write it somewhere visible.',
  ),
  _Milestone(
    minutes: 525960,
    label: l10n.recoveryM11Label,
    title: l10n.recoveryM11Title,
    body: l10n.recoveryM11Body,
    icon: Icons.favorite_rounded,
    system: l10n.recoveryM11System,
    mind: 'One year is a landmark. Research points to meaningful structural changes in the brain — improved prefrontal regulation, stress response, and memory consolidation — though individual recovery pathways vary.',
    experience: 'Most people describe a new baseline of wellbeing — not euphoria, but genuine stability and earned self-trust.',
    tip: 'Reflect on who you were 12 months ago. Write yourself a letter from where you stand now.',
  ),
  _Milestone(
    minutes: 1051920,
    label: l10n.recoveryM12Label,
    title: l10n.recoveryM12Title,
    body: l10n.recoveryM12Body,
    icon: Icons.trending_down_rounded,
    system: l10n.recoveryM12System,
    mind: 'At two years, reward pathways continue to stabilise. Cue-induced cravings often become markedly weaker as conditioned responses fade — though ongoing care and connection remain important.',
    experience: 'Triggers that once felt overwhelming may now feel manageable or even irrelevant.',
    tip: 'Mentor someone earlier in their recovery. Giving back is one of the most powerful ways to consolidate your own.',
  ),
  _Milestone(
    minutes: 2629800,
    label: l10n.recoveryM13Label,
    title: l10n.recoveryM13Title,
    body: l10n.recoveryM13Body,
    icon: Icons.star_outline_rounded,
    system: l10n.recoveryM13System,
    mind: 'Five years is associated with a substantial reduction in lifetime relapse risk. Neuroplasticity continues, enabling stable patterns of thought and behaviour to deepen across every area of life.',
    experience: 'Many describe this period as among the richest of their lives — purpose-driven, deeply connected, and genuinely free.',
    tip: 'Your story is medicine for someone still suffering. Consider sharing it when the moment is right.',
  ),
  _Milestone(
    minutes: 5259600,
    label: l10n.recoveryM14Label,
    title: l10n.recoveryM14Title,
    body: l10n.recoveryM14Body,
    icon: Icons.emoji_events_outlined,
    system: l10n.recoveryM14System,
    mind: 'Decade-long recovery is associated with profound neurological healing in research. The brain\'s capacity to restore and rebuild is remarkable — and your commitment has made the most of it.',
    experience: 'Recovery is no longer something you do — it has become who you are.',
    tip: 'You have shown that people can change profoundly and completely. Live that truth fully, every day.',
  ),
];

// ─── Recovery Screen ──────────────────────────────────────────────────────────

class RecoveryScreen extends ConsumerWidget {
  const RecoveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final timeline = _buildTimeline(l10n);
    final stats = ref.watch(soberStatsProvider);
    final elapsedMinutes = stats?.elapsed.inMinutes.clamp(0, 99999999) ?? 0;
    final achievedCount = timeline.where((m) => elapsedMinutes >= m.minutes).length;

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
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded,
                          size: 20, color: AppColors.stone700),
                      onPressed: () {
                        H.light();
                        Navigator.of(context).pop();
                      },
                    ),
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
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
                          'Timelines are drawn from population-level research. '
                          'Individual recovery varies — if you have concerns about '
                          'withdrawal or your health, please speak with a medical professional.',
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
                            const SizedBox(height: 6),
                            Text(m.experience,
                                style: AppTextStyles.bodyMedium.copyWith(
                                    color: AppColors.stone500,
                                    height: 1.5,
                                    fontStyle: FontStyle.italic)),

                            // Tip box
                            const SizedBox(height: 14),
                            Container(
                              padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
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
