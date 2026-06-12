// Two short, structured bottom-sheets that surface key daily / weekly
// practices the app's clinical foundation depends on:
//
//   • IntentionSheet — Morning: write a single sentence intention.
//                       Evening: review how that intention played out.
//   • RecoveryCapitalSheet — once-a-week 5-tap check across the five
//                              dimensions of Kelly & White's recovery
//                              capital framework.
//
// Both sheets are intentionally small. Recovery practice is more useful
// when the rituals are short enough that the user actually does them.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Daily Intention sheet ───────────────────────────────────────────────────

/// Single entry point — opens the right pane based on the time of day OR
/// the existence of today's intention. Morning (or "no intention yet")
/// → write pane. Afternoon/evening + intention exists + not yet reviewed
/// → review pane. Otherwise → confirmation card.
class IntentionSheet extends ConsumerStatefulWidget {
  const IntentionSheet({super.key});

  @override
  ConsumerState<IntentionSheet> createState() => _IntentionSheetState();
}

class _IntentionSheetState extends ConsumerState<IntentionSheet> {
  final _ctrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill with today's existing intention so the user can edit, not
    // re-type. Watched via initState (not build) because edits to the
    // controller while the provider rebuilds would clobber typed text.
    final t = ref.read(todaysIntentionProvider);
    if (t != null) _ctrl.text = t.text;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _saveIntention() async {
    if (_ctrl.text.trim().isEmpty || _saving) return;
    setState(() => _saving = true);
    H.medium();
    await ref.read(intentionProvider.notifier).setToday(_ctrl.text);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _saveReview(String outcome) async {
    H.medium();
    await ref.read(intentionProvider.notifier).reviewToday(outcome);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final today = ref.watch(todaysIntentionProvider);
    final now = DateTime.now();
    // Heuristic: after 16:00 local, if an intention exists and hasn't been
    // reviewed, show the review pane. Otherwise show write/edit.
    final showReview = today != null && today.outcome == null && now.hour >= 16;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.stone200,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 14),
          if (showReview)
            _ReviewPane(intention: today, onReview: _saveReview)
          else
            _WritePane(
              controller: _ctrl,
              saving: _saving,
              alreadySet: today != null,
              onSave: _saveIntention,
            ),
        ],
      ),
    );
  }
}

class _WritePane extends StatelessWidget {
  const _WritePane({
    required this.controller,
    required this.saving,
    required this.alreadySet,
    required this.onSave,
  });
  final TextEditingController controller;
  final bool saving;
  final bool alreadySet;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          alreadySet ? 'Edit today\'s intention' : 'Set today\'s intention',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.forest700),
        ),
        const SizedBox(height: 4),
        Text(
          'One small thing for your recovery today.',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          autofocus: true,
          maxLength: 120,
          maxLines: 3,
          minLines: 2,
          style: AppTextStyles.bodyLarge
              .copyWith(color: AppColors.stone800, height: 1.4, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'e.g. Call my sponsor before noon.',
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
            filled: true,
            fillColor: AppColors.stone50,
            counterText: '',
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.forest100),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.forest100),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.forest400, width: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: saving ? null : onSave,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forest600,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.lg),
            ),
            child: Text(
              saving ? 'Saving…' : 'Save intention',
              style: AppTextStyles.labelMedium.copyWith(color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewPane extends StatelessWidget {
  const _ReviewPane({required this.intention, required this.onReview});
  final DailyIntention intention;
  final void Function(String outcome) onReview;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'How did today go?',
          style: AppTextStyles.titleLarge.copyWith(color: AppColors.forest700),
        ),
        const SizedBox(height: 4),
        Text(
          'This morning you said:',
          style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.mintChip,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.forest100),
          ),
          child: Text(
            '"${intention.text}"',
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.forest700,
              height: 1.4,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            _ReviewPill(
              icon: Icons.eco_rounded,
              label: 'Did it',
              color: AppColors.forest600,
              onTap: () => onReview('did'),
            ),
            const SizedBox(width: 8),
            _ReviewPill(
              icon: Icons.timelapse_rounded,
              label: 'Partly',
              color: AppColors.honey500,
              onTap: () => onReview('partly'),
            ),
            const SizedBox(width: 8),
            _ReviewPill(
              icon: Icons.bedtime_outlined,
              label: 'Not yet',
              color: AppColors.stone500,
              onTap: () => onReview('not_yet'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ReviewPill extends StatelessWidget {
  const _ReviewPill({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          H.selection();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: color.withOpacity(0.10),
            borderRadius: BorderRadius.circular(12),
            // ignore: deprecated_member_use
            border: Border.all(color: color.withOpacity(0.40)),
          ),
          child: Column(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(height: 6),
              Text(
                label,
                style: AppTextStyles.labelMedium.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Recovery Capital weekly check ───────────────────────────────────────────

class RecoveryCapitalSheet extends ConsumerStatefulWidget {
  const RecoveryCapitalSheet({super.key});

  @override
  ConsumerState<RecoveryCapitalSheet> createState() =>
      _RecoveryCapitalSheetState();
}

class _RecoveryCapitalSheetState extends ConsumerState<RecoveryCapitalSheet> {
  // Pre-fill from this week's existing entry, if any, so the user can revise.
  bool _connected = false;
  bool _physical = false;
  bool _slept = false;
  bool _helpfulPlace = false;
  bool _meaningful = false;
  final _noteCtrl = TextEditingController();
  bool _loaded = false;
  bool _saving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    final w = ref.read(thisWeekCapitalProvider);
    if (w != null) {
      _connected = w.connected;
      _physical = w.physical;
      _slept = w.slept;
      _helpfulPlace = w.helpfulPlace;
      _meaningful = w.meaningful;
      if (w.note != null) _noteCtrl.text = w.note!;
    }
  }

  @override
  void dispose() {
    _noteCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    setState(() => _saving = true);
    H.medium();
    await ref.read(recoveryCapitalProvider.notifier).setCurrentWeek(
          connected: _connected,
          physical: _physical,
          slept: _slept,
          helpfulPlace: _helpfulPlace,
          meaningful: _meaningful,
          note: _noteCtrl.text,
        );
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final weekStart = today.subtract(Duration(days: today.weekday - 1));
    final weekEnd = weekStart.add(const Duration(days: 6));

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.stone200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Recovery capital this week',
              style:
                  AppTextStyles.titleLarge.copyWith(color: AppColors.forest700),
            ),
            const SizedBox(height: 4),
            Text(
              '${DateFormat('MMM d').format(weekStart)} – ${DateFormat('MMM d').format(weekEnd)}',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
            ),
            const SizedBox(height: 18),
            _CapitalRow(
              icon: Icons.people_outline_rounded,
              label: 'Connected with someone supportive',
              value: _connected,
              onChanged: (v) => setState(() => _connected = v),
            ),
            _CapitalRow(
              icon: Icons.directions_walk_rounded,
              label: 'Moved my body',
              value: _physical,
              onChanged: (v) => setState(() => _physical = v),
            ),
            _CapitalRow(
              icon: Icons.bedtime_outlined,
              label: 'Slept enough most nights',
              value: _slept,
              onChanged: (v) => setState(() => _slept = v),
            ),
            _CapitalRow(
              icon: Icons.park_outlined,
              label: 'Spent time somewhere that helps me',
              value: _helpfulPlace,
              onChanged: (v) => setState(() => _helpfulPlace = v),
            ),
            _CapitalRow(
              icon: Icons.auto_awesome_outlined,
              label: 'Did something meaningful to me',
              value: _meaningful,
              onChanged: (v) => setState(() => _meaningful = v),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.stone800, height: 1.4),
              decoration: InputDecoration(
                hintText: 'A note for future-you (optional)',
                hintStyle:
                    AppTextStyles.bodySmall.copyWith(color: AppColors.stone400),
                filled: true,
                fillColor: AppColors.stone50,
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.forest100),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AppColors.forest100),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide:
                      BorderSide(color: AppColors.forest400, width: 1.2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest600,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape:
                      const RoundedRectangleBorder(borderRadius: AppRadius.lg),
                ),
                child: Text(
                  _saving ? 'Saving…' : 'Save this week',
                  style:
                      AppTextStyles.labelMedium.copyWith(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CapitalRow extends StatelessWidget {
  const _CapitalRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        H.selection();
        onChanged(!value);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Icon(icon,
                size: 20,
                color: value ? AppColors.forest600 : AppColors.stone400),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: value ? AppColors.stone800 : AppColors.stone600,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.forest600 : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value ? AppColors.forest600 : AppColors.stone300,
                  width: 1.4,
                ),
              ),
              child: value
                  ? const Icon(Icons.check_rounded,
                      size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
