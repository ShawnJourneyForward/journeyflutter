import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import '../utils/voice_input.dart';
import '../providers/app_providers.dart';
import '../l10n/app_localizations.dart';
import 'vision_board_shared.dart';
import 'vision_detail_screen.dart';
import 'journal_shared.dart';
import 'journal_detail_screen.dart';
import 'journal_template_screen.dart';

// ─── Zen quotes ───────────────────────────────────────────────────────────────

List<(String, String)> _buildZenQuotes(AppLocalizations l10n) => [
      (l10n.zenQuote0, l10n.zenQuoteAuthor0),
      (l10n.zenQuote1, l10n.zenQuoteAuthor1),
      (l10n.zenQuote2, l10n.zenQuoteAuthor2),
      (l10n.zenQuote3, l10n.zenQuoteAuthor3),
      (l10n.zenQuote4, l10n.zenQuoteAuthor4),
      (l10n.zenQuote5, l10n.zenQuoteAuthor5),
      (l10n.zenQuote6, l10n.zenQuoteAuthor6),
      (l10n.zenQuote7, l10n.zenQuoteAuthor7),
      (l10n.zenQuote8, l10n.zenQuoteAuthor8),
      (l10n.zenQuote9, l10n.zenQuoteAuthor9),
      (l10n.zenQuote10, l10n.zenQuoteAuthor10),
      (l10n.zenQuote11, l10n.zenQuoteAuthor11),
      (l10n.zenQuote12, l10n.zenQuoteAuthor12),
      (l10n.zenQuote13, l10n.zenQuoteAuthor13),
      (l10n.zenQuote14, l10n.zenQuoteAuthor14),
      (l10n.zenQuote15, l10n.zenQuoteAuthor15),
      (l10n.zenQuote16, l10n.zenQuoteAuthor16),
      (l10n.zenQuote17, l10n.zenQuoteAuthor17),
      (l10n.zenQuote18, l10n.zenQuoteAuthor18),
      (l10n.zenQuote19, l10n.zenQuoteAuthor19),
      (l10n.zenQuote20, l10n.zenQuoteAuthor20),
      (l10n.zenQuote21, l10n.zenQuoteAuthor21),
      (l10n.zenQuote22, l10n.zenQuoteAuthor22),
      (l10n.zenQuote23, l10n.zenQuoteAuthor23),
      (l10n.zenQuote24, l10n.zenQuoteAuthor24),
      (l10n.zenQuote25, l10n.zenQuoteAuthor25),
      (l10n.zenQuote26, l10n.zenQuoteAuthor26),
      (l10n.zenQuote27, l10n.zenQuoteAuthor27),
      (l10n.zenQuote28, l10n.zenQuoteAuthor28),
      (l10n.zenQuote29, l10n.zenQuoteAuthor29),
    ];

List<String> _buildDefaultAffirmations(AppLocalizations l10n) => [
      l10n.journalAffirm0,
      l10n.journalAffirm1,
      l10n.journalAffirm2,
      l10n.journalAffirm3,
      l10n.journalAffirm4,
      l10n.journalAffirm5,
      l10n.journalAffirm6,
      l10n.journalAffirm7,
      l10n.journalAffirm8,
      l10n.journalAffirm9,
      l10n.journalAffirm10,
      l10n.journalAffirm11,
      l10n.journalAffirm12,
      l10n.journalAffirm13,
      l10n.journalAffirm14,
    ];

// Vision Board icon palette + category metadata live in vision_board_shared.dart
// so the detail screen can share them without a circular import.

// ─── Journal screen ───────────────────────────────────────────────────────────

class JournalScreen extends ConsumerStatefulWidget {
  const JournalScreen({super.key});

  @override
  ConsumerState<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends ConsumerState<JournalScreen>
    with SingleTickerProviderStateMixin {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = [
      l10n.journalTabJournal,
      l10n.journalTabAffirm,
      l10n.journalTabVision,
      l10n.journalTabZen
    ];
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _Header(
                  tab: _tab,
                  tabs: tabs,
                  onTabChanged: (i) => setState(() => _tab = i),
                ),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 240),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.04, 0),
                          end: Offset.zero,
                        ).animate(anim),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_tab),
                      child: switch (_tab) {
                        0 => const _JournalTab(),
                        1 => const _AffirmTab(),
                        2 => const _VisionTab(),
                        3 => const _ZenTab(),
                        _ => const SizedBox.shrink(),
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header with pill tab bar ─────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({
    required this.tab,
    required this.tabs,
    required this.onTabChanged,
  });
  final int tab;
  final List<String> tabs;
  final ValueChanged<int> onTabChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.journalTitle, style: AppTextStyles.greetingSerif),
          const SizedBox(height: 14),
          Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.full,
              border: Border.all(color: AppColors.softBorder),
            ),
            child: Row(
              children: List.generate(tabs.length, (i) {
                final selected = i == tab;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTabChanged(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color:
                            selected ? AppColors.mintChip : Colors.transparent,
                        borderRadius: AppRadius.full,
                        boxShadow: selected ? AppShadows.card : null,
                      ),
                      child: Center(
                        child: Text(
                          tabs[i],
                          style: AppTextStyles.labelMedium.copyWith(
                            color: selected
                                ? AppColors.forest700
                                : AppColors.stone400,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 0 — Journal
// ─────────────────────────────────────────────────────────────────────────────

class _JournalTab extends ConsumerWidget {
  const _JournalTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final entries = ref.watch(journalProvider);

    return entries.when(
      loading: () => Center(
          child: CircularProgressIndicator(color: AppColors.forest600)),
      error: (e, _) => Center(child: Text(l10n.homeErrorPrefix(e.toString()))),
      data: (allEntries) {
        final filtered = ref.watch(filteredJournalProvider);
        final streak = ref.watch(journalStreakProvider);
        final echoes = ref.watch(onThisDayProvider);
        final filter = ref.watch(journalFilterProvider);
        final hasAny = allEntries.isNotEmpty;
        // Quick-mood pill only shows on days where the user hasn't written
        // anything yet — once they've checked in, the pill disappears.
        final now = DateTime.now();
        final hasEntryToday = allEntries.any((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day);

        return Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ── Streak + on-this-day peek (only when there's data) ──
                if (hasAny)
                  SliverToBoxAdapter(
                    child: _DiaryHeader(
                      streak: streak,
                      echoes: echoes,
                      onEchoTap: (entry) => _openDetail(context, ref, entry),
                    ),
                  ),

                // ── Quick mood check-in (only when no entry yet today) ──
                if (hasAny && !hasEntryToday)
                  SliverToBoxAdapter(
                    child: _QuickMoodPill(
                      onPick: (moodKey) async {
                        H.medium();
                        await ref.read(journalProvider.notifier).add(
                              '', // empty body — user can add words later
                              moodKey,
                            );
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                l10n.journalMoodLoggedSnack,
                                style: AppTextStyles.bodySmall
                                    .copyWith(color: Colors.white)),
                            backgroundColor: AppColors.forest700,
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ),

                // ── Filter chips + search (only when there's data) ─────
                if (hasAny)
                  SliverToBoxAdapter(
                    child: _DiaryFilterBar(
                      filter: filter,
                      counts: _countsFor(allEntries),
                      onModeChanged: (m) {
                        H.selection();
                        ref.read(journalFilterProvider.notifier).state =
                            filter.copyWith(mode: m);
                      },
                      onQueryChanged: (q) {
                        ref.read(journalFilterProvider.notifier).state =
                            filter.copyWith(query: q);
                      },
                      onClearTag: filter.tag == null
                          ? null
                          : () {
                              ref.read(journalFilterProvider.notifier).state =
                                  filter.copyWith(tag: null);
                            },
                    ),
                  ),

                // ── Empty state ─────────────────────────────────────────
                if (!hasAny)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _DiaryEmptyState(
                      onSeed: (prompt) =>
                          _showEntrySheet(context, ref, prompt: prompt),
                      onBlank: () => _showEntrySheet(context, ref),
                    ),
                  )
                else if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(40),
                      child: _EmptyState(
                        icon: Icons.filter_alt_off_outlined,
                        title: l10n.journalFilterEmptyTitle,
                        subtitle: l10n.journalFilterEmptySubtitle,
                      ),
                    ),
                  )
                else
                  () {
                    // Group entries into date buckets and flatten into a list
                    // of headers + entries. Done inline so the SliverList
                    // builder stays a simple list lookup.
                    final items = _bucketEntries(filtered, l10n);
                    return SliverPadding(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 110),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (_, i) {
                            final item = items[i];
                            if (item is String) {
                              return _DateBucketHeader(label: item);
                            }
                            final entry = item as JournalEntry;
                            return _JournalCard(
                              entry: entry,
                              onTap: () => _openDetail(context, ref, entry),
                              onTagTap: (tag) {
                                H.selection();
                                ref.read(journalFilterProvider.notifier).state =
                                    filter.copyWith(tag: tag);
                              },
                            );
                          },
                          childCount: items.length,
                        ),
                      ),
                    );
                  }(),
              ],
            ),

            // FAB
            Positioned(
              right: 20,
              bottom: 24,
              child: _FAB(onTap: () => _chooseEntryKind(context, ref)),
            ),
          ],
        );
      },
    );
  }

  // ── Counts shown next to filter chips ─────────────────────────────────
  Map<JournalFilterMode, int> _countsFor(List<JournalEntry> all) {
    final now = DateTime.now();
    final todayKey = DateTime(now.year, now.month, now.day);
    var today = 0, hard = 0, wins = 0, locked = 0;
    for (final e in all) {
      final d = DateTime(e.date.year, e.date.month, e.date.day);
      if (d == todayKey) today++;
      if (e.mood == 'hard' || e.mood == 'crisis') hard++;
      if (e.mood == 'great' || e.mood == 'good') wins++;
      if (e.locked) locked++;
    }
    return {
      JournalFilterMode.all: all.length,
      JournalFilterMode.today: today,
      JournalFilterMode.hard: hard,
      JournalFilterMode.wins: wins,
      JournalFilterMode.locked: locked,
    };
  }

  // ── Open detail (gated by re-auth if locked) ──────────────────────────
  Future<void> _openDetail(
      BuildContext context, WidgetRef ref, JournalEntry entry) async {
    H.selection();
    if (entry.locked) {
      final ok = await JournalReauth.require(context,
          reason: AppLocalizations.of(context).journalReauthViewEntry);
      if (!ok || !context.mounted) return;
    }
    if (!context.mounted) return;
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => JournalDetailScreen(
        entryId: entry.id,
        onEdit: (live) => _showEntrySheet(context, ref, existing: live),
      ),
    ));
  }

  // ── Open the entry sheet for add / edit / prompt-seeded ───────────────
  void _showEntrySheet(
    BuildContext context,
    WidgetRef ref, {
    JournalEntry? existing,
    JournalPrompt? prompt,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JournalEntrySheet(
        existing: existing,
        seedPrompt: prompt,
        onSave: ({
          required String text,
          required String mood,
          String? subMood,
          required List<String> tags,
          String? promptId,
          required bool locked,
        }) async {
          if (existing == null) {
            await ref.read(journalProvider.notifier).add(
                  text,
                  mood,
                  subMood: subMood,
                  tags: tags,
                  promptId: promptId,
                  locked: locked,
                );
          } else {
            await ref.read(journalProvider.notifier).editEntry(
                  existing.id,
                  text: text,
                  mood: mood,
                  subMood: subMood,
                  tags: tags,
                  locked: locked,
                );
          }
          // Crisis routing: only on fresh entries (not edits) so we don't
          // re-prompt the same calm path when the user just fixes a typo.
          if (existing == null && context.mounted) {
            _maybeOfferCrisisPath(context, mood);
          }
        },
      ),
    );
  }

  // ── FAB chooser: blank page vs guided daily reflection ───────────────
  // Two paths into the diary so the page-paralysis user has a structured
  // option while the journaller-by-habit can still hit a blank page fast.
  void _chooseEntryKind(BuildContext context, WidgetRef ref) {
    H.medium();
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 14),
                    decoration: BoxDecoration(
                      color: AppColors.stone200,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Text(l10n.journalNewEntryTitle,
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.forest700)),
                const SizedBox(height: 4),
                Text(l10n.journalNewEntrySubtitle,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone500)),
                const SizedBox(height: 18),
                _EntryKindCard(
                  icon: Icons.edit_note_rounded,
                  tint: AppColors.mintChip,
                  border: AppColors.forest100,
                  accent: AppColors.forest600,
                  title: l10n.journalPlainEntryTitle,
                  subtitle: l10n.journalPlainEntrySubtitle,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    _showEntrySheet(context, ref);
                  },
                ),
                const SizedBox(height: 12),
                _EntryKindCard(
                  icon: Icons.auto_stories_rounded,
                  tint: AppColors.honey50,
                  border: AppColors.honey100,
                  accent: AppColors.honey600,
                  title: l10n.journalDailyReflectionTitle,
                  subtitle: l10n.journalDailyReflectionSubtitle,
                  badge: l10n.journalBadgeNew,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => const JournalTemplateScreen(),
                    ));
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── After a fresh entry, route hard/crisis moods to existing support ──
  void _maybeOfferCrisisPath(BuildContext context, String mood) {
    if (mood != 'hard' && mood != 'crisis') return;
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: AppColors.stone200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                mood == 'crisis'
                    ? l10n.journalCrisisTitleCrisis
                    : l10n.journalCrisisTitleHard,
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.forest700),
              ),
              const SizedBox(height: 6),
              Text(
                mood == 'crisis'
                    ? l10n.journalCrisisBodyCrisis
                    : l10n.journalCrisisBodyHard,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone600),
              ),
              const SizedBox(height: 18),
              if (mood == 'crisis')
                _CrisisAction(
                  icon: Icons.self_improvement_rounded,
                  label: l10n.journalCrisisCalmRoomLabel,
                  detail: l10n.journalCrisisCalmRoomDetail,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/emergency');
                  },
                )
              else
                _CrisisAction(
                  icon: Icons.psychology_outlined,
                  label: l10n.journalCrisisThoughtRecordLabel,
                  detail: l10n.journalCrisisThoughtRecordDetail,
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go('/cbt');
                  },
                ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(
                    l10n.journalCrisisDismiss,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.stone500),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Date bucketing for the diary list ──────────────────────────────────────
//
// Returns a flat list where String items are section headers and
// JournalEntry items are the cards under that header. Buckets:
//   - Today        (current calendar day)
//   - Yesterday    (day - 1)
//   - This week    (last 7 days, excluding today/yesterday)
//   - Last week    (8-14 days ago)
//   - Earlier this month
//   - Month + Year for everything older
//
// Designed to be cheap — a single linear pass.

List<Object> _bucketEntries(List<JournalEntry> entries, AppLocalizations l10n) {
  if (entries.isEmpty) return const [];
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = today.subtract(const Duration(days: 1));
  final sevenAgo = today.subtract(const Duration(days: 7));
  final fourteenAgo = today.subtract(const Duration(days: 14));

  String bucketFor(DateTime d) {
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return l10n.historyToday;
    if (day == yesterday) return l10n.historyYesterday;
    if (day.isAfter(sevenAgo)) return l10n.journalBucketThisWeek;
    if (day.isAfter(fourteenAgo)) return l10n.journalBucketLastWeek;
    if (d.year == now.year && d.month == now.month) {
      return l10n.journalBucketEarlierThisMonth;
    }
    return DateFormat('MMMM y').format(d);
  }

  final out = <Object>[];
  String? lastBucket;
  for (final e in entries) {
    final b = bucketFor(e.date);
    if (b != lastBucket) {
      out.add(b);
      lastBucket = b;
    }
    out.add(e);
  }
  return out;
}

class _DateBucketHeader extends StatelessWidget {
  const _DateBucketHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 12, 2, 8),
      child: Text(
        label.toUpperCase(),
        style: AppTextStyles.overline.copyWith(
          color: AppColors.stone500,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ─── Crisis bottom-sheet action row ──────────────────────────────────────────

class _CrisisAction extends StatelessWidget {
  const _CrisisAction({
    required this.icon,
    required this.label,
    required this.detail,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final String detail;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.lg,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.forest50,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.forest100),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.forest100,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: AppColors.forest700),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.forest700)),
                  const SizedBox(height: 2),
                  Text(detail,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone500)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_rounded,
                size: 18, color: AppColors.forest500),
          ],
        ),
      ),
    );
  }
}

// ─── Header: streak ribbon + on-this-day peek ────────────────────────────────

class _DiaryHeader extends StatelessWidget {
  const _DiaryHeader({
    required this.streak,
    required this.echoes,
    required this.onEchoTap,
  });
  final int streak;
  final List<JournalEntry> echoes;
  final void Function(JournalEntry) onEchoTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final hasEcho = echoes.isNotEmpty;
    if (streak == 0 && !hasEcho) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (streak > 0)
            Row(
              children: [
                Icon(Icons.local_fire_department_rounded,
                    size: 16, color: AppColors.honey500),
                const SizedBox(width: 6),
                Text(
                  l10n.journalWritingStreak(streak),
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.forest700),
                ),
              ],
            ),
          if (hasEcho) ...[
            const SizedBox(height: 10),
            _OnThisDayCard(echoes: echoes, onTap: onEchoTap),
          ],
        ],
      ),
    );
  }
}

// ─── Quick mood pill ─────────────────────────────────────────────────────────
//
// One-tap mood logging for days where typing feels like too much. Disappears
// the moment any entry exists for today — including the very entry created
// by tapping one of these emojis. So the surface area stays tiny and
// non-nagging.

class _QuickMoodPill extends StatelessWidget {
  const _QuickMoodPill({required this.onPick});
  final void Function(String moodKey) onPick;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 14),
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.md,
          border: Border.all(color: AppColors.softBorder),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l10n.journalQuickMoodPrompt,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.stone600),
              ),
            ),
            ...kMoodOptions.map((m) => GestureDetector(
                  onTap: () => onPick(m.key),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.stone50,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.stone100),
                      ),
                      child:
                          Text(m.emoji, style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}

class _OnThisDayCard extends StatelessWidget {
  const _OnThisDayCard({required this.echoes, required this.onTap});
  final List<JournalEntry> echoes;
  final void Function(JournalEntry) onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final first = echoes.first;
    final years = DateTime.now().year - first.date.year;
    final mood = moodFor(first.mood);
    return InkWell(
      borderRadius: AppRadius.lg,
      onTap: () => onTap(first),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.mintChip, AppColors.forest50],
          ),
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.forest100),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: mood.color.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.history_rounded,
                  size: 18, color: AppColors.forest600),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.journalOnThisDay(years),
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.forest700),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    first.locked
                        ? l10n.journalEchoLockedEntry
                        : first.text.trim().isEmpty
                            ? l10n.journalEchoMoodCheckIn
                            : first.text,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.stone600,
                      fontStyle: (first.locked || first.text.trim().isEmpty)
                          ? FontStyle.italic
                          : FontStyle.normal,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (echoes.length > 1) ...[
                    const SizedBox(height: 4),
                    Text(
                      l10n.journalEchoMore(echoes.length - 1),
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone400),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Filter chip row + search field ──────────────────────────────────────────

class _DiaryFilterBar extends StatefulWidget {
  const _DiaryFilterBar({
    required this.filter,
    required this.counts,
    required this.onModeChanged,
    required this.onQueryChanged,
    required this.onClearTag,
  });
  final JournalFilter filter;
  final Map<JournalFilterMode, int> counts;
  final void Function(JournalFilterMode) onModeChanged;
  final void Function(String) onQueryChanged;
  final VoidCallback? onClearTag;

  @override
  State<_DiaryFilterBar> createState() => _DiaryFilterBarState();
}

class _DiaryFilterBarState extends State<_DiaryFilterBar> {
  late final TextEditingController _searchCtrl;
  bool _searchOpen = false;

  @override
  void initState() {
    super.initState();
    _searchCtrl = TextEditingController(text: widget.filter.query);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _chip(JournalFilterMode.all, l10n.journalFilterAll),
                      const SizedBox(width: 6),
                      _chip(JournalFilterMode.today, l10n.journalFilterToday),
                      const SizedBox(width: 6),
                      _chip(JournalFilterMode.hard, l10n.journalFilterHard),
                      const SizedBox(width: 6),
                      _chip(JournalFilterMode.wins, l10n.journalFilterWins),
                      const SizedBox(width: 6),
                      _chip(JournalFilterMode.locked, l10n.journalFilterLocked),
                    ],
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  _searchOpen ? Icons.close_rounded : Icons.search_rounded,
                  size: 20,
                  color: AppColors.stone600,
                ),
                onPressed: () {
                  setState(() {
                    _searchOpen = !_searchOpen;
                    if (!_searchOpen && _searchCtrl.text.isNotEmpty) {
                      _searchCtrl.clear();
                      widget.onQueryChanged('');
                    }
                  });
                },
              ),
            ],
          ),
          if (_searchOpen) ...[
            const SizedBox(height: 8),
            TextField(
              controller: _searchCtrl,
              autofocus: true,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
              decoration: InputDecoration(
                hintText: l10n.journalSearchHint,
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone300),
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: AppColors.stone400),
                filled: true,
                fillColor: AppColors.card,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: AppRadius.md,
                  borderSide: BorderSide(color: AppColors.stone100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.md,
                  borderSide: BorderSide(color: AppColors.stone100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.md,
                  borderSide:
                      BorderSide(color: AppColors.forest400, width: 1.5),
                ),
              ),
              onChanged: widget.onQueryChanged,
            ),
          ],
          if (widget.filter.tag != null) ...[
            const SizedBox(height: 8),
            InputChip(
              label: Text('#${widget.filter.tag!}'),
              labelStyle:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.forest700),
              backgroundColor: AppColors.mintChip,
              side: BorderSide(color: AppColors.forest100),
              deleteIconColor: AppColors.forest500,
              onDeleted: widget.onClearTag,
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(JournalFilterMode mode, String label) {
    final selected = widget.filter.mode == mode;
    final count = widget.counts[mode] ?? 0;
    return GestureDetector(
      onTap: () => widget.onModeChanged(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? AppColors.forest600 : AppColors.card,
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: selected ? AppColors.forest600 : AppColors.stone200,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label,
                style: AppTextStyles.labelMedium.copyWith(
                    color: selected ? Colors.white : AppColors.stone600)),
            if (count > 0) ...[
              const SizedBox(width: 5),
              Text('$count',
                  style: AppTextStyles.labelSmall.copyWith(
                      // ignore: deprecated_member_use
                      color: selected
                          // ignore: deprecated_member_use
                          ? Colors.white.withOpacity(0.7)
                          : AppColors.stone400)),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Empty state with three starter prompts ──────────────────────────────────

class _DiaryEmptyState extends StatelessWidget {
  const _DiaryEmptyState({required this.onSeed, required this.onBlank});
  final void Function(JournalPrompt) onSeed;
  final VoidCallback onBlank;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final starters = starterPromptsForEmptyState();
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.forest50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.menu_book_rounded,
                  size: 34, color: AppColors.forest500),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              l10n.journalEmptyTitle,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.forest700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              l10n.journalEmptySubtitle,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 22),
          ...starters.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: InkWell(
                  borderRadius: AppRadius.lg,
                  onTap: () {
                    H.selection();
                    onSeed(p);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: AppRadius.lg,
                      border: Border.all(color: AppColors.stone100),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.format_quote_rounded,
                            size: 18, color: AppColors.forest400),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            p.text,
                            style: AppTextStyles.bodyMedium.copyWith(
                              color: AppColors.stone700,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_forward_rounded,
                            size: 16, color: AppColors.stone400),
                      ],
                    ),
                  ),
                ),
              )),
          const SizedBox(height: 6),
          Center(
            child: TextButton.icon(
              onPressed: onBlank,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(l10n.journalBlankPageButton),
              style: TextButton.styleFrom(foregroundColor: AppColors.forest600),
            ),
          ),
        ],
      ),
    );
  }
}

class _JournalCard extends ConsumerWidget {
  const _JournalCard({
    required this.entry,
    required this.onTap,
    required this.onTagTap,
  });
  final JournalEntry entry;
  final VoidCallback onTap;
  final void Function(String tag) onTagTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final mood = moodFor(entry.mood);

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.honeySoft,
          borderRadius: AppRadius.lg,
        ),
        child:
            Icon(Icons.delete_outline_rounded, color: AppColors.honey500),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.journalDeleteEntryTitle,
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.stone800)),
            content: Text(l10n.journalDeleteEntryBody,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone500)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.commonCancel,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.stone500)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.commonDelete,
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.honey500)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => ref.read(journalProvider.notifier).delete(entry.id),
      child: InkWell(
        borderRadius: AppRadius.xxl,
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppRadius.xxl,
            border: Border.all(color: AppColors.softBorder),
            boxShadow: AppShadows.luxury,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Mood + sub-mood + lock + date ───────────────────────
              Row(
                children: [
                  Icon(mood.icon, size: 18, color: mood.color),
                  const SizedBox(width: 6),
                  Text(mood.label,
                      style:
                          AppTextStyles.labelSmall.copyWith(color: mood.color)),
                  if (entry.subMood != null && entry.subMood!.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Container(
                      width: 3,
                      height: 3,
                      decoration: BoxDecoration(
                        color: AppColors.stone300,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        entry.subMood!,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  if (entry.locked) ...[
                    const SizedBox(width: 8),
                    Icon(Icons.lock, size: 12, color: AppColors.honey500),
                  ],
                  const Spacer(),
                  Text(
                    _formatDate(entry.date, l10n),
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone400),
                  ),
                ],
              ),

              // ── Body preview (hidden if locked) ─────────────────────
              const SizedBox(height: 10),
              if (entry.locked)
                Row(
                  children: [
                    Icon(Icons.lock_outline,
                        size: 14, color: AppColors.stone400),
                    const SizedBox(width: 6),
                    Text(
                      l10n.journalCardLockedHint,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.stone500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
              else if (entry.text.trim().isEmpty)
                // Quick-mood entry (no body). Make the empty state explicit
                // so the card doesn't look broken or accidentally blank.
                Row(
                  children: [
                    Icon(Icons.edit_note_rounded,
                        size: 14, color: AppColors.stone400),
                    const SizedBox(width: 6),
                    Text(
                      l10n.journalCardMoodCheckInHint,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.stone500,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                )
              else
                Text(
                  entry.text,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone700),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),

              // ── Tag chips ───────────────────────────────────────────
              if (entry.tags.isNotEmpty) ...[
                const SizedBox(height: 12),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: entry.tags.map((t) {
                    return GestureDetector(
                      onTap: () => onTagTap(t),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.forest50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.forest100),
                        ),
                        child: Text(
                          '#$t',
                          style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.forest600, letterSpacing: 0.2),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime dt, AppLocalizations l10n) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return l10n.journalCardDateToday(DateFormat('h:mm a').format(dt));
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return l10n.historyYesterday;
    }
    return DateFormat('MMM d').format(dt);
  }
}

/// Callback shape the entry sheet uses to hand back its work. The named
/// args mirror the persisted fields one-to-one so the parent doesn't have
/// to remember positional argument order.
typedef JournalSaveCallback = Future<void> Function({
  required String text,
  required String mood,
  String? subMood,
  required List<String> tags,
  String? promptId,
  required bool locked,
});

class _JournalEntrySheet extends ConsumerStatefulWidget {
  const _JournalEntrySheet({
    required this.onSave,
    this.existing,
    this.seedPrompt,
  });
  final JournalSaveCallback onSave;
  final JournalEntry? existing; // edit mode
  final JournalPrompt? seedPrompt; // empty-state starter

  @override
  ConsumerState<_JournalEntrySheet> createState() => _JournalEntrySheetState();
}

class _JournalEntrySheetState extends ConsumerState<_JournalEntrySheet> {
  late final TextEditingController _ctrl;
  late final TextEditingController _newTagCtrl;
  late String _mood;
  late String? _subMood;
  late List<String> _tags;
  late bool _locked;
  String? _promptId; // null until user picks a prompt or seedPrompt set
  bool _listening = false;
  String _baseline = '';
  bool _promptPickerOpen = false;

  // ── Draft autosave state ───────────────────────────────────────────────
  // Only fresh entries autosave drafts. Editing an existing entry is its own
  // protected flow — we don't want a half-finished edit to silently overwrite
  // the original on next open.
  JournalDraft? _availableDraft; // populated after async lookup on init
  bool _draftDismissed = false; // user tapped Discard
  bool _draftRestored = false; // user tapped Restore
  Timer? _autosaveDebounce;

  bool get _isEdit => widget.existing != null;
  bool get _shouldAutosave => !_isEdit;

  @override
  void initState() {
    super.initState();
    final ex = widget.existing;
    final seed = widget.seedPrompt;
    _ctrl = TextEditingController(text: ex?.text ?? '');
    _newTagCtrl = TextEditingController();
    _mood = ex?.mood ?? 'okay';
    _subMood = ex?.subMood;
    _tags = List<String>.from(ex?.tags ?? const []);
    _locked = ex?.locked ?? false;
    _promptId = ex?.promptId ?? seed?.id;
    // If we were opened from a starter prompt, drop a soft header into the
    // text field so the user sees what they're answering.
    if (seed != null && _ctrl.text.isEmpty) {
      _ctrl.text = '${seed.text}\n\n';
      _ctrl.selection =
          TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
    }

    // Wire autosave only for fresh entries — debounced 1.2s after the last
    // keystroke so we don't hammer disk on every character.
    if (_shouldAutosave) {
      _ctrl.addListener(_scheduleAutosave);
      // After first frame, look up any prior draft and offer to restore it.
      WidgetsBinding.instance.addPostFrameCallback((_) => _loadDraft());
    }
  }

  Future<void> _loadDraft() async {
    // Skip if we opened with a starter prompt or already typing — the user's
    // current intent wins over a stale draft.
    if (widget.seedPrompt != null) return;
    if (_ctrl.text.trim().isNotEmpty) return;
    final draft = await JournalDraftStore.read();
    if (!mounted || draft == null) return;
    setState(() => _availableDraft = draft);
  }

  void _restoreDraft() {
    final d = _availableDraft;
    if (d == null) return;
    setState(() {
      _ctrl.text = d.text;
      _ctrl.selection =
          TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
      _mood = d.mood;
      _subMood = d.subMood;
      _tags = List<String>.from(d.tags);
      _locked = d.locked;
      _promptId = d.promptId;
      _draftRestored = true;
      _availableDraft = null;
    });
    H.medium();
  }

  Future<void> _discardDraft() async {
    await JournalDraftStore.clear();
    if (!mounted) return;
    setState(() {
      _availableDraft = null;
      _draftDismissed = true;
    });
    H.selection();
  }

  void _scheduleAutosave() {
    if (!_shouldAutosave) return;
    _autosaveDebounce?.cancel();
    _autosaveDebounce =
        Timer(const Duration(milliseconds: 1200), _flushAutosave);
  }

  Future<void> _flushAutosave() async {
    if (!_shouldAutosave) return;
    final text = _ctrl.text;
    // Don't save empty drafts — they just leave a stale prompt behind.
    if (text.trim().isEmpty) {
      await JournalDraftStore.clear();
      return;
    }
    await JournalDraftStore.write(JournalDraft(
      text: text,
      mood: _mood,
      subMood: _subMood,
      tags: List.unmodifiable(_tags),
      promptId: _promptId,
      locked: _locked,
      savedAt: DateTime.now(),
    ));
  }

  @override
  void dispose() {
    _autosaveDebounce?.cancel();
    // One final flush — covers the case where the user swipes the sheet down
    // less than 1.2s after their last keystroke.
    if (_shouldAutosave) _flushAutosave();
    if (_listening) VoiceInput.instance.cancel();
    _ctrl.dispose();
    _newTagCtrl.dispose();
    super.dispose();
  }

  Future<void> _toggleListening() async {
    if (_listening) {
      await VoiceInput.instance.stop();
      if (mounted) setState(() => _listening = false);
      return;
    }
    final ok = await VoiceInput.instance.init();
    if (!ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            AppLocalizations.of(context).journalVoiceUnavailable,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.stone600,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    H.medium();
    _baseline = _ctrl.text;
    if (_baseline.isNotEmpty && !_baseline.endsWith(' ')) _baseline += ' ';
    setState(() => _listening = true);
    await VoiceInput.instance.start(
      onResult: (text, isFinal) {
        if (!mounted) return;
        _ctrl.text = '$_baseline$text';
        _ctrl.selection =
            TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
        if (isFinal) {
          setState(() => _listening = false);
        }
      },
      listenFor: const Duration(minutes: 2),
      pauseFor: const Duration(seconds: 4),
    );
  }

  // ── Sub-mood selection ─────────────────────────────────────────────────
  void _toggleSubMood(String value) {
    H.selection();
    setState(() {
      _subMood = (_subMood == value) ? null : value;
    });
    _scheduleAutosave();
  }

  // ── Tag handling ───────────────────────────────────────────────────────
  void _toggleTag(String tag) {
    H.selection();
    setState(() {
      if (_tags.contains(tag)) {
        _tags.remove(tag);
      } else {
        _tags.add(tag);
      }
    });
    _scheduleAutosave();
  }

  void _addNewTag() {
    final t = _newTagCtrl.text.trim().toLowerCase().replaceAll('#', '');
    if (t.isEmpty) return;
    if (!_tags.contains(t)) {
      setState(() => _tags.add(t));
      _scheduleAutosave();
    }
    _newTagCtrl.clear();
    H.selection();
  }

  void _pickPrompt(JournalPrompt p) {
    setState(() {
      _promptId = p.id;
      _promptPickerOpen = false;
      // Soft-prepend to the text field so the user sees what they're answering.
      if (_ctrl.text.trim().isEmpty) {
        _ctrl.text = '${p.text}\n\n';
        _ctrl.selection =
            TextSelection.fromPosition(TextPosition(offset: _ctrl.text.length));
      }
    });
    H.selection();
  }

  void _save() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    // Drop sub-mood if it no longer applies to the chosen primary mood
    // (user could have toggled great → okay after picking a sub-mood).
    final allowedSub = subMoodsFor(_mood);
    final finalSub = (allowedSub == null ||
            _subMood == null ||
            !allowedSub.contains(_subMood))
        ? null
        : _subMood;
    widget.onSave(
      text: text,
      mood: _mood,
      subMood: finalSub,
      tags: List.unmodifiable(_tags),
      promptId: _promptId,
      locked: _locked,
    );
    // A successful save retires the draft — it has a permanent home now.
    if (_shouldAutosave) {
      _autosaveDebounce?.cancel();
      JournalDraftStore.clear();
    }
    Navigator.pop(context);
    H.medium();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final usedTags = ref.watch(allJournalTagsProvider);
    final suggestedTags = <String>{
      ..._tags, // current selection always visible
      ...usedTags.take(8),
      ...kSuggestedTags,
    }.toList();
    final subVocab = subMoodsFor(_mood);

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.90,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ─────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 4),
            child: Row(
              children: [
                Text(
                  _isEdit ? l10n.journalEditEntryTitle : l10n.journalTodaysEntryTitle,
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.forest700),
                ),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close_rounded,
                      color: AppColors.stone400),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // ── Scrollable body ────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 12 + bottom),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Draft restore banner (fresh entries only) ──────────
                  if (_availableDraft != null &&
                      !_draftDismissed &&
                      !_draftRestored)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _DraftRestoreBanner(
                        draft: _availableDraft!,
                        onRestore: _restoreDraft,
                        onDiscard: _discardDraft,
                      ),
                    ),

                  // ── Prompt strip ───────────────────────────────────────
                  _buildPromptStrip(),

                  const SizedBox(height: 14),

                  // ── Primary mood ───────────────────────────────────────
                  Text(l10n.journalMoodQuestion,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.stone500)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: kMoodOptions.map((m) {
                      final selected = _mood == m.key;
                      return GestureDetector(
                        onTap: () {
                          H.selection();
                          setState(() {
                            _mood = m.key;
                            // Reset sub-mood if no longer relevant.
                            if (subMoodsFor(_mood) == null) _subMood = null;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected
                                // ignore: deprecated_member_use
                                ? m.color.withOpacity(0.12)
                                : Colors.transparent,
                            borderRadius: AppRadius.md,
                            border: Border.all(
                              color: selected
                                  // ignore: deprecated_member_use
                                  ? m.color.withOpacity(0.4)
                                  : AppColors.stone100,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(m.emoji,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(height: 2),
                              Text(m.label,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color:
                                        selected ? m.color : AppColors.stone400,
                                  )),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  // ── Sub-mood slide-in (only when relevant) ─────────────
                  AnimatedSize(
                    duration: const Duration(milliseconds: 180),
                    curve: Curves.easeOut,
                    child: subVocab == null
                        ? const SizedBox.shrink()
                        : Padding(
                            padding: const EdgeInsets.only(top: 14),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _mood == 'great'
                                      ? l10n.journalSubMoodSpecific
                                      : l10n.journalSubMoodUnderneath,
                                  style: AppTextStyles.labelMedium
                                      .copyWith(color: AppColors.stone500),
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: subVocab.map((s) {
                                    final selected = _subMood == s;
                                    return GestureDetector(
                                      onTap: () => _toggleSubMood(s),
                                      child: AnimatedContainer(
                                        duration:
                                            const Duration(milliseconds: 120),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 11, vertical: 5),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? AppColors.forest600
                                              : AppColors.stone50,
                                          borderRadius:
                                              BorderRadius.circular(20),
                                          border: Border.all(
                                            color: selected
                                                ? AppColors.forest600
                                                : AppColors.stone200,
                                          ),
                                        ),
                                        child: Text(
                                          s,
                                          style:
                                              AppTextStyles.labelSmall.copyWith(
                                            color: selected
                                                ? Colors.white
                                                : AppColors.stone600,
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ),
                  ),

                  const SizedBox(height: 16),

                  // ── Text field + voice ─────────────────────────────────
                  Row(
                    children: [
                      Text(l10n.journalMindQuestion,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.stone500)),
                      const Spacer(),
                      GestureDetector(
                        onTap: _toggleListening,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _listening
                                ? AppColors.blush500
                                : AppColors.forest50,
                            borderRadius: AppRadius.pill,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _listening
                                    ? Icons.stop_rounded
                                    : Icons.mic_none_rounded,
                                size: 14,
                                color: _listening
                                    ? Colors.white
                                    : AppColors.forest700,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _listening ? l10n.journalVoiceStop : l10n.journalVoiceSpeak,
                                style: AppTextStyles.labelSmall.copyWith(
                                    color: _listening
                                        ? Colors.white
                                        : AppColors.forest700),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _ctrl,
                    maxLines: 8,
                    minLines: 5,
                    autofocus: !_isEdit,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.stone800, height: 1.5),
                    decoration: InputDecoration(
                      hintText: l10n.journalBodyHint,
                      hintStyle: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.stone300),
                      filled: true,
                      fillColor: AppColors.stone50,
                      border: OutlineInputBorder(
                        borderRadius: AppRadius.lg,
                        borderSide: BorderSide(color: AppColors.stone100),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: AppRadius.lg,
                        borderSide: BorderSide(color: AppColors.stone100),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: AppRadius.lg,
                        borderSide: BorderSide(
                            color: AppColors.forest400, width: 1.5),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Tags ───────────────────────────────────────────────
                  Text(l10n.journalTagsLabel,
                      style: AppTextStyles.labelMedium
                          .copyWith(color: AppColors.stone500)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: suggestedTags.map((t) {
                      final selected = _tags.contains(t);
                      return GestureDetector(
                        onTap: () => _toggleTag(t),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 120),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.forest600
                                : AppColors.stone50,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected
                                  ? AppColors.forest600
                                  : AppColors.stone200,
                            ),
                          ),
                          child: Text(
                            '#$t',
                            style: AppTextStyles.labelSmall.copyWith(
                              color:
                                  selected ? Colors.white : AppColors.stone600,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _newTagCtrl,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => _addNewTag(),
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.stone800),
                          decoration: InputDecoration(
                            hintText: l10n.journalAddTagHint,
                            isDense: true,
                            hintStyle: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.stone300),
                            prefixIcon: Icon(Icons.tag_rounded,
                                size: 16, color: AppColors.stone400),
                            filled: true,
                            fillColor: AppColors.stone50,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: AppRadius.sm,
                              borderSide:
                                  BorderSide(color: AppColors.stone100),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: AppRadius.sm,
                              borderSide:
                                  BorderSide(color: AppColors.stone100),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      TextButton(
                        onPressed: _addNewTag,
                        child: Text(l10n.journalAdd),
                      ),
                    ],
                  ),

                  // ── Lock toggle ────────────────────────────────────────
                  const SizedBox(height: 8),
                  InkWell(
                    borderRadius: AppRadius.md,
                    onTap: () {
                      H.selection();
                      setState(() => _locked = !_locked);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            _locked ? Icons.lock : Icons.lock_open_outlined,
                            size: 18,
                            color: _locked
                                ? AppColors.honey500
                                : AppColors.stone400,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _locked ? l10n.journalLockedEntryLabel : l10n.journalLockEntryLabel,
                                  style: AppTextStyles.labelMedium
                                      .copyWith(color: AppColors.stone700),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  l10n.journalLockEntryHint,
                                  style: AppTextStyles.bodySmall
                                      .copyWith(color: AppColors.stone400),
                                ),
                              ],
                            ),
                          ),
                          Switch.adaptive(
                            value: _locked,
                            activeColor: AppColors.forest600,
                            onChanged: (v) {
                              H.selection();
                              setState(() => _locked = v);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Save button (sticks to bottom of sheet) ────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 18),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
                ),
                child: Text(
                  _isEdit ? l10n.journalSaveChanges : l10n.journalSaveEntry,
                  style: AppTextStyles.labelLarge.copyWith(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Prompt strip — collapsed by default, expand to pick ────────────────
  Widget _buildPromptStrip() {
    final l10n = AppLocalizations.of(context);
    final activePrompt = _promptId == null ? null : promptById(_promptId!);
    // Smart default: when the user hasn't picked a prompt yet, surface one
    // appropriate to the time of day and their most recent mood.
    final recent = ref.watch(journalProvider).valueOrNull ?? const [];
    final mostRecent = recent.isEmpty ? null : recent.first;
    final suggestedCategory = smartDefaultCategory(
      now: DateTime.now(),
      mostRecentMood: mostRecent?.mood,
      sinceMostRecent: mostRecent == null
          ? null
          : DateTime.now().difference(mostRecent.date),
    );
    final suggestedPrompt = dailyPromptFor(suggestedCategory);
    final headlineText =
        activePrompt?.text ?? l10n.journalSuggestedPrompt(suggestedPrompt.text);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          borderRadius: AppRadius.md,
          onTap: () => setState(() => _promptPickerOpen = !_promptPickerOpen),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.mintChip,
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.forest100),
            ),
            child: Row(
              children: [
                Icon(Icons.format_quote_rounded,
                    size: 16, color: AppColors.forest500),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    headlineText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.forest700,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _promptPickerOpen
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.forest500,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          child: !_promptPickerOpen
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: kPromptCategories.map((cat) {
                      final prompt = dailyPromptFor(cat);
                      final isSuggested = cat.id == suggestedCategory.id;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: InkWell(
                          borderRadius: AppRadius.sm,
                          onTap: () => _pickPrompt(prompt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 10),
                            decoration: BoxDecoration(
                              // ignore: deprecated_member_use
                              color: isSuggested
                                  // ignore: deprecated_member_use
                                  ? cat.color.withOpacity(0.06)
                                  : AppColors.stone50,
                              borderRadius: AppRadius.sm,
                              border: Border.all(
                                color: isSuggested
                                    // ignore: deprecated_member_use
                                    ? cat.color.withOpacity(0.4)
                                    : AppColors.stone100,
                                width: isSuggested ? 1.4 : 1.0,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 28,
                                  height: 28,
                                  decoration: BoxDecoration(
                                    // ignore: deprecated_member_use
                                    color: cat.color.withOpacity(0.12),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(cat.icon,
                                      size: 14, color: cat.color),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            cat.label.toUpperCase(),
                                            style:
                                                AppTextStyles.overline.copyWith(
                                              color: cat.color,
                                              fontSize: 9,
                                              letterSpacing: 1.0,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          if (isSuggested) ...[
                                            const SizedBox(width: 6),
                                            Text(
                                              l10n.journalSuggestedTag,
                                              style: AppTextStyles.overline
                                                  .copyWith(
                                                color: AppColors.stone400,
                                                fontSize: 9,
                                                letterSpacing: 0.8,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 1),
                                      Text(
                                        prompt.text,
                                        style: AppTextStyles.bodySmall.copyWith(
                                          color: AppColors.stone700,
                                          fontStyle: FontStyle.italic,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
        ),
      ],
    );
  }
}

// ─── Draft restore banner ────────────────────────────────────────────────────
// Shown at the top of the entry sheet only when (a) we're creating a fresh
// entry, (b) a non-stale draft exists in storage, and (c) the user hasn't
// already chosen Restore or Discard. Compact on purpose — it shouldn't
// dominate the sheet.

class _DraftRestoreBanner extends StatelessWidget {
  const _DraftRestoreBanner({
    required this.draft,
    required this.onRestore,
    required this.onDiscard,
  });
  final JournalDraft draft;
  final VoidCallback onRestore;
  final VoidCallback onDiscard;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final age = DateTime.now().difference(draft.savedAt);
    final mood = moodFor(draft.mood);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.honeySoft,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.honey100),
      ),
      child: Row(
        children: [
          Icon(Icons.history_edu_rounded,
              size: 18, color: AppColors.honey600),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.journalDraftFrom(_ageLabel(age, l10n)),
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.stone700),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(mood.icon, size: 12, color: mood.color),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        l10n.journalDraftChars(mood.label, draft.text.length),
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: onDiscard,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.stone500,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.journalDraftDiscard),
          ),
          TextButton(
            onPressed: onRestore,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.forest600,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              minimumSize: const Size(0, 32),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(l10n.commonRestore),
          ),
        ],
      ),
    );
  }

  String _ageLabel(Duration age, AppLocalizations l10n) {
    if (age.inMinutes < 1) return l10n.journalAgeMomentAgo;
    if (age.inMinutes < 60) return l10n.journalAgeMinutesAgo(age.inMinutes);
    if (age.inHours < 24) return l10n.journalAgeHoursAgo(age.inHours);
    return l10n.journalAgeYesterday;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 1 — Affirmations
// ─────────────────────────────────────────────────────────────────────────────

class _AffirmTab extends ConsumerStatefulWidget {
  const _AffirmTab();

  @override
  ConsumerState<_AffirmTab> createState() => _AffirmTabState();
}

class _AffirmTabState extends ConsumerState<_AffirmTab> {
  int _page = 0;
  final _pageController = PageController();
  final Set<String> _favourites = {};

  // Personalised cards seeded from the user's profile + recent gratitude.
  // These rotate daily (day-of-year mod) so the user doesn't see the same
  // one every time but they don't feel random either. Empty list when there
  // is no name + no gratitude — keeps the existing affirmation flow intact.
  List<String> _personalCards(
      String? name, List<String> gratitudes, AppLocalizations l10n) {
    final out = <String>[];
    if (name != null && name.trim().isNotEmpty) {
      final n = name.trim();
      out.addAll([
        l10n.journalPersonalCard0(n),
        l10n.journalPersonalCard1(n),
        l10n.journalPersonalCard2(n),
        l10n.journalPersonalCard3(n),
      ]);
    }
    // Pull from recent gratitudes — turn the user's own words into a mirror.
    for (final g in gratitudes.take(3)) {
      final clean = g.trim();
      if (clean.length > 4 && clean.length < 80) {
        out.add(l10n.journalPersonalGratitudeCard(clean));
      }
    }
    return out;
  }

  List<String> _allAffirmations(
    List<String> personal,
    List<String> custom,
    List<String> defaults,
  ) =>
      [...personal, ...custom, ...defaults];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final defaults = _buildDefaultAffirmations(l10n);
    final customAsync = ref.watch(affirmationProvider);
    final custom = customAsync.valueOrNull ?? [];
    final profile = ref.watch(profileProvider).valueOrNull;
    final pastGratitudes = ref.watch(allGratitudeProvider).valueOrNull ?? [];
    final personal = _personalCards(
      profile?.username,
      pastGratitudes.map((g) => g.text).toList(),
      l10n,
    );
    final all = _allAffirmations(personal, custom, defaults);

    return Stack(
      children: [
        Column(
          children: [
            // Swipeable card
            SizedBox(
              height: 300,
              child: PageView.builder(
                controller: _pageController,
                itemCount: all.length,
                onPageChanged: (i) => setState(() => _page = i),
                itemBuilder: (_, i) => _AffirmCard(
                  text: all[i],
                  isFavourite: _favourites.contains(all[i]),
                  isCustom: i < custom.length,
                  onFavourite: () => setState(() {
                    if (_favourites.contains(all[i])) {
                      _favourites.remove(all[i]);
                    } else {
                      _favourites.add(all[i]);
                    }
                  }),
                  onDelete: i < custom.length
                      ? () =>
                          ref.read(affirmationProvider.notifier).remove(all[i])
                      : null,
                ),
              ),
            ),

            // Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                all.length.clamp(0, 20),
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _page ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color:
                        i == _page ? AppColors.forest600 : AppColors.stone200,
                    borderRadius: AppRadius.full,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Swipe hint
            Text(l10n.journalSwipeHint,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone400)),

            Divider(
              height: 32,
              indent: 20,
              endIndent: 20,
              color: AppColors.stone100,
            ),

            // Your custom affirmations
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Text(l10n.journalYourAffirmations,
                      style: AppTextStyles.titleMedium
                          .copyWith(color: AppColors.stone700)),
                  const Spacer(),
                  Text('${custom.length}',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone400)),
                ],
              ),
            ),
            const SizedBox(height: 8),

            Expanded(
              child: custom.isEmpty
                  ? Center(
                      child: Text(
                        l10n.journalTapToAddAffirmation,
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppColors.stone400),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                      itemCount: custom.length,
                      itemBuilder: (_, i) => _CustomAffirmRow(
                        text: custom[i],
                        onDelete: () => ref
                            .read(affirmationProvider.notifier)
                            .remove(custom[i]),
                      ),
                    ),
            ),
          ],
        ),

        // FAB
        Positioned(
          right: 20,
          bottom: 24,
          child: _FAB(
            onTap: () => _showAddSheet(context, ref),
          ),
        ),
      ],
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final ctrl = TextEditingController();
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    // Dispose the controller after the sheet closes — without this, every
    // FAB tap created a controller that was never freed.
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppRadius.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.journalAddAffirmationTitle,
                style: AppTextStyles.titleLarge
                    .copyWith(color: AppColors.forest700)),
            const SizedBox(height: 14),
            TextField(
              controller: ctrl,
              maxLines: 3,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
              decoration: InputDecoration(
                hintText: l10n.journalAffirmationHint,
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone300),
                filled: true,
                fillColor: AppColors.stone50,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide: BorderSide(color: AppColors.stone100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide: BorderSide(color: AppColors.stone100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide:
                      BorderSide(color: AppColors.forest400, width: 1.5),
                ),
                contentPadding: const EdgeInsets.all(14),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  final t = ctrl.text.trim();
                  if (t.isEmpty) return;
                  ref.read(affirmationProvider.notifier).add(t);
                  H.medium();
                  Navigator.pop(ctx);
                },
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
                ),
                child: Text(l10n.journalAdd,
                    style:
                        AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    ).whenComplete(ctrl.dispose);
  }
}

class _AffirmCard extends StatelessWidget {
  const _AffirmCard({
    required this.text,
    required this.isFavourite,
    required this.isCustom,
    required this.onFavourite,
    this.onDelete,
  });
  final String text;
  final bool isFavourite;
  final bool isCustom;
  final VoidCallback onFavourite;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.forest50, Color(0xFFF0F7F3)],
          ),
          borderRadius: AppRadius.xl,
          border: Border.all(color: AppColors.forest100),
          boxShadow: AppShadows.card,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.format_quote_rounded,
                size: 32, color: AppColors.forest200),
            const SizedBox(height: 12),
            Text(
              text,
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.forest800,
                height: 1.6,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    H.selection();
                    onFavourite();
                  },
                  child: Icon(
                    isFavourite ? Icons.spa_rounded : Icons.spa_outlined,
                    size: 22,
                    color:
                        isFavourite ? AppColors.honey500 : AppColors.stone300,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomAffirmRow extends StatelessWidget {
  const _CustomAffirmRow({required this.text, required this.onDelete});
  final String text;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.stone100),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, size: 16, color: AppColors.honey400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone700)),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Icon(Icons.close_rounded,
                size: 18, color: AppColors.stone300),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 2 — Vision Board
// ─────────────────────────────────────────────────────────────────────────────

/// Filter chips above the board.
enum _VisionFilter { all, active, pinned, achieved }

class _VisionTab extends ConsumerStatefulWidget {
  const _VisionTab();

  @override
  ConsumerState<_VisionTab> createState() => _VisionTabState();
}

class _VisionTabState extends ConsumerState<_VisionTab> {
  _VisionFilter _filter = _VisionFilter.all;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final ref = this.ref;
    final items = ref.watch(visionBoardProvider).valueOrNull ?? const [];

    // Filter pass — kept separate from grouping so counts can be computed
    // independently for the chips below.
    final filtered = items.where((e) {
      switch (_filter) {
        case _VisionFilter.all:
          return true;
        case _VisionFilter.active:
          return !e.achieved;
        case _VisionFilter.pinned:
          return e.pinned && !e.achieved;
        case _VisionFilter.achieved:
          return e.achieved;
      }
    }).toList();

    // Group by category for the section headers. Map preserves insertion order,
    // which we set deliberately so 'Uncategorised' lands last.
    final byCategory = <VisionCategory, List<VisionItem>>{};
    for (final cat in VisionCategory.values) {
      final hits = filtered.where((e) => e.category == cat).toList();
      if (hits.isNotEmpty) byCategory[cat] = hits;
    }

    final pinnedCount = items.where((e) => e.pinned && !e.achieved).length;
    final achievedCount = items.where((e) => e.achieved).length;
    final activeCount = items.length - achievedCount;

    return Stack(
      children: [
        CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: _BoardHeader(
                  total: items.length,
                  pinnedCount: pinnedCount,
                  achievedCount: achievedCount,
                ),
              ),
            ),
            if (items.isNotEmpty)
              SliverToBoxAdapter(
                child: _FilterRow(
                  filter: _filter,
                  allCount: items.length,
                  activeCount: activeCount,
                  pinnedCount: pinnedCount,
                  achievedCount: achievedCount,
                  onSelect: (f) {
                    H.selection();
                    setState(() => _filter = f);
                  },
                ),
              ),

            // ── Empty state (no items at all OR filter has no matches) ──────
            if (items.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: _VisionEmptyState(
                  onSeed: (starter) =>
                      _showEditSheet(context, ref, null, starter: starter),
                  onBlank: () => _showEditSheet(context, ref, null),
                ),
              )
            else if (filtered.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: _EmptyState(
                    icon: Icons.filter_alt_off_outlined,
                    title: l10n.visionFilterEmptyTitle,
                    subtitle: l10n.visionFilterEmptySubtitle,
                  ),
                ),
              )
            else
              // One sliver per category section.
              ...byCategory.entries.expand((entry) {
                final info = categoryInfoFor(entry.key);
                final showHeader =
                    byCategory.length > 1 || entry.key != VisionCategory.none;
                return [
                  if (showHeader)
                    SliverToBoxAdapter(
                      child:
                          _SectionHeader(info: info, count: entry.value.length),
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 14,
                        crossAxisSpacing: 14,
                        childAspectRatio: 0.82,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => _VisionCard(
                          item: entry.value[i],
                          onTap: () =>
                              _openDetail(context, ref, entry.value[i]),
                          onEdit: () =>
                              _showEditSheet(context, ref, entry.value[i]),
                          onDelete: () => ref
                              .read(visionBoardProvider.notifier)
                              .remove(entry.value[i].id),
                        ),
                        childCount: entry.value.length,
                      ),
                    ),
                  ),
                ];
              }),
            const SliverToBoxAdapter(child: SizedBox(height: 110)),
          ],
        ),
        Positioned(
          right: 20,
          bottom: 24,
          child: _FAB(onTap: () => _showEditSheet(context, ref, null)),
        ),
      ],
    );
  }

  void _openDetail(BuildContext context, WidgetRef ref, VisionItem item) {
    H.selection();
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => VisionDetailScreen(
        itemId: item.id,
        onEdit: (live) => _showEditSheet(context, ref, live),
      ),
    ));
  }

  void _showEditSheet(BuildContext context, WidgetRef ref, VisionItem? item,
      {VisionStarter? starter}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        // Lift sheet above keyboard — outside the stateful widget so it only
        // rebuilds the Padding, never the text fields.
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _VisionEditSheet(
          existingItem: item,
          starter: starter,
          onSave: (updated) =>
              ref.read(visionBoardProvider.notifier).add(updated),
          onUpdate: (updated) =>
              ref.read(visionBoardProvider.notifier).saveItem(updated),
          onDelete: item == null
              ? null
              : () => ref.read(visionBoardProvider.notifier).remove(item.id),
        ),
      ),
    );
  }
}

// ─── Board header banner ─────────────────────────────────────────────────────

class _BoardHeader extends StatelessWidget {
  const _BoardHeader({
    required this.total,
    required this.pinnedCount,
    required this.achievedCount,
  });
  final int total;
  final int pinnedCount;
  final int achievedCount;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.mintChip, AppColors.forest50],
        ),
        borderRadius: AppRadius.luxury,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.forest100,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.auto_awesome_rounded,
                size: 22, color: AppColors.forest600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.visionBoardTitle,
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.forest700)),
                Text(
                  total == 0
                      ? l10n.visionBoardEmptyTagline
                      : _subtitle(total, pinnedCount, achievedCount, l10n),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _subtitle(int total, int pinned, int achieved, AppLocalizations l10n) {
    final parts = <String>[
      l10n.visionDreamCount(total),
      if (pinned > 0) l10n.visionPinnedCount(pinned),
      if (achieved > 0) l10n.visionAchievedCount(achieved),
    ];
    return parts.join(' · ');
  }
}

// ─── Filter chips row ────────────────────────────────────────────────────────

class _FilterRow extends StatelessWidget {
  const _FilterRow({
    required this.filter,
    required this.allCount,
    required this.activeCount,
    required this.pinnedCount,
    required this.achievedCount,
    required this.onSelect,
  });
  final _VisionFilter filter;
  final int allCount;
  final int activeCount;
  final int pinnedCount;
  final int achievedCount;
  final void Function(_VisionFilter) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip(l10n.journalFilterAll, allCount, _VisionFilter.all),
            const SizedBox(width: 8),
            _filterChip(
                l10n.visionFilterActive, activeCount, _VisionFilter.active),
            const SizedBox(width: 8),
            _filterChip(
                l10n.visionFilterPinned, pinnedCount, _VisionFilter.pinned),
            const SizedBox(width: 8),
            _filterChip(l10n.visionFilterAchieved, achievedCount,
                _VisionFilter.achieved),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, int count, _VisionFilter f) {
    final selected = f == filter;
    return GestureDetector(
      onTap: () => onSelect(f),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.forest600 : AppColors.card,
          borderRadius: AppRadius.sm,
          border: Border.all(
            color: selected ? AppColors.forest600 : AppColors.stone200,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelMedium.copyWith(
                color: selected ? Colors.white : AppColors.stone600,
              ),
            ),
            if (count > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: selected
                      // ignore: deprecated_member_use
                      ? Colors.white.withOpacity(0.20)
                      : AppColors.stone100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: selected ? Colors.white : AppColors.stone600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Category section header ─────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.info, required this.count});
  final VisionCategoryInfo info;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
      child: Row(
        children: [
          Icon(info.icon, size: 16, color: info.color),
          const SizedBox(width: 8),
          Text(
            info.label.toUpperCase(),
            style: AppTextStyles.overline.copyWith(
              color: info.color,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text('· $count',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone400)),
        ],
      ),
    );
  }
}

// ─── Empty state with starter prompts ────────────────────────────────────────

class _VisionEmptyState extends StatelessWidget {
  const _VisionEmptyState({required this.onSeed, required this.onBlank});
  final void Function(VisionStarter) onSeed;
  final VoidCallback onBlank;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.forest50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.auto_awesome_rounded,
                  size: 34, color: AppColors.forest500),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              l10n.visionEmptyTitle,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.forest700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              l10n.visionEmptySubtitle,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 20),
          ...kStarterPrompts.map((s) {
            final opt = visionOptionFor(s.iconKey);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: AppRadius.lg,
                onTap: () {
                  H.selection();
                  onSeed(s);
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: AppRadius.lg,
                    border: Border.all(color: AppColors.stone100),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          // ignore: deprecated_member_use
                          color: opt.color.withOpacity(0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(opt.icon, size: 18, color: opt.color),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          s.title,
                          style: AppTextStyles.bodyMedium
                              .copyWith(color: AppColors.stone800),
                        ),
                      ),
                      Icon(Icons.add_rounded,
                          size: 18, color: AppColors.stone400),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 6),
          Center(
            child: TextButton.icon(
              onPressed: onBlank,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(l10n.visionBlankDreamButton),
              style: TextButton.styleFrom(foregroundColor: AppColors.forest600),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Vision Card ─────────────────────────────────────────────────────────────

class _VisionCard extends StatelessWidget {
  const _VisionCard({
    required this.item,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });
  final VisionItem item;
  final VoidCallback onTap; // open detail view
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final accent = visionAccent(item);
    final opt = visionOptionFor(item.emoji);
    final hasPhoto =
        item.imagePaths.isNotEmpty && File(item.imagePaths.first).existsSync();
    final progress = item.progress;
    final hasMilestones = item.milestones.isNotEmpty;

    return GestureDetector(
      onTap: () {
        H.selection();
        onTap();
      },
      onLongPress: () {
        H.medium();
        _confirmDelete(context);
      },
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadius.lg,
              border: Border.all(
                color: item.achieved
                    // ignore: deprecated_member_use
                    ? AppColors.forest500.withOpacity(0.45)
                    // ignore: deprecated_member_use
                    : accent.withOpacity(0.18),
                width: item.achieved ? 1.6 : 1.2,
              ),
              boxShadow: AppShadows.luxury,
            ),
            clipBehavior: Clip.hardEdge,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (hasPhoto)
                  SizedBox(
                    height: 90,
                    child: Image.file(
                      File(item.imagePaths.first),
                      fit: BoxFit.cover,
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: hasPhoto ? 40 : 52,
                          height: hasPhoto ? 40 : 52,
                          decoration: BoxDecoration(
                            // ignore: deprecated_member_use
                            color: accent.withOpacity(0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(opt.icon,
                              size: hasPhoto ? 20 : 26, color: accent),
                        ),
                        SizedBox(height: hasPhoto ? 6 : 10),

                        Text(
                          item.title,
                          style: AppTextStyles.titleSmall.copyWith(
                              color: AppColors.forest700, height: 1.25),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        if (item.description.isNotEmpty) ...[
                          const SizedBox(height: 5),
                          Text(
                            item.description,
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.stone400),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],

                        const Spacer(),

                        // Progress bar OR "tap to open" hint.
                        if (hasMilestones)
                          _MiniProgress(progress: progress, accent: accent)
                        else
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.touch_app_outlined,
                                  size: 11, color: AppColors.stone300),
                              const SizedBox(width: 3),
                              Text(l10n.visionTapToOpen,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.stone300,
                                      letterSpacing: 0.4)),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pinned indicator (top-left).
          if (item.pinned)
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.honey500,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.luxury,
                ),
                child:
                    const Icon(Icons.push_pin, size: 12, color: Colors.white),
              ),
            ),

          // Achieved overlay (top-right check + subtle tint).
          if (item.achieved)
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: AppColors.forest600,
                  shape: BoxShape.circle,
                  boxShadow: AppShadows.luxury,
                ),
                child: const Icon(Icons.check, size: 14, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text(l10n.visionRemoveDreamTitle,
            style:
                AppTextStyles.titleMedium.copyWith(color: AppColors.stone800)),
        content: Text(item.title,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.visionKeep,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.stone500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: Text(l10n.visionRemove,
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.blush600)),
          ),
        ],
      ),
    );
  }
}

class _MiniProgress extends StatelessWidget {
  const _MiniProgress({required this.progress, required this.accent});
  final double progress;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 4,
            // ignore: deprecated_member_use
            backgroundColor: accent.withOpacity(0.12),
            valueColor: AlwaysStoppedAnimation(accent),
          ),
        ),
        const SizedBox(height: 4),
        Text('${(progress * 100).round()}%',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontSize: 10,
                color: AppColors.stone500,
                fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ─── Vision Edit Sheet (add + edit) ──────────────────────────────────────────
// The keyboard-inset Padding lives OUTSIDE this widget (in the bottom-sheet
// builder) so the text fields never lose focus when the keyboard appears.

class _VisionEditSheet extends StatefulWidget {
  const _VisionEditSheet({
    required this.onSave,
    required this.onUpdate,
    this.existingItem,
    this.starter,
    this.onDelete,
  });
  final VisionItem? existingItem;
  final VisionStarter? starter; // pre-fill from a tapped starter prompt
  final void Function(VisionItem) onSave;
  final void Function(VisionItem) onUpdate;
  final VoidCallback? onDelete;

  @override
  State<_VisionEditSheet> createState() => _VisionEditSheetState();
}

enum _SheetTab { vision, photo, milestones, affirmation }

class _VisionEditSheetState extends State<_VisionEditSheet> {
  // ── Form controllers ─────────────────────────────────────────────────────
  late final TextEditingController _titleCtrl;
  late final TextEditingController _descCtrl;
  late final TextEditingController _whyCtrl;
  late final TextEditingController _affirmCtrl;
  late final TextEditingController _milestoneCtrl;
  final _titleFocus = FocusNode();

  // ── Form state ───────────────────────────────────────────────────────────
  late String _iconKey;
  late VisionCategory _category;
  DateTime? _targetDate;
  late List<String> _imagePaths;
  late List<VisionMilestone> _milestones;

  _SheetTab _tab = _SheetTab.vision;

  bool get _isEdit => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final ex = widget.existingItem;
    final st = widget.starter;
    _titleCtrl = TextEditingController(text: ex?.title ?? st?.title ?? '');
    _descCtrl = TextEditingController(text: ex?.description ?? '');
    _whyCtrl = TextEditingController(text: ex?.whyItMatters ?? '');
    _affirmCtrl =
        TextEditingController(text: ex?.affirmation ?? st?.affirmation ?? '');
    _milestoneCtrl = TextEditingController();
    _iconKey = ex?.emoji ?? st?.iconKey ?? 'guide';
    _category = ex?.category ?? st?.category ?? VisionCategory.none;
    _targetDate = ex?.targetDate;
    _imagePaths = List<String>.from(ex?.imagePaths ?? const []);
    _milestones = List<VisionMilestone>.from(ex?.milestones ?? const []);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _whyCtrl.dispose();
    _affirmCtrl.dispose();
    _milestoneCtrl.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  // ── Photo handling ───────────────────────────────────────────────────────
  Future<void> _pickImage() async {
    if (_imagePaths.length >= 4) return; // cap at 4
    final picker = ImagePicker();
    final picked =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (picked != null && mounted) {
      setState(() => _imagePaths.add(picked.path));
    }
  }

  // ── Milestone handling ───────────────────────────────────────────────────
  void _addMilestone() {
    final text = _milestoneCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _milestones.add(VisionMilestone(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        text: text,
      ));
      _milestoneCtrl.clear();
    });
    H.selection();
  }

  void _toggleMilestone(int i) {
    setState(() {
      _milestones[i] = _milestones[i].copyWith(done: !_milestones[i].done);
    });
  }

  void _removeMilestone(int i) {
    setState(() => _milestones.removeAt(i));
  }

  // ── Target date ──────────────────────────────────────────────────────────
  Future<void> _pickTargetDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? now.add(const Duration(days: 90)),
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365 * 10)),
    );
    if (picked != null) setState(() => _targetDate = picked);
  }

  // ── Affirmation suggest ──────────────────────────────────────────────────
  void _suggestAffirmation() {
    final suggestion = suggestAffirmationForTitle(_titleCtrl.text);
    setState(() => _affirmCtrl.text = suggestion);
    H.light();
  }

  // ── Save ─────────────────────────────────────────────────────────────────
  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      setState(() => _tab = _SheetTab.vision);
      _titleFocus.requestFocus();
      return;
    }
    final item = _isEdit
        ? widget.existingItem!.copyWith(
            title: title,
            description: _descCtrl.text.trim(),
            emoji: _iconKey,
            imagePaths: _imagePaths,
            category: _category,
            targetDate: _targetDate,
            milestones: _milestones,
            affirmation: _affirmCtrl.text.trim(),
            whyItMatters: _whyCtrl.text.trim(),
          )
        : VisionItem(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: title,
            description: _descCtrl.text.trim(),
            emoji: _iconKey,
            imagePaths: _imagePaths,
            category: _category,
            targetDate: _targetDate,
            milestones: _milestones,
            affirmation: _affirmCtrl.text.trim(),
            whyItMatters: _whyCtrl.text.trim(),
          );
    if (_isEdit) {
      widget.onUpdate(item);
    } else {
      widget.onSave(item);
    }
    Navigator.pop(context);
    H.medium();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.92,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Header ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 12, 10),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _isEdit ? l10n.visionEditDreamTitle : l10n.visionAddDreamTitle,
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.forest700),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.stone100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close_rounded,
                        size: 17, color: AppColors.stone500),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ),

          // ── Tabs ─────────────────────────────────────────────────────────
          _SheetTabBar(
            current: _tab,
            onSelect: (t) {
              H.selection();
              setState(() => _tab = t);
            },
          ),

          // ── Tab body ─────────────────────────────────────────────────────
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
              child: _buildTabBody(),
            ),
          ),

          // ── Footer buttons ───────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _save,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest600,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
                    ),
                    child: Text(
                      _isEdit ? l10n.journalSaveChanges : l10n.visionAddToBoard,
                      style: AppTextStyles.labelLarge
                          .copyWith(color: Colors.white),
                    ),
                  ),
                ),
                if (_isEdit && widget.onDelete != null) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        widget.onDelete!();
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape:
                            RoundedRectangleBorder(borderRadius: AppRadius.lg),
                      ),
                      child: Text(l10n.visionRemoveThisDream,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.blush600)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Tab body switcher ─────────────────────────────────────────────────────
  Widget _buildTabBody() {
    switch (_tab) {
      case _SheetTab.vision:
        return _buildVisionTab();
      case _SheetTab.photo:
        return _buildPhotoTab();
      case _SheetTab.milestones:
        return _buildMilestonesTab();
      case _SheetTab.affirmation:
        return _buildAffirmationTab();
    }
  }

  // ── Tab: Vision (title, description, icon, category, date) ───────────────
  Widget _buildVisionTab() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.visionDreamTitleLabel),
        const SizedBox(height: 6),
        TextField(
          controller: _titleCtrl,
          focusNode: _titleFocus,
          textInputAction: TextInputAction.next,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
          decoration: _fieldDecor(
              l10n.visionDreamTitleHint, Icons.title_rounded),
        ),
        const SizedBox(height: 14),
        _label(l10n.visionNotesLabel),
        const SizedBox(height: 6),
        TextField(
          controller: _descCtrl,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 2,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
          decoration: _fieldDecor(l10n.visionNotesHint, Icons.notes_rounded),
        ),
        const SizedBox(height: 14),
        _label(l10n.visionWhyLabel),
        const SizedBox(height: 6),
        TextField(
          controller: _whyCtrl,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 2,
          style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
          decoration: _fieldDecor(l10n.visionWhyHint,
              Icons.psychology_outlined),
        ),
        const SizedBox(height: 18),
        _label(l10n.visionCategoryLabel),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: kCategoryInfo.map((info) {
            final selected = info.category == _category;
            return GestureDetector(
              onTap: () {
                H.selection();
                setState(() => _category = info.category);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: selected
                      // ignore: deprecated_member_use
                      ? info.color.withOpacity(0.14)
                      : AppColors.stone50,
                  borderRadius: AppRadius.sm,
                  border: Border.all(
                    color: selected ? info.color : AppColors.stone100,
                    width: selected ? 1.5 : 1.0,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(info.icon,
                        size: 14,
                        color: selected ? info.color : AppColors.stone400),
                    const SizedBox(width: 6),
                    Text(info.label,
                        style: AppTextStyles.labelMedium.copyWith(
                            color: selected ? info.color : AppColors.stone600)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        _label(l10n.visionChooseIcon),
        const SizedBox(height: 10),
        GridView.count(
          crossAxisCount: 5,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 0.72,
          children: kVisionIcons.map((o) {
            final selected = o.key == _iconKey;
            return GestureDetector(
              onTap: () {
                H.selection();
                setState(() => _iconKey = o.key);
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: double.infinity,
                    height: 44,
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: selected
                          // ignore: deprecated_member_use
                          ? o.color.withOpacity(0.14)
                          : AppColors.stone50,
                      borderRadius: AppRadius.md,
                      border: Border.all(
                        color: selected
                            // ignore: deprecated_member_use
                            ? o.color.withOpacity(0.6)
                            : AppColors.stone100,
                        width: selected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Icon(o.icon,
                        size: 22,
                        color: selected ? o.color : AppColors.stone400),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    o.label,
                    style: TextStyle(
                      fontSize: 9,
                      color: selected ? o.color : AppColors.stone400,
                      fontWeight:
                          selected ? FontWeight.w600 : FontWeight.normal,
                      letterSpacing: 0.1,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),
        _label(l10n.visionTargetDateLabel),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: AppRadius.lg,
          onTap: _pickTargetDate,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.stone50,
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.stone100),
            ),
            child: Row(
              children: [
                Icon(Icons.event_rounded,
                    size: 18, color: AppColors.stone400),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _targetDate == null
                        ? l10n.visionTargetDatePlaceholder
                        : DateFormat.yMMMMd().format(_targetDate!),
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: _targetDate == null
                            ? AppColors.stone400
                            : AppColors.stone800),
                  ),
                ),
                if (_targetDate != null)
                  IconButton(
                    icon: Icon(Icons.clear_rounded,
                        size: 18, color: AppColors.stone400),
                    onPressed: () => setState(() => _targetDate = null),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ── Tab: Photos ──────────────────────────────────────────────────────────
  Widget _buildPhotoTab() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.visionPhotosLabel),
        const SizedBox(height: 10),
        if (_imagePaths.isNotEmpty)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              for (var i = 0; i < _imagePaths.length; i++)
                _PhotoTile(
                  path: _imagePaths[i],
                  onRemove: () => setState(() => _imagePaths.removeAt(i)),
                ),
            ],
          ),
        if (_imagePaths.isNotEmpty) const SizedBox(height: 12),
        if (_imagePaths.length < 4)
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.stone50,
                borderRadius: AppRadius.lg,
                border: Border.all(color: AppColors.stone100),
              ),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined,
                        size: 22, color: AppColors.stone400),
                    const SizedBox(width: 10),
                    Text(
                      _imagePaths.isEmpty
                          ? l10n.visionAddFirstPhoto
                          : l10n.visionAddAnotherPhoto(_imagePaths.length),
                      style: AppTextStyles.bodyMedium
                          .copyWith(color: AppColors.stone500),
                    ),
                  ],
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        Text(
          l10n.visionPhotosPrivacyNote,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone400),
        ),
      ],
    );
  }

  // ── Tab: Milestones ──────────────────────────────────────────────────────
  Widget _buildMilestonesTab() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.visionStepsLabel),
        const SizedBox(height: 6),
        Text(
          l10n.visionStepsDescription,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
        ),
        const SizedBox(height: 14),
        if (_milestones.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(l10n.visionNoStepsYet,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone400)),
          )
        else
          ...List.generate(_milestones.length, (i) {
            final m = _milestones[i];
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.stone50,
                borderRadius: AppRadius.md,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(
                      m.done
                          ? Icons.check_circle
                          : Icons.radio_button_unchecked,
                      color: m.done ? AppColors.forest600 : AppColors.stone400,
                      size: 22,
                    ),
                    onPressed: () => _toggleMilestone(i),
                  ),
                  Expanded(
                    child: Text(
                      m.text,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: m.done ? AppColors.stone400 : AppColors.stone800,
                        decoration: m.done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: AppColors.stone400),
                    onPressed: () => _removeMilestone(i),
                  ),
                ],
              ),
            );
          }),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _milestoneCtrl,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _addMilestone(),
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone800),
                decoration: _fieldDecor(
                    l10n.visionStepHint, Icons.add_task_rounded),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _addMilestone,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest600,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
              ),
              child:
                  const Icon(Icons.add_rounded, color: Colors.white, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  // ── Tab: Affirmation ─────────────────────────────────────────────────────
  Widget _buildAffirmationTab() {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(l10n.visionAffirmationLabel),
        const SizedBox(height: 6),
        Text(
          l10n.visionAffirmationDescription,
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _affirmCtrl,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.stone800, fontStyle: FontStyle.italic),
          decoration: _fieldDecor(
              l10n.visionAffirmationHint,
              Icons.format_quote_rounded),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _suggestAffirmation,
            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: Text(l10n.visionSuggestFromTitle),
            style: TextButton.styleFrom(foregroundColor: AppColors.forest600),
          ),
        ),
      ],
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────
  Widget _label(String text) => Text(text,
      style: AppTextStyles.labelMedium.copyWith(color: AppColors.stone500));

  InputDecoration _fieldDecor(String hint, IconData icon) => InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone300),
        prefixIcon: Icon(icon, size: 18, color: AppColors.stone300),
        filled: true,
        fillColor: AppColors.stone50,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.stone100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.stone100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: BorderSide(color: AppColors.forest400, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(14),
      );
}

// ─── Sheet tab bar ───────────────────────────────────────────────────────────

class _SheetTabBar extends StatelessWidget {
  const _SheetTabBar({required this.current, required this.onSelect});
  final _SheetTab current;
  final void Function(_SheetTab) onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tabs = <(_SheetTab, IconData, String)>[
      (_SheetTab.vision, Icons.auto_awesome_rounded, l10n.visionTabVision),
      (_SheetTab.photo, Icons.image_outlined, l10n.visionTabPhotos),
      (_SheetTab.milestones, Icons.flag_outlined, l10n.visionTabSteps),
      (_SheetTab.affirmation, Icons.format_quote_rounded, l10n.visionTabAffirm),
    ];
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.stone50,
        borderRadius: AppRadius.md,
      ),
      child: Row(
        children: tabs.map((t) {
          final selected = t.$1 == current;
          return Expanded(
            child: GestureDetector(
              onTap: () => onSelect(t.$1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? AppColors.card : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: selected ? AppShadows.luxury : null,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(t.$2,
                        size: 16,
                        color: selected
                            ? AppColors.forest600
                            : AppColors.stone500),
                    const SizedBox(height: 2),
                    Text(
                      t.$3,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight:
                            selected ? FontWeight.w700 : FontWeight.w500,
                        color:
                            selected ? AppColors.forest700 : AppColors.stone500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── Photo tile (with remove button) ─────────────────────────────────────────

class _PhotoTile extends StatelessWidget {
  const _PhotoTile({required this.path, required this.onRemove});
  final String path;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppRadius.md,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.file(File(path), fit: BoxFit.cover),
          Positioned(
            top: 6,
            right: 6,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 26,
                height: 26,
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close_rounded,
                    size: 14, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Tab 3 — Daily Zen
// ─────────────────────────────────────────────────────────────────────────────

class _ZenTab extends StatelessWidget {
  const _ZenTab();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final zenQuotes = _buildZenQuotes(l10n);
    final now = DateTime.now();
    final dayOfYear = now.difference(DateTime(now.year)).inDays;
    final (quote, author) = zenQuotes[dayOfYear % zenQuotes.length];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 4, 24, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily quote card
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.mintChip,
              borderRadius: AppRadius.luxury,
              border: Border.all(color: AppColors.softBorder),
              boxShadow: AppShadows.luxury,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.format_quote_rounded,
                        size: 20, color: AppColors.forest400),
                    const SizedBox(width: 8),
                    Text(
                      l10n.zenTodaysReflection,
                      style: AppTextStyles.overline,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  '"$quote"',
                  style: AppTextStyles.bodySerif.copyWith(
                    color: AppColors.forestDark,
                    height: 1.7,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '— $author',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.forest600,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Morning intention
          _ZenSection(
            title: l10n.zenMorningIntention,
            icon: Icons.light_mode_outlined,
            color: AppColors.honey500,
            child: const _IntentionWidget(),
          ),

          const SizedBox(height: 16),

          // Evening reflection prompts
          _ZenSection(
            title: l10n.zenReflectionPrompts,
            icon: Icons.nights_stay_outlined,
            color: AppColors.forest600,
            child: const _ReflectionPrompts(),
          ),

          const SizedBox(height: 16),

          // Gratitude section
          _ZenSection(
            title: l10n.zenThreeGoodThings,
            icon: Icons.spa_outlined,
            color: AppColors.honey500,
            child: const _ThreeGoodThings(),
          ),

          const SizedBox(height: 16),

          // Breathing reminder
          _ZenSection(
            title: l10n.zenMindfulMoment,
            icon: Icons.air_rounded,
            color: AppColors.forest400,
            child: const _MindfulMoment(),
          ),
        ],
      ),
    );
  }
}

class _ZenSection extends StatelessWidget {
  const _ZenSection({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xxl,
        border: Border.all(color: AppColors.softBorder),
        boxShadow: AppShadows.luxury,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.titleSmall
                      .copyWith(color: AppColors.stone700)),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _IntentionWidget extends StatefulWidget {
  const _IntentionWidget();

  @override
  State<_IntentionWidget> createState() => _IntentionWidgetState();
}

class _IntentionWidgetState extends State<_IntentionWidget> {
  final _ctrl = TextEditingController();
  bool _saved = false;

  List<String> _prompts(AppLocalizations l10n) => [
        l10n.zenIntentionPrompt0,
        l10n.zenIntentionPrompt1,
        l10n.zenIntentionPrompt2,
        l10n.zenIntentionPrompt3,
      ];

  String _hint(AppLocalizations l10n) {
    final prompts = _prompts(l10n);
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return prompts[dayOfYear % prompts.length];
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    if (_saved) {
      return Row(
        children: [
          Icon(Icons.check_circle_rounded,
              size: 18, color: AppColors.forest500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_ctrl.text,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone700)),
          ),
          GestureDetector(
            onTap: () => setState(() => _saved = false),
            child: Icon(Icons.edit_outlined,
                size: 16, color: AppColors.stone300),
          ),
        ],
      );
    }
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _ctrl,
            textCapitalization: TextCapitalization.sentences,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
            decoration: InputDecoration(
              hintText: _hint(l10n),
              hintStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone300),
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            if (_ctrl.text.trim().isEmpty) return;
            H.selection();
            setState(() => _saved = true);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.honey50,
              borderRadius: AppRadius.md,
              border: Border.all(color: AppColors.honey200),
            ),
            child: Text(l10n.zenSetIntention,
                style: AppTextStyles.labelSmall
                    .copyWith(color: AppColors.honey600)),
          ),
        ),
      ],
    );
  }
}

class _ReflectionPrompts extends StatefulWidget {
  const _ReflectionPrompts();

  @override
  State<_ReflectionPrompts> createState() => _ReflectionPromptsState();
}

class _ReflectionPromptsState extends State<_ReflectionPrompts> {
  int _current = 0;

  List<String> _prompts(AppLocalizations l10n) => [
        l10n.zenReflectionPrompt0,
        l10n.zenReflectionPrompt1,
        l10n.zenReflectionPrompt2,
        l10n.zenReflectionPrompt3,
        l10n.zenReflectionPrompt4,
        l10n.zenReflectionPrompt5,
        l10n.zenReflectionPrompt6,
        l10n.zenReflectionPrompt7,
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prompts = _prompts(l10n);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          prompts[_current],
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.stone600, height: 1.5),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            H.selection();
            setState(() => _current = (_current + 1) % prompts.length);
          },
          child: Row(
            children: [
              Icon(Icons.refresh_rounded,
                  size: 16, color: AppColors.forest500),
              const SizedBox(width: 6),
              Text(l10n.zenNextPrompt,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.forest600)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ThreeGoodThings extends StatefulWidget {
  const _ThreeGoodThings();

  @override
  State<_ThreeGoodThings> createState() => _ThreeGoodThingsState();
}

class _ThreeGoodThingsState extends State<_ThreeGoodThings> {
  final _ctrls = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: AppColors.honeySoft,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '${i + 1}',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.honey500),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: _ctrls[i],
                  textCapitalization: TextCapitalization.sentences,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone800),
                  decoration: InputDecoration(
                    hintText: l10n.zenGoodThingHint,
                    hintStyle: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.stone300),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _MindfulMoment extends StatelessWidget {
  const _MindfulMoment();

  List<(String, String, bool)> _exercises(AppLocalizations l10n) => [
        (
          l10n.zenExercise0Title,
          l10n.zenExercise0Desc,
          false,
        ),
        (
          l10n.zenExercise1Title,
          l10n.zenExercise1Desc,
          true, // has guided exercise in Toolkit
        ),
        (
          l10n.zenExercise2Title,
          l10n.zenExercise2Desc,
          false,
        ),
        (
          l10n.zenExercise3Title,
          l10n.zenExercise3Desc,
          true,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final exercises = _exercises(l10n);
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final (title, desc, hasGuided) = exercises[dayOfYear % exercises.length];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style:
                AppTextStyles.labelMedium.copyWith(color: AppColors.forest600)),
        const SizedBox(height: 6),
        Text(desc,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.stone600,
              height: 1.5,
            )),
        if (hasGuided) ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.go('/emergency'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.forest50,
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.forest200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.air_rounded,
                      size: 16, color: AppColors.forest600),
                  const SizedBox(width: 7),
                  Text(l10n.zenOpenGuidedBreathing,
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.forest700)),
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded,
                      size: 15, color: AppColors.forest500),
                ],
              ),
            ),
          ),
        ] else ...[
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => context.go('/emergency'),
            child: Row(
              children: [
                Icon(Icons.air_rounded,
                    size: 14, color: AppColors.forest400),
                const SizedBox(width: 6),
                Text(l10n.zenMoreBreathingExercises,
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.forest600)),
                const SizedBox(width: 3),
                Icon(Icons.chevron_right_rounded,
                    size: 14, color: AppColors.forest500),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _FAB extends StatelessWidget {
  const _FAB({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        H.medium();
        onTap();
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.forest600,
          shape: BoxShape.circle,
          boxShadow: AppShadows.button,
        ),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
      ),
    );
  }
}

// Card used in the new-entry chooser sheet. Two of these stack: plain vs
// guided. Kept inline (not a separate file) because it's only used here.
class _EntryKindCard extends StatelessWidget {
  const _EntryKindCard({
    required this.icon,
    required this.tint,
    required this.border,
    required this.accent,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });
  final IconData icon;
  final Color tint;
  final Color border;
  final Color accent;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.lg,
      onTap: () {
        H.selection();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: tint,
          borderRadius: AppRadius.lg,
          border: Border.all(color: border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: border),
              ),
              child: Icon(icon, color: accent, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title,
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.stone800)),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(badge!,
                              style: AppTextStyles.labelSmall.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                letterSpacing: 0.4,
                              )),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone500, height: 1.4)),
                ],
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded,
                color: AppColors.stone400, size: 22),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: AppColors.stone200),
          const SizedBox(height: 14),
          Text(title,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.stone500)),
          const SizedBox(height: 6),
          Text(subtitle,
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone400)),
        ],
      ),
    );
  }
}
