import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';

// ─── Group data ───────────────────────────────────────────────────────────────

class _Group {
  const _Group({
    required this.name,
    required this.tagline,
    required this.description,
    required this.approach,
    required this.icon,
    required this.accentColor,
    this.website,
    this.regions,
  });

  final String name;
  final String tagline;
  final String description;
  final String approach;
  final IconData icon;
  final Color accentColor;
  final String? website;
  final String? regions;
}

const _groups = [
  _Group(
    name: 'Alcoholics Anonymous',
    tagline: 'AA',
    description:
        'The original peer-led fellowship. Meetings worldwide — in-person and online. '
        'Based on 12 steps and mutual support. Free and anonymous.',
    approach: '12-step · Peer support · Spiritual',
    icon: Icons.people_outline_rounded,
    accentColor: AppColors.forest600,
    website: 'https://www.aa.org',
    regions: 'Worldwide · South Africa: aa.org.za',
  ),
  _Group(
    name: 'SMART Recovery',
    tagline: 'Self-Management & Recovery Training',
    description:
        'Science-based alternative to 12-step. Uses CBT and motivational techniques. '
        'No spiritual component required. In-person and online meetings globally.',
    approach: 'CBT-based · Evidence-based · Non-spiritual',
    icon: Icons.psychology_outlined,
    accentColor: AppColors.forest700,
    website: 'https://www.smartrecovery.org',
    regions: 'Worldwide · South Africa: smartrecovery.org.za',
  ),
  _Group(
    name: 'Narcotics Anonymous',
    tagline: 'NA',
    description:
        'Peer-led 12-step fellowship for people recovering from drug addiction. '
        'Meetings in most cities and online. Free and welcoming to all.',
    approach: '12-step · Peer support · Drug-focused',
    icon: Icons.group_outlined,
    accentColor: AppColors.forest500,
    website: 'https://www.na.org',
    regions: 'Worldwide',
  ),
  _Group(
    name: 'Refuge Recovery',
    tagline: 'Mindfulness-based recovery',
    description:
        'Uses Buddhist principles and meditation as the foundation for recovery. '
        'No requirement to be Buddhist — the focus is on compassion, mindfulness, '
        'and the causes of suffering.',
    approach: 'Mindfulness · Buddhist-informed · Meditation',
    icon: Icons.self_improvement_outlined,
    accentColor: AppColors.honey600,
    website: 'https://www.refugerecovery.org',
    regions: 'Worldwide · Online',
  ),
  _Group(
    name: 'Celebrate Recovery',
    tagline: 'Faith-based recovery',
    description:
        'A Christ-centred 12-step programme for hurts, habits, and hang-ups. '
        'Runs through local churches. Welcoming to anyone dealing with addiction '
        'or life struggles.',
    approach: '12-step · Christian · Faith-based',
    icon: Icons.favorite_outline_rounded,
    accentColor: AppColors.honey500,
    website: 'https://www.celebraterecovery.com',
    regions: 'Worldwide · Many SA churches',
  ),
  _Group(
    name: 'Women for Sobriety',
    tagline: 'WFS — women-only support',
    description:
        'A programme specifically for women, focusing on building positive '
        'emotions, self-worth, and a new life. Online and in-person meetings.',
    approach: 'Women-only · Positive focus · Empowerment',
    icon: Icons.woman_outlined,
    accentColor: AppColors.blush500,
    website: 'https://www.womenforsobriety.org',
    regions: 'Worldwide · Online',
  ),
  _Group(
    name: 'LifeRing Secular Recovery',
    tagline: 'Non-spiritual peer support',
    description:
        'Secular, non-religious peer support. No steps, no higher power. '
        'Focus on sobriety, secularity, and self-help. Online and in-person.',
    approach: 'Secular · Non-12-step · Self-directed',
    icon: Icons.anchor_outlined,
    accentColor: AppColors.forest400,
    website: 'https://www.lifering.org',
    regions: 'Worldwide · Online',
  ),
  _Group(
    name: 'Online Sobriety Communities',
    tagline: 'Digital support — always available',
    description:
        'Communities like r/stopdrinking, SoberGrid, and Sober.com offer '
        '24/7 peer support, accountability partners, and daily check-ins — '
        'right from your phone.',
    approach: 'Online · Anonymous · 24/7',
    icon: Icons.forum_outlined,
    accentColor: AppColors.stone500,
    website: 'https://www.reddit.com/r/stopdrinking',
    regions: 'Global · Always online',
  ),
];

// ─── Groups Screen ────────────────────────────────────────────────────────────

class GroupsScreen extends StatelessWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop();
                      },
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context).groupsTitle,
                              style: AppTextStyles.titleLarge
                                  .copyWith(color: AppColors.forest700)),
                          Text(AppLocalizations.of(context).groupsSubtitle,
                              style: AppTextStyles.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Intro note ───────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: LuxuryCard(
                  backgroundColor: AppColors.mintChip,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppColors.forest500, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context).groupsIntroNote,
                          style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.forest700, height: 1.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Group cards ──────────────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 48),
              sliver: SliverList.separated(
                itemCount: _groups.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (_, i) => _GroupCard(group: _groups[i]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Group card ───────────────────────────────────────────────────────────────

class _GroupCard extends StatefulWidget {
  const _GroupCard({required this.group});
  final _Group group;

  @override
  State<_GroupCard> createState() => _GroupCardState();
}

class _GroupCardState extends State<_GroupCard> {
  bool _expanded = false;

  Future<void> _openWebsite() async {
    final url = widget.group.website;
    if (url == null) return;
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final g = widget.group;
    return SolidCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: Column(
        children: [

          // Tap header to expand
          InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _expanded = !_expanded);
            },
            borderRadius: _expanded
                ? const BorderRadius.vertical(top: Radius.circular(20))
                : AppRadius.xl,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: g.accentColor.withOpacity(0.1),
                      borderRadius: AppRadius.md,
                    ),
                    child: Icon(g.icon, color: g.accentColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(g.name,
                            style: AppTextStyles.titleSmall),
                        const SizedBox(height: 2),
                        Text(g.tagline,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.stone500)),
                      ],
                    ),
                  ),
                  Icon(
                    _expanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                    color: AppColors.stone300,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),

          // Expanded content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 220),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1, color: AppColors.stone100),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(g.description,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.stone600, height: 1.55)),
                      const SizedBox(height: 12),
                      // Approach chips
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: g.approach.split(' · ').map((tag) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.forest50,
                              borderRadius: AppRadius.pill,
                              border: Border.all(color: AppColors.forest100),
                            ),
                            child: Text(tag,
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.forest600,
                                    letterSpacing: 0.3)),
                          );
                        }).toList(),
                      ),
                      if (g.regions != null) ...[
                        const SizedBox(height: 10),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.stone400),
                          const SizedBox(width: 6),
                          Text(g.regions!,
                              style: AppTextStyles.bodySmall
                                  .copyWith(color: AppColors.stone500)),
                        ]),
                      ],
                      const SizedBox(height: 14),
                      if (g.website != null)
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _openWebsite,
                            icon: const Icon(Icons.open_in_new_rounded,
                                size: 16),
                            label: Text(AppLocalizations.of(context).groupsVisitWebsite),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.forest600,
                              side: const BorderSide(
                                  color: AppColors.forest200),
                              shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadius.lg),
                              minimumSize: const Size.fromHeight(44),
                            ),
                          ),
                        ),
                      const SizedBox(height: 14),
                    ],
                  ),
                ),
              ],
            ),
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
