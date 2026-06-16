// Daily Reflection template — the "guided page" alternative to a blank entry.
//
// The user reaches this screen from the journal tab's "+" button after
// picking "Daily reflection" in the kind chooser. It mirrors the look of
// classic planner-style daily pages (mood pills, gratitude lines, anchor
// checkboxes, wins, cravings, intention) but uses our recovery palette and
// language. On save we compose all the sections into a single formatted
// body string and persist as a normal JournalEntry tagged `reflection`, so
// it shows up alongside plain entries everywhere else.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import 'journal_shared.dart';

class JournalTemplateScreen extends ConsumerStatefulWidget {
  const JournalTemplateScreen({super.key});

  @override
  ConsumerState<JournalTemplateScreen> createState() =>
      _JournalTemplateScreenState();
}

class _JournalTemplateScreenState extends ConsumerState<JournalTemplateScreen> {
  // ── Section state ─────────────────────────────────────────────────────────
  String _mood = 'okay';

  // Three gratitude lines instead of free-form, to make the page feel like
  // a planner and lower the activation energy of filling it in.
  final _grat1 = TextEditingController();
  final _grat2 = TextEditingController();
  final _grat3 = TextEditingController();

  // Recovery "anchors" — actions that protect the streak. Checking these
  // generates auto-tags on the resulting entry so they're searchable later.
  // Keyed by a stable identifier so the on/off state and the slug/tag lookups
  // never depend on the (now localized) display label.
  final Map<String, bool> _anchors = {
    'reached_out': false,
    'meeting': false,
    'moved': false,
    'ate_hydrated': false,
    'meds': false,
    'avoided_trigger': false,
  };

  // Localized display label for each anchor identity key.
  String _anchorLabel(AppLocalizations l10n, String id) {
    switch (id) {
      case 'reached_out':
        return l10n.journalReflectionAnchorReachedOut;
      case 'meeting':
        return l10n.journalReflectionAnchorMeeting;
      case 'moved':
        return l10n.journalReflectionAnchorMoved;
      case 'ate_hydrated':
        return l10n.journalReflectionAnchorAteHydrated;
      case 'meds':
        return l10n.journalReflectionAnchorMeds;
      case 'avoided_trigger':
        return l10n.journalReflectionAnchorAvoidedTrigger;
      default:
        return id;
    }
  }

  final _wins = TextEditingController();
  final _cravings = TextEditingController();
  final _intention = TextEditingController();
  final _affirmation = TextEditingController();

  bool _saving = false;

  @override
  void dispose() {
    _grat1.dispose();
    _grat2.dispose();
    _grat3.dispose();
    _wins.dispose();
    _cravings.dispose();
    _intention.dispose();
    _affirmation.dispose();
    super.dispose();
  }

  // ── Save: assemble + persist ──────────────────────────────────────────────

  // We render the structured form into a single formatted text body so the
  // existing list / detail / search code works without modification.
  String _composeBody(AppLocalizations l10n) {
    final buf = StringBuffer();
    buf.writeln('🌿 ${l10n.journalReflectionTitle}');
    buf.writeln(DateFormat('EEEE, MMMM d, y').format(DateTime.now()));
    buf.writeln();

    final grats = [_grat1.text, _grat2.text, _grat3.text]
        .map((t) => t.trim())
        .where((t) => t.isNotEmpty)
        .toList();
    if (grats.isNotEmpty) {
      buf.writeln(l10n.journalReflectionBodyGratefulHeading);
      for (var i = 0; i < grats.length; i++) {
        buf.writeln('  ${i + 1}. ${grats[i]}');
      }
      buf.writeln();
    }

    final checked =
        _anchors.entries.where((e) => e.value).map((e) => e.key).toList();
    if (checked.isNotEmpty) {
      buf.writeln(l10n.journalReflectionBodyAnchorsHeading);
      for (final c in checked) {
        buf.writeln('  • ${_anchorLabel(l10n, c)}');
      }
      buf.writeln();
    }

    void section(String label, TextEditingController c) {
      final v = c.text.trim();
      if (v.isEmpty) return;
      buf.writeln(label);
      buf.writeln(v);
      buf.writeln();
    }

    section(l10n.journalReflectionBodyWinsHeading, _wins);
    section(l10n.journalReflectionBodyCravingsHeading, _cravings);
    section(l10n.journalReflectionBodyIntentionHeading, _intention);
    section(l10n.journalReflectionBodyAffirmationHeading, _affirmation);

    return buf.toString().trimRight();
  }

  // Auto-tags so a reflection is easy to filter for later. Each checked
  // anchor turns into a short hash-friendly tag.
  List<String> _autoTags() {
    final tags = <String>['reflection'];
    const slug = {
      'reached_out': 'connection',
      'meeting': 'meeting',
      'moved': 'exercise',
      'ate_hydrated': 'self-care',
      'meds': 'meds',
      'avoided_trigger': 'won-over-trigger',
    };
    for (final entry in _anchors.entries) {
      if (entry.value) tags.add(slug[entry.key] ?? '');
    }
    if (_cravings.text.trim().isNotEmpty) tags.add('craving');
    return tags.where((t) => t.isNotEmpty).toSet().toList();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    H.medium();
    final body = _composeBody(AppLocalizations.of(context));
    await ref.read(journalProvider.notifier).add(
          body,
          _mood,
          tags: _autoTags(),
        );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.cream,
        foregroundColor: AppColors.stone800,
        elevation: 0,
        title: Text(l10n.journalReflectionTitle,
            style:
                AppTextStyles.titleMedium.copyWith(color: AppColors.forest700)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: TextButton(
              onPressed: _saving ? null : _save,
              style: TextButton.styleFrom(
                backgroundColor: AppColors.forest600,
                foregroundColor: AppColors.onForest,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                  _saving
                      ? l10n.journalReflectionSaving
                      : l10n.commonSave,
                  style:
                      AppTextStyles.labelMedium.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 6, 18, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                DateFormat('EEEE, MMMM d').format(DateTime.now()),
                style:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
              ),
            ),
            const SizedBox(height: 14),

            // ── Mood ────────────────────────────────────────────────────
            _Section(
              tint: AppColors.mintChip,
              border: AppColors.forest100,
              title: l10n.journalReflectionMoodTitle,
              icon: Icons.sentiment_satisfied_alt_rounded,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: kMoodOptions.map((m) {
                  final selected = m.key == _mood;
                  return GestureDetector(
                    onTap: () {
                      H.selection();
                      setState(() => _mood = m.key);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            // ignore: deprecated_member_use
                            ? m.color.withOpacity(0.18)
                            : AppColors.cream,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: selected ? m.color : AppColors.forest100,
                          width: selected ? 1.4 : 1.0,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(m.icon, size: 16, color: m.color),
                          const SizedBox(width: 6),
                          Text(m.localizedLabel(l10n),
                              style: AppTextStyles.labelSmall
                                  .copyWith(color: m.color)),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // ── Gratitude (3 numbered lines) ────────────────────────────
            _Section(
              tint: AppColors.honey50,
              border: AppColors.honey100,
              title: l10n.journalReflectionGratefulTitle,
              icon: Icons.favorite_border_rounded,
              accent: AppColors.honey600,
              child: Column(
                children: [
                  _NumberedField(n: 1, controller: _grat1),
                  const SizedBox(height: 8),
                  _NumberedField(n: 2, controller: _grat2),
                  const SizedBox(height: 8),
                  _NumberedField(n: 3, controller: _grat3),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // ── Anchors (checkboxes for recovery actions) ───────────────
            _Section(
              tint: AppColors.mintChip,
              border: AppColors.forest100,
              title: l10n.journalReflectionAnchorsTitle,
              icon: Icons.anchor_rounded,
              child: Column(
                children: _anchors.keys.map((id) {
                  final on = _anchors[id] ?? false;
                  return InkWell(
                    onTap: () {
                      H.selection();
                      setState(() => _anchors[id] = !on);
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              color:
                                  on ? AppColors.forest600 : Colors.transparent,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: on
                                    ? AppColors.forest600
                                    : AppColors.forest300,
                                width: 1.4,
                              ),
                            ),
                            child: on
                                ? const Icon(Icons.check_rounded,
                                    size: 16, color: Colors.white)
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _anchorLabel(l10n, id),
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: on
                                    ? AppColors.stone800
                                    : AppColors.stone600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // ── Wins ────────────────────────────────────────────────────
            _Section(
              tint: AppColors.mintChip,
              border: AppColors.forest100,
              title: l10n.journalReflectionWinsTitle,
              icon: Icons.emoji_events_outlined,
              child: _TallField(
                controller: _wins,
                hint: l10n.journalReflectionWinsHint,
              ),
            ),
            const SizedBox(height: 12),

            // ── Cravings / triggers ─────────────────────────────────────
            _Section(
              tint: AppColors.blush50,
              border: AppColors.blush100,
              title: l10n.journalReflectionCravingsTitle,
              icon: Icons.bolt_outlined,
              accent: AppColors.blush600,
              child: _TallField(
                controller: _cravings,
                hint: l10n.journalReflectionCravingsHint,
              ),
            ),
            const SizedBox(height: 12),

            // ── Intention ───────────────────────────────────────────────
            _Section(
              tint: AppColors.mintChip,
              border: AppColors.forest100,
              title: l10n.journalReflectionIntentionTitle,
              icon: Icons.wb_twilight_rounded,
              child: _TallField(
                controller: _intention,
                hint: l10n.journalReflectionIntentionHint,
              ),
            ),
            const SizedBox(height: 12),

            // ── Affirmation ─────────────────────────────────────────────
            _Section(
              tint: AppColors.honey50,
              border: AppColors.honey100,
              title: l10n.journalReflectionAffirmationTitle,
              icon: Icons.auto_awesome_rounded,
              accent: AppColors.honey600,
              child: _TallField(
                controller: _affirmation,
                hint: l10n.journalReflectionAffirmationHint,
              ),
            ),
            const SizedBox(height: 22),

            Center(
              child: Text(
                l10n.journalReflectionFooter,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone400, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Small building blocks ──────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.tint,
    required this.border,
    required this.title,
    required this.icon,
    required this.child,
    this.accent,
  });
  final Color tint;
  final Color border;
  final String title;
  final IconData icon;
  final Color? accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ac = accent ?? AppColors.forest600;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: AppRadius.lg,
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: ac),
              const SizedBox(width: 8),
              Text(title,
                  style: AppTextStyles.labelMedium
                      .copyWith(color: ac, letterSpacing: 0.3)),
            ],
          ),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}

class _NumberedField extends StatelessWidget {
  const _NumberedField({required this.n, required this.controller});
  final int n;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: BoxDecoration(
            color: AppColors.honey100,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text('$n',
              style:
                  AppTextStyles.labelSmall.copyWith(color: AppColors.honey600)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextField(
            controller: controller,
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: AppColors.cream,
              hintText: '…',
              hintStyle:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: AppColors.honey100, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: AppColors.honey100, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide:
                    BorderSide(color: AppColors.honey300, width: 1.2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TallField extends StatelessWidget {
  const _TallField({required this.controller, required this.hint});
  final TextEditingController controller;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      minLines: 3,
      maxLines: 6,
      style: AppTextStyles.bodyMedium
          .copyWith(color: AppColors.stone800, height: 1.5),
      decoration: InputDecoration(
        filled: true,
        fillColor: AppColors.cream,
        hintText: hint,
        hintStyle: AppTextStyles.bodySmall
            .copyWith(color: AppColors.stone400, height: 1.5),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.forest100, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.forest100, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: AppColors.forest400, width: 1.2),
        ),
      ),
    );
  }
}
