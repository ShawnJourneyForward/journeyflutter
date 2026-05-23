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
    final entries = ref.watch(journalProvider);

    return entries.when(
      loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.forest600)),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (list) => Stack(
        children: [
          if (list.isEmpty)
            _EmptyState(
              icon: Icons.book_outlined,
              title: 'Your journal is empty',
              subtitle: 'Tap + to write your first entry',
            )
          else
            ListView.builder(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 100),
              itemCount: list.length,
              itemBuilder: (_, i) => _JournalCard(entry: list[i]),
            ),
          Positioned(
            right: 20,
            bottom: 24,
            child: _FAB(
              onTap: () => _showEntrySheet(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  void _showEntrySheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _JournalEntrySheet(
        onSave: (text, mood) =>
            ref.read(journalProvider.notifier).add(text, mood),
      ),
    );
  }
}

class _JournalCard extends ConsumerWidget {
  const _JournalCard({required this.entry});
  final JournalEntry entry;

  static const _moodData = {
    'great': (
      Icons.sentiment_very_satisfied_rounded,
      AppColors.forest600,
      'Great'
    ),
    'good': (Icons.sentiment_satisfied_rounded, AppColors.forest400, 'Good'),
    'okay': (Icons.sentiment_neutral_rounded, AppColors.honey500, 'Okay'),
    'hard': (Icons.sentiment_dissatisfied_rounded, AppColors.honey500, 'Hard'),
    'crisis': (
      Icons.sentiment_very_dissatisfied_rounded,
      AppColors.forest600,
      'Crisis'
    ),
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (icon, color, label) = _moodData[entry.mood] ??
        (Icons.sentiment_neutral_rounded, AppColors.stone400, 'Okay');

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
            const Icon(Icons.delete_outline_rounded, color: AppColors.honey500),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('Delete entry?',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.stone800)),
            content: Text('This cannot be undone.',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone500)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.stone500)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text('Delete',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.honey500)),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) => ref.read(journalProvider.notifier).delete(entry.id),
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
            Row(
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(label,
                    style: AppTextStyles.labelSmall.copyWith(color: color)),
                const Spacer(),
                Text(
                  _formatDate(entry.date),
                  style: AppTextStyles.bodySmall
                      .copyWith(color: AppColors.stone400),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              entry.text,
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone700),
              maxLines: 5,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final now = DateTime.now();
    if (dt.year == now.year && dt.month == now.month && dt.day == now.day) {
      return 'Today ${DateFormat('h:mm a').format(dt)}';
    }
    final yesterday = now.subtract(const Duration(days: 1));
    if (dt.year == yesterday.year &&
        dt.month == yesterday.month &&
        dt.day == yesterday.day) {
      return 'Yesterday';
    }
    return DateFormat('MMM d').format(dt);
  }
}

class _JournalEntrySheet extends StatefulWidget {
  const _JournalEntrySheet({required this.onSave});
  final void Function(String text, String mood) onSave;

  @override
  State<_JournalEntrySheet> createState() => _JournalEntrySheetState();
}

class _JournalEntrySheetState extends State<_JournalEntrySheet> {
  final _ctrl = TextEditingController();
  String _mood = 'okay';
  bool _listening = false;
  String _baseline = ''; // text already typed before mic was tapped

  static const _moods = [
    ('great', '😄', 'Great'),
    ('good', '🙂', 'Good'),
    ('okay', '😐', 'Okay'),
    ('hard', '😔', 'Hard'),
    ('crisis', '😰', 'Crisis'),
  ];

  @override
  void dispose() {
    if (_listening) VoiceInput.instance.cancel();
    _ctrl.dispose();
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
            'Voice input is unavailable. Check microphone permission in Settings.',
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

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: AppRadius.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text("Today's Entry",
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.forest700)),
              const Spacer(),
              IconButton(
                icon:
                    const Icon(Icons.close_rounded, color: AppColors.stone400),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Mood selector
          Text('How are you feeling?',
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.stone500)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _moods.map((m) {
              final (value, emoji, label) = m;
              final selected = _mood == value;
              return GestureDetector(
                onTap: () {
                  H.selection();
                  setState(() => _mood = value);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: selected ? AppColors.forest50 : Colors.transparent,
                    borderRadius: AppRadius.md,
                    border: Border.all(
                      color:
                          selected ? AppColors.forest200 : AppColors.stone100,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 20)),
                      const SizedBox(height: 2),
                      Text(label,
                          style: AppTextStyles.labelSmall.copyWith(
                            color: selected
                                ? AppColors.forest700
                                : AppColors.stone400,
                          )),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 16),
          Row(
            children: [
              Text('What\'s on your mind?',
                  style: AppTextStyles.labelMedium
                      .copyWith(color: AppColors.stone500)),
              const Spacer(),
              GestureDetector(
                onTap: _toggleListening,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                        _listening ? 'Stop' : 'Speak',
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
            maxLines: 6,
            minLines: 4,
            autofocus: true,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
            decoration: InputDecoration(
              hintText: 'Write freely — no one else will see this...',
              hintStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone300),
              filled: true,
              fillColor: AppColors.stone50,
              border: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide: const BorderSide(color: AppColors.stone100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide: const BorderSide(color: AppColors.stone100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.lg,
                borderSide:
                    const BorderSide(color: AppColors.forest400, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(14),
            ),
          ),

          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                final text = _ctrl.text.trim();
                if (text.isEmpty) return;
                widget.onSave(text, _mood);
                Navigator.pop(context);
                H.medium();
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest600,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
              ),
              child: Text('Save Entry',
                  style:
                      AppTextStyles.labelLarge.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
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
  List<String> _personalCards(String? name, List<String> gratitudes) {
    final out = <String>[];
    if (name != null && name.trim().isNotEmpty) {
      final n = name.trim();
      out.addAll([
        '$n, you are doing harder things than most people will ever try.',
        '$n, your sober self is the realest version of you.',
        '$n, this moment is enough. You are enough.',
        '$n, the version of you a year from now is rooting for today\'s you.',
      ]);
    }
    // Pull from recent gratitudes — turn the user's own words into a mirror.
    for (final g in gratitudes.take(3)) {
      final clean = g.trim();
      if (clean.length > 4 && clean.length < 80) {
        out.add('You wrote this: "$clean" — that\'s still true.');
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
            Text('Swipe for more affirmations',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone400)),

            const Divider(
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
                  Text('Your affirmations',
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
                        'Tap + to add your own',
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
          color: Colors.white,
          borderRadius: AppRadius.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Add Affirmation',
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
                hintText: 'I am...',
                hintStyle: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone300),
                filled: true,
                fillColor: AppColors.stone50,
                border: OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide: const BorderSide(color: AppColors.stone100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide: const BorderSide(color: AppColors.stone100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: AppRadius.lg,
                  borderSide:
                      const BorderSide(color: AppColors.forest400, width: 1.5),
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
                child: Text('Add',
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
          gradient: const LinearGradient(
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
            const Icon(Icons.format_quote_rounded,
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
                    isFavourite
                        ? Icons.spa_rounded
                        : Icons.spa_outlined,
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
        color: Colors.white,
        borderRadius: AppRadius.md,
        border: Border.all(color: AppColors.stone100),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 16, color: AppColors.honey400),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone700)),
          ),
          GestureDetector(
            onTap: onDelete,
            child: const Icon(Icons.close_rounded,
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
                    title: 'Nothing here yet',
                    subtitle: 'Try a different filter, or add a new dream.',
                  ),
                ),
              )
            else
              // One sliver per category section.
              ...byCategory.entries.expand((entry) {
                final info = categoryInfoFor(entry.key);
                final showHeader = byCategory.length > 1 ||
                    entry.key != VisionCategory.none;
                return [
                  if (showHeader)
                    SliverToBoxAdapter(
                      child: _SectionHeader(info: info, count: entry.value.length),
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
        padding:
            EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
        child: _VisionEditSheet(
          existingItem: item,
          starter: starter,
          onSave: (updated) =>
              ref.read(visionBoardProvider.notifier).add(updated),
          onUpdate: (updated) =>
              ref.read(visionBoardProvider.notifier).saveItem(updated),
          onDelete: item == null
              ? null
              : () =>
                  ref.read(visionBoardProvider.notifier).remove(item.id),
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
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
            decoration: const BoxDecoration(
              color: AppColors.forest100,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 22, color: AppColors.forest600),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Your Vision Board',
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.forest700)),
                Text(
                  total == 0
                      ? 'Visualise the life ahead of you'
                      : _subtitle(total, pinnedCount, achievedCount),
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

  String _subtitle(int total, int pinned, int achieved) {
    final parts = <String>[
      '$total dream${total == 1 ? '' : 's'}',
      if (pinned > 0) '$pinned pinned',
      if (achieved > 0) '$achieved achieved',
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _filterChip('All', allCount, _VisionFilter.all),
            const SizedBox(width: 8),
            _filterChip('Active', activeCount, _VisionFilter.active),
            const SizedBox(width: 8),
            _filterChip('Pinned', pinnedCount, _VisionFilter.pinned),
            const SizedBox(width: 8),
            _filterChip('Achieved', achievedCount, _VisionFilter.achieved),
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
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.stone400)),
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
              decoration: const BoxDecoration(
                color: AppColors.forest50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 34, color: AppColors.forest500),
            ),
          ),
          const SizedBox(height: 18),
          Center(
            child: Text(
              'What does your life ahead look like?',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.forest700),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 6),
          Center(
            child: Text(
              'Start with one of these — or tap + for a blank canvas.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.stone500),
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
                      const Icon(Icons.add_rounded,
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
              label: const Text('Start with a blank dream'),
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
                              const Icon(Icons.touch_app_outlined,
                                  size: 11, color: AppColors.stone300),
                              const SizedBox(width: 3),
                              Text('Tap to open',
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
                child: const Icon(Icons.push_pin,
                    size: 12, color: Colors.white),
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Remove this dream?',
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.stone800)),
        content: Text(item.title,
            style:
                AppTextStyles.bodySmall.copyWith(color: AppColors.stone500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Keep',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.stone500)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: Text('Remove',
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
    _affirmCtrl = TextEditingController(
        text: ex?.affirmation ?? st?.affirmation ?? '');
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
    final picked = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 85);
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
                    _isEdit ? 'Edit Dream' : 'Add a Dream',
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.forest700),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: AppColors.stone100,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded,
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
                      shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.lg),
                    ),
                    child: Text(
                      _isEdit ? 'Save Changes' : 'Add to Vision Board',
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
                        shape: RoundedRectangleBorder(
                            borderRadius: AppRadius.lg),
                      ),
                      child: Text('Remove this dream',
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Dream title'),
        const SizedBox(height: 6),
        TextField(
          controller: _titleCtrl,
          focusNode: _titleFocus,
          textInputAction: TextInputAction.next,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
          decoration: _fieldDecor(
              'e.g. Be more present for my family', Icons.title_rounded),
        ),
        const SizedBox(height: 14),

        _label('Notes (optional)'),
        const SizedBox(height: 6),
        TextField(
          controller: _descCtrl,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 2,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
          decoration:
              _fieldDecor('Anything to remember…', Icons.notes_rounded),
        ),
        const SizedBox(height: 14),

        _label('Why this matters (optional)'),
        const SizedBox(height: 6),
        TextField(
          controller: _whyCtrl,
          textInputAction: TextInputAction.newline,
          maxLines: 3,
          minLines: 2,
          style:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
          decoration: _fieldDecor(
              'When this matters most, why does it matter?',
              Icons.psychology_outlined),
        ),
        const SizedBox(height: 18),

        _label('Category'),
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
                        color:
                            selected ? info.color : AppColors.stone400),
                    const SizedBox(width: 6),
                    Text(info.label,
                        style: AppTextStyles.labelMedium.copyWith(
                            color: selected
                                ? info.color
                                : AppColors.stone600)),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 18),

        _label('Choose your icon'),
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
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.normal,
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

        _label('Target date (optional)'),
        const SizedBox(height: 6),
        InkWell(
          borderRadius: AppRadius.lg,
          onTap: _pickTargetDate,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.stone50,
              borderRadius: AppRadius.lg,
              border: Border.all(color: AppColors.stone100),
            ),
            child: Row(
              children: [
                const Icon(Icons.event_rounded,
                    size: 18, color: AppColors.stone400),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _targetDate == null
                        ? 'Pick a date to work toward'
                        : DateFormat.yMMMMd().format(_targetDate!),
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: _targetDate == null
                            ? AppColors.stone400
                            : AppColors.stone800),
                  ),
                ),
                if (_targetDate != null)
                  IconButton(
                    icon: const Icon(Icons.clear_rounded,
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Photos help you feel it (up to 4)'),
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
                  onRemove: () =>
                      setState(() => _imagePaths.removeAt(i)),
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
                    const Icon(Icons.add_photo_alternate_outlined,
                        size: 22, color: AppColors.stone400),
                    const SizedBox(width: 10),
                    Text(
                      _imagePaths.isEmpty
                          ? 'Add your first photo'
                          : 'Add another (${_imagePaths.length}/4)',
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
          'Photos are stored on this device only — they never leave your phone.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone400),
        ),
      ],
    );
  }

  // ── Tab: Milestones ──────────────────────────────────────────────────────
  Widget _buildMilestonesTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Small concrete steps'),
        const SizedBox(height: 6),
        Text(
          'Break the dream into 3–6 tiny wins. Check them off as life moves.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
        ),
        const SizedBox(height: 14),

        if (_milestones.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text('No steps yet — add one below.',
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
                        color: m.done
                            ? AppColors.stone400
                            : AppColors.stone800,
                        decoration: m.done
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded,
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
                    'e.g. Walk 20 minutes today', Icons.add_task_rounded),
              ),
            ),
            const SizedBox(width: 8),
            FilledButton(
              onPressed: _addMilestone,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest600,
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: AppRadius.lg),
              ),
              child: const Icon(Icons.add_rounded,
                  color: Colors.white, size: 18),
            ),
          ],
        ),
      ],
    );
  }

  // ── Tab: Affirmation ─────────────────────────────────────────────────────
  Widget _buildAffirmationTab() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label('Your present-tense reframe'),
        const SizedBox(height: 6),
        Text(
          '"I am…" beats "I want to…" — the brain hears it as already real.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _affirmCtrl,
          maxLines: 4,
          minLines: 3,
          textInputAction: TextInputAction.newline,
          style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.stone800, fontStyle: FontStyle.italic),
          decoration: _fieldDecor(
              'I am present, patient, and proud of how I show up.',
              Icons.format_quote_rounded),
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _suggestAffirmation,
            icon: const Icon(Icons.auto_awesome_rounded, size: 16),
            label: const Text('Suggest from title'),
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
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.stone300),
        prefixIcon: Icon(icon, size: 18, color: AppColors.stone300),
        filled: true,
        fillColor: AppColors.stone50,
        border: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: const BorderSide(color: AppColors.stone100),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide: const BorderSide(color: AppColors.stone100),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lg,
          borderSide:
              const BorderSide(color: AppColors.forest400, width: 1.5),
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
    const tabs = <(_SheetTab, IconData, String)>[
      (_SheetTab.vision, Icons.auto_awesome_rounded, 'Vision'),
      (_SheetTab.photo, Icons.image_outlined, 'Photos'),
      (_SheetTab.milestones, Icons.flag_outlined, 'Steps'),
      (_SheetTab.affirmation, Icons.format_quote_rounded, 'Affirm'),
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
                        color: selected
                            ? AppColors.forest700
                            : AppColors.stone500,
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
                    const Icon(Icons.format_quote_rounded,
                        size: 20, color: AppColors.forest400),
                    const SizedBox(width: 8),
                    Text(
                      'Today\'s Reflection',
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
            title: 'Morning Intention',
            icon: Icons.light_mode_outlined,
            color: AppColors.honey500,
            child: const _IntentionWidget(),
          ),

          const SizedBox(height: 16),

          // Evening reflection prompts
          _ZenSection(
            title: 'Reflection Prompts',
            icon: Icons.nights_stay_outlined,
            color: AppColors.forest600,
            child: const _ReflectionPrompts(),
          ),

          const SizedBox(height: 16),

          // Gratitude section
          _ZenSection(
            title: 'Three Good Things',
            icon: Icons.spa_outlined,
            color: AppColors.honey500,
            child: const _ThreeGoodThings(),
          ),

          const SizedBox(height: 16),

          // Breathing reminder
          _ZenSection(
            title: 'Mindful Moment',
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

  static const _prompts = [
    'Today I intend to…',
    'My focus for today is…',
    'I will show up for myself by…',
    'One thing I\'m grateful for right now is…',
  ];

  String get _hint {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    return _prompts[dayOfYear % _prompts.length];
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_saved) {
      return Row(
        children: [
          const Icon(Icons.check_circle_rounded,
              size: 18, color: AppColors.forest500),
          const SizedBox(width: 8),
          Expanded(
            child: Text(_ctrl.text,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone700)),
          ),
          GestureDetector(
            onTap: () => setState(() => _saved = false),
            child: const Icon(Icons.edit_outlined,
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
              hintText: _hint,
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
            child: Text('Set',
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

  static const _prompts = [
    'What went well today?',
    'What challenged me, and how did I handle it?',
    'What am I most proud of today?',
    'How did I take care of myself today?',
    'What would I do differently tomorrow?',
    'Who or what am I grateful for right now?',
    'What did I learn about myself today?',
    'How did I show up for my sobriety today?',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _prompts[_current],
          style: AppTextStyles.bodyMedium
              .copyWith(color: AppColors.stone600, height: 1.5),
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            H.selection();
            setState(() => _current = (_current + 1) % _prompts.length);
          },
          child: Row(
            children: [
              const Icon(Icons.refresh_rounded,
                  size: 16, color: AppColors.forest500),
              const SizedBox(width: 6),
              Text('Next prompt',
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
    return Column(
      children: List.generate(3, (i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(
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
                    hintText: 'Something good today…',
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

  static const _exercises = [
    (
      '5-4-3-2-1 Grounding',
      'Name 5 things you see, 4 you can touch, 3 you hear, 2 you smell, 1 you taste.',
      false,
    ),
    (
      'Box Breath',
      'Breathe in for 4, hold for 4, breathe out for 4, hold for 4. Repeat 4 times.',
      true, // has guided exercise in Toolkit
    ),
    (
      'Body Scan',
      'Close your eyes. Slowly scan from your toes to your head, releasing tension as you go.',
      false,
    ),
    (
      'Gratitude Breath',
      'With each inhale, think of something you\'re grateful for. With each exhale, let go of what doesn\'t serve you.',
      true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final dayOfYear =
        DateTime.now().difference(DateTime(DateTime.now().year)).inDays;
    final (title, desc, hasGuided) =
        _exercises[dayOfYear % _exercises.length];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.labelMedium
                .copyWith(color: AppColors.forest600)),
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
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: BoxDecoration(
                color: AppColors.forest50,
                borderRadius: AppRadius.md,
                border: Border.all(color: AppColors.forest200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.air_rounded,
                      size: 16, color: AppColors.forest600),
                  const SizedBox(width: 7),
                  Text('Open guided breathing in Your Toolkit',
                      style: AppTextStyles.labelSmall
                          .copyWith(color: AppColors.forest700)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right_rounded,
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
                const Icon(Icons.air_rounded,
                    size: 14, color: AppColors.forest400),
                const SizedBox(width: 6),
                Text('More breathing exercises in Your Toolkit',
                    style: AppTextStyles.labelSmall
                        .copyWith(color: AppColors.forest600)),
                const SizedBox(width: 3),
                const Icon(Icons.chevron_right_rounded,
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
