import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../theme/app_theme.dart';
import '../components/back_button.dart';
import '../components/glass_card.dart';

// ─── Data models ─────────────────────────────────────────────────────────────

class CrisisLine {
  const CrisisLine({
    required this.name,
    required this.number,
    required this.description,
    required this.hours,
    this.isTextOnly = false,
  });

  final String name;
  final String number;
  final String description;
  final String hours;

  /// True for text/SMS lines where a phone call is not applicable.
  final bool isTextOnly;
}

class CrisisRegion {
  const CrisisRegion({
    required this.label,
    required this.lines,
    this.initiallyExpanded = false,
  });

  final String label;
  final List<CrisisLine> lines;
  final bool initiallyExpanded;
}

// ─── Data ────────────────────────────────────────────────────────────────────

const _regions = <CrisisRegion>[
  CrisisRegion(
    label: 'International / US',
    lines: [
      CrisisLine(
        name: '988 Suicide & Crisis Lifeline',
        number: '988',
        description: 'US mental health & substance use crisis — call or text',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'SAMHSA Helpline',
        number: '1-800-662-4357',
        description: 'Free, confidential substance abuse help',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Crisis Text Line',
        number: 'Text HOME to 741741',
        description: 'Text-based crisis support',
        hours: '24/7',
        isTextOnly: true,
      ),
      CrisisLine(
        name: 'AA General Service',
        number: '1-800-839-1686',
        description: 'Alcoholics Anonymous support',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'SMART Recovery',
        number: '1-440-951-5357',
        description: 'Science-based recovery support',
        hours: 'Business hours',
      ),
    ],
  ),
  CrisisRegion(
    label: 'UK / Ireland',
    lines: [
      CrisisLine(
        name: 'AA United Kingdom',
        number: '0800 9177 650',
        description: 'Alcoholics Anonymous UK',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Drinkline',
        number: '0300 123 1110',
        description: 'National alcohol helpline',
        hours: 'Mon-Fri 9am-8pm',
      ),
      CrisisLine(
        name: 'Samaritans',
        number: '116 123',
        description: 'Emotional support in crisis',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Frank',
        number: '0300 123 6600',
        description: 'Drug and alcohol helpline',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'AA Ireland',
        number: '01 842 0700',
        description: 'Alcoholics Anonymous Ireland',
        hours: 'Office hours',
      ),
    ],
  ),
  CrisisRegion(
    label: 'South Africa',
    initiallyExpanded: true,
    lines: [
      CrisisLine(
        name: 'SADAG Substance Abuse',
        number: '0800 12 13 14',
        description: 'South African Depression and Anxiety Group',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'SADAG SMS Line',
        number: '32312',
        description: 'Text-based support',
        hours: '24/7',
        isTextOnly: true,
      ),
      CrisisLine(
        name: 'AA South Africa',
        number: '0861 435 722',
        description: 'Alcoholics Anonymous SA',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Lifeline South Africa',
        number: '0861 322 322',
        description: 'Crisis counselling',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'FAMSA',
        number: '011 975 7106',
        description: 'Family and Marriage Society of SA',
        hours: 'Office hours',
      ),
      CrisisLine(
        name: 'SANCA',
        number: '011 892 3829',
        description: 'SA National Council on Alcoholism',
        hours: 'Office hours',
      ),
    ],
  ),
  CrisisRegion(
    label: 'Australia',
    lines: [
      CrisisLine(
        name: 'AA Australia',
        number: '1300 22 2222',
        description: 'Alcoholics Anonymous Australia',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Beyond Blue',
        number: '1300 22 4636',
        description: 'Mental health support',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Lifeline Australia',
        number: '13 11 14',
        description: 'Crisis support',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Turning Point',
        number: '1800 888 236',
        description: 'Alcohol and drug treatment',
        hours: 'Business hours',
      ),
      CrisisLine(
        name: 'SMART Recovery AU',
        number: '1300 392 088',
        description: 'Science-based recovery',
        hours: 'Business hours',
      ),
    ],
  ),
  CrisisRegion(
    label: 'Canada',
    lines: [
      CrisisLine(
        name: 'Crisis Services Canada',
        number: '1-833-456-4566',
        description: 'National crisis line',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'CAMH',
        number: '1-800-463-2338',
        description: 'Centre for Addiction and Mental Health',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'AA Canada',
        number: '1-800-268-8833',
        description: 'Alcoholics Anonymous Canada',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'ConnexOntario',
        number: '1-866-531-2600',
        description: 'Mental health and addictions',
        hours: '24/7',
      ),
    ],
  ),
  CrisisRegion(
    label: 'New Zealand',
    lines: [
      CrisisLine(
        name: 'AA New Zealand',
        number: '0800 229 6757',
        description: 'Alcoholics Anonymous NZ',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Lifeline NZ',
        number: '0800 543 354',
        description: 'Crisis support',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Need to Talk',
        number: '1737',
        description: 'Free call or text',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Alcohol Drug Helpline',
        number: '0800 787 797',
        description: 'Alcohol and drug support',
        hours: '24/7',
      ),
    ],
  ),
  CrisisRegion(
    label: 'Europe',
    lines: [
      CrisisLine(
        name: 'Germany — DHS',
        number: '+49 2381 9015-0',
        description: 'Deutsche Hauptstelle fuer Suchtfragen',
        hours: 'Office hours',
      ),
      CrisisLine(
        name: 'France — Ecoute Alcool',
        number: '0 980 980 930',
        description: 'National alcohol helpline',
        hours: '24/7',
      ),
      CrisisLine(
        name: 'Netherlands — Jellinek',
        number: '088 505 1220',
        description: 'Addiction treatment',
        hours: 'Business hours',
      ),
      CrisisLine(
        name: 'Spain — AA Espana',
        number: '91 445 1232',
        description: 'Alcoholics Anonymous Spain',
        hours: 'Office hours',
      ),
    ],
  ),
];

List<String> _buildWithdrawalSymptoms(AppLocalizations l10n) => [
      l10n.crisisWithdrawal0,
      l10n.crisisWithdrawal1,
      l10n.crisisWithdrawal2,
      l10n.crisisWithdrawal3,
      l10n.crisisWithdrawal4,
      l10n.crisisWithdrawal5,
      l10n.crisisWithdrawal6,
    ];

// ─── Screen ──────────────────────────────────────────────────────────────────

class CrisisScreen extends StatefulWidget {
  const CrisisScreen({super.key});

  @override
  State<CrisisScreen> createState() => _CrisisScreenState();
}

class _CrisisScreenState extends State<CrisisScreen> {
  bool _withdrawalExpanded = false;

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _call(String number) async {
    final clean = number.replaceAll(' ', '').replaceAll('-', '');
    final uri = Uri.parse('tel:$clean');
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }

  Future<void> _copy(BuildContext context, String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          AppLocalizations.of(context).commonCopied,
          style: AppTextStyles.bodySmall.copyWith(color: Colors.white),
        ),
        backgroundColor: AppColors.stone700,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.sm,
                  AppSpacing.md,
                  AppSpacing.xxl,
                ),
                children: [
                  _buildEmergencyCallout(),
                  const SizedBox(height: AppSpacing.md),
                  _buildWithdrawalWarning(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSectionHeader(
                      AppLocalizations.of(context).crisisSectionHeader),
                  const SizedBox(height: AppSpacing.sm),
                  ..._regions.map((r) => _buildRegionTile(r)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: AppColors.stone50,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          LuxuryBackButton(
            tooltip: AppLocalizations.of(context).crisisTooltipBack,
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(AppLocalizations.of(context).crisisTitle,
              style: AppTextStyles.titleLarge),
        ],
      ),
    );
  }

  // ── Emergency callout ──────────────────────────────────────────────────────

  Widget _buildEmergencyCallout() {
    return BlushCard(
      borderRadius: AppRadius.xl,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.blush100,
                  borderRadius: AppRadius.sm,
                ),
                child: Icon(
                  Icons.warning_rounded,
                  color: AppColors.blush600,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  AppLocalizations.of(context).crisisEmergencyHeadline,
                  style: AppTextStyles.titleSmall.copyWith(
                    color: AppColors.blush700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              _buildEmergencyButton('911'),
              const SizedBox(width: AppSpacing.xs),
              _buildEmergencyButton('999'),
              const SizedBox(width: AppSpacing.xs),
              _buildEmergencyButton('000'),
              const SizedBox(width: AppSpacing.xs),
              _buildEmergencyButton('112'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmergencyButton(String number) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _call(number),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.blush600,
            borderRadius: AppRadius.pill,
            boxShadow: [
              BoxShadow(
                color: AppColors.blush600.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            number,
            style: AppTextStyles.labelLarge.copyWith(
              color: Colors.white,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  // ── Withdrawal warning ─────────────────────────────────────────────────────

  Widget _buildWithdrawalWarning() {
    return HoneyCard(
      borderRadius: AppRadius.xl,
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () =>
                setState(() => _withdrawalExpanded = !_withdrawalExpanded),
            borderRadius: AppRadius.xl,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.honey100,
                      borderRadius: AppRadius.sm,
                    ),
                    child: Icon(
                      Icons.local_hospital_rounded,
                      color: AppColors.honey600,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context).crisisWithdrawalTitle,
                          style: AppTextStyles.titleSmall.copyWith(
                            color: AppColors.stone800,
                          ),
                        ),
                        if (!_withdrawalExpanded) ...[
                          const SizedBox(height: 2),
                          Text(
                            AppLocalizations.of(context)
                                .crisisWithdrawalTapHint,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.honey600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _withdrawalExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.honey600,
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: _buildWithdrawalExpanded(),
            crossFadeState: _withdrawalExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _buildWithdrawalExpanded() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 1,
            color: AppColors.honey100,
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
          ),
          Text(
            AppLocalizations.of(context).crisisSeekMedical,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.stone600,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          ..._buildWithdrawalSymptoms(AppLocalizations.of(context)).map(
            (symptom) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xs),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3, right: 8),
                    child: Container(
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: AppColors.honey500,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      symptom,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.stone700,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.blush50,
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.blush100),
            ),
            child: Text(
              AppLocalizations.of(context).crisisCallEmergency,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.blush700,
                fontWeight: FontWeight.w600,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Section header ─────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String label) {
    return Text(label, style: AppTextStyles.overline);
  }

  // ── Region tile ────────────────────────────────────────────────────────────

  Widget _buildRegionTile(CrisisRegion region) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.xl,
          border: Border.all(color: AppColors.stone100),
          boxShadow: AppShadows.card,
        ),
        child: ClipRRect(
          borderRadius: AppRadius.xl,
          child: Theme(
            data: Theme.of(context).copyWith(
              dividerColor: Colors.transparent,
            ),
            child: ExpansionTile(
              initiallyExpanded: region.initiallyExpanded,
              tilePadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              childrenPadding: EdgeInsets.zero,
              expandedCrossAxisAlignment: CrossAxisAlignment.start,
              iconColor: AppColors.forest600,
              collapsedIconColor: AppColors.stone400,
              title: Text(
                region.label,
                style: AppTextStyles.titleSmall.copyWith(
                  color: AppColors.stone800,
                ),
              ),
              subtitle: Text(
                AppLocalizations.of(context)
                    .crisisLinesCount(region.lines.length),
                style: AppTextStyles.caption,
              ),
              children: [
                Container(
                  height: 1,
                  color: AppColors.stone100,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                ),
                ...region.lines.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final line = entry.value;
                  return Column(
                    children: [
                      _buildCrisisLineRow(line),
                      if (idx < region.lines.length - 1)
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: AppColors.stone100,
                          indent: AppSpacing.md,
                          endIndent: AppSpacing.md,
                        ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Crisis line row ────────────────────────────────────────────────────────

  Widget _buildCrisisLineRow(CrisisLine line) {
    final bool alwaysOn = line.hours == '24/7';

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.name,
                  style: AppTextStyles.titleSmall,
                ),
                const SizedBox(height: 2),
                Text(
                  line.description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.stone500,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                _buildHoursBadge(line.hours, alwaysOn),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!line.isTextOnly)
                _buildIconAction(
                  icon: Icons.phone_rounded,
                  color: AppColors.forest600,
                  bgColor: AppColors.forest50,
                  onTap: () => _call(line.number),
                  tooltip: AppLocalizations.of(context).crisisTooltipCall,
                ),
              if (!line.isTextOnly) const SizedBox(width: AppSpacing.xs),
              _buildIconAction(
                icon: Icons.copy_rounded,
                color: AppColors.stone600,
                bgColor: AppColors.stone100,
                onTap: () => _copy(context, line.number),
                tooltip: AppLocalizations.of(context).crisisTooltipCopy,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHoursBadge(String hours, bool alwaysOn) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: alwaysOn ? AppColors.forest50 : AppColors.stone100,
        borderRadius: AppRadius.pill,
        border: Border.all(
          color: alwaysOn ? AppColors.forest100 : AppColors.stone200,
        ),
      ),
      child: Text(
        hours,
        style: AppTextStyles.labelSmall.copyWith(
          color: alwaysOn ? AppColors.forest600 : AppColors.stone600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }

  Widget _buildIconAction({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.md,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: AppRadius.md,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 17),
        ),
      ),
    );
  }
}
