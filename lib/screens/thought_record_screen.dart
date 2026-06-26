import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../models/thought_record.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── CBT thought record (full version) ───────────────────────────────────────
//
// Therapist-style structured record: situation → automatic thought →
// distortion(s) → evidence for/against → reframe → mood delta. Distinct
// from the quick "what's in my head right now" ThoughtEntry log.

class ThoughtRecordScreen extends ConsumerWidget {
  const ThoughtRecordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(thoughtRecordProvider);
    final records = async.valueOrNull ?? [];

    return Scaffold(
      backgroundColor: AppColors.stone50,
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.forest700,
          foregroundColor: AppColors.onForest,
          elevation: 2,
          onPressed: () => _openEditor(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.trNewRecord),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 110),
          children: [
            const Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: EdgeInsets.only(left: 4),
                child: LuxuryBackButton(),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(l10n.trTitle,
                  style: AppTextStyles.greetingSerif.copyWith(
                      fontSize: 30,
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w400)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                l10n.trSubtitle,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500, height: 1.4),
              ),
            ),
            const SizedBox(height: 22),
            if (records.isEmpty)
              _EmptyState(onAdd: () => _openEditor(context, ref))
            else
              ...records.map((r) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _RecordCard(
                      record: r,
                      onDelete: () async {
                        H.light();
                        final ok = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            backgroundColor: AppColors.card,
                            shape: const RoundedRectangleBorder(
                                borderRadius: AppRadius.xxl),
                            title: Text(l10n.trDeleteTitle,
                                style: AppTextStyles.titleMedium),
                            actions: [
                              TextButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(false),
                                child: Text(l10n.commonCancel),
                              ),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.of(context).pop(true),
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.blush500),
                                child: Text(l10n.commonDelete),
                              ),
                            ],
                          ),
                        );
                        if (ok == true) {
                          await ref
                              .read(thoughtRecordProvider.notifier)
                              .remove(r.id);
                        }
                      },
                    ),
                  )),
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor(BuildContext context, WidgetRef ref) async {
    H.light();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _EditorSheet(),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
                color: AppColors.forest50, shape: BoxShape.circle),
            child: Icon(Icons.psychology_alt_outlined,
                size: 32, color: AppColors.forest600),
          ),
          const SizedBox(height: 16),
          Text(l10n.trEmptyTitle,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.forest700)),
          const SizedBox(height: 6),
          Text(
            l10n.trEmptyBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(l10n.trStartRecord),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forest700,
              foregroundColor: AppColors.onForest,
              shape: const RoundedRectangleBorder(borderRadius: AppRadius.pill),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({required this.record, required this.onDelete});
  final ThoughtRecord record;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final delta = (record.moodAfter != null && record.moodBefore != null)
        ? (record.moodAfter! - record.moodBefore!)
        : null;
    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(DateFormat('EEE d MMM · HH:mm').format(record.date),
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone500)),
              const Spacer(),
              if (delta != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: delta >= 0 ? AppColors.forest50 : AppColors.honey50,
                    borderRadius: AppRadius.pill,
                  ),
                  child: Text(
                    l10n.trMoodDelta(delta >= 0 ? '+$delta' : '$delta'),
                    style: AppTextStyles.caption.copyWith(
                      color:
                          delta >= 0 ? AppColors.forest700 : AppColors.honey600,
                      fontSize: 10,
                    ),
                  ),
                ),
              IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline_rounded,
                    color: AppColors.stone400, size: 18),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (record.situation.isNotEmpty) ...[
            _MiniLabel(l10n.trLabelSituation),
            Text(record.situation,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone700)),
            const SizedBox(height: 10),
          ],
          _MiniLabel(l10n.trLabelAutoThought),
          Text('"${record.automaticThought}"',
              style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.stone800, fontStyle: FontStyle.italic)),
          if (record.distortions.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: record.distortions
                  .map((c) => CognitiveDistortion.byCode(c)?.localizedName(l10n))
                  .whereType<String>()
                  .map((name) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.honey50,
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(name,
                            style: AppTextStyles.caption.copyWith(
                                color: AppColors.honey600, fontSize: 10)),
                      ))
                  .toList(),
            ),
          ],
          if (record.reframe.isNotEmpty) ...[
            const SizedBox(height: 12),
            _MiniLabel(l10n.trLabelReframe),
            Text(record.reframe,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.forest700)),
          ],
        ],
      ),
    );
  }
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 2),
        child: Text(text.toUpperCase(),
            style: AppTextStyles.overline
                .copyWith(color: AppColors.stone400, fontSize: 9)),
      );
}

// ─── Editor sheet (multi-step) ───────────────────────────────────────────────

class _EditorSheet extends ConsumerStatefulWidget {
  const _EditorSheet();

  @override
  ConsumerState<_EditorSheet> createState() => _EditorSheetState();
}

class _EditorSheetState extends ConsumerState<_EditorSheet> {
  final _situation = TextEditingController();
  final _thought = TextEditingController();
  final _evidenceFor = TextEditingController();
  final _evidenceAgainst = TextEditingController();
  final _reframe = TextEditingController();
  final Set<String> _distortions = {};
  int _moodBefore = 5;
  int _moodAfter = 5;
  int _step = 0;
  bool _saving = false;

  static const _stepCount = 5;

  @override
  void dispose() {
    _situation.dispose();
    _thought.dispose();
    _evidenceFor.dispose();
    _evidenceAgainst.dispose();
    _reframe.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    if (_thought.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.trCatchFirst,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.stone600,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _saving = true);
    H.medium();
    await ref.read(thoughtRecordProvider.notifier).add(ThoughtRecord(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          date: DateTime.now(),
          situation: _situation.text.trim(),
          automaticThought: _thought.text.trim(),
          distortions: _distortions.toList(),
          evidenceFor: _evidenceFor.text.trim(),
          evidenceAgainst: _evidenceAgainst.text.trim(),
          reframe: _reframe.text.trim(),
          moodBefore: _moodBefore,
          moodAfter: _moodAfter,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: AppColors.stone200,
                  borderRadius: AppRadius.pill,
                ),
              ),
            ),
            LinearProgressIndicator(
              value: (_step + 1) / _stepCount,
              backgroundColor: AppColors.stone100,
              color: AppColors.forest600,
              minHeight: 4,
            ),
            const SizedBox(height: 14),
            ConstrainedBox(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.55),
              child: SingleChildScrollView(child: _buildStep()),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                if (_step > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _saving
                          ? null
                          : () {
                              H.selection();
                              setState(() => _step--);
                            },
                      child: Text(l10n.commonBack),
                    ),
                  ),
                if (_step > 0) const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: _saving
                        ? null
                        : () {
                            if (_step < _stepCount - 1) {
                              H.selection();
                              setState(() => _step++);
                            } else {
                              _save();
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest700,
                      minimumSize: const Size.fromHeight(50),
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.lg),
                    ),
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2.4),
                          )
                        : Text(
                            _step == _stepCount - 1
                                ? l10n.trSaveRecord
                                : l10n.commonNext,
                            style: AppTextStyles.labelLarge
                                .copyWith(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep() {
    final l10n = AppLocalizations.of(context);
    switch (_step) {
      case 0:
        return _StepBlock(
          title: l10n.trStep0Title,
          subtitle: l10n.trStep0Sub,
          child: _field(_situation, hint: l10n.trStep0Hint),
        );
      case 1:
        return _StepBlock(
          title: l10n.trStep1Title,
          subtitle: l10n.trStep1Sub,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(_thought, hint: l10n.trStep1Hint),
              const SizedBox(height: 14),
              Text(l10n.trMoodNow,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone500)),
              Slider(
                value: _moodBefore.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: l10n.trMoodScale(_moodBefore),
                onChanged: (v) => setState(() => _moodBefore = v.round()),
              ),
            ],
          ),
        );
      case 2:
        return _StepBlock(
          title: l10n.trStep2Title,
          subtitle: l10n.trStep2Sub,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: CognitiveDistortion.all.map((d) {
              final sel = _distortions.contains(d.code);
              return GestureDetector(
                onTap: () {
                  H.selection();
                  setState(() {
                    sel
                        ? _distortions.remove(d.code)
                        : _distortions.add(d.code);
                  });
                },
                onLongPress: () {
                  showDialog<void>(
                    context: context,
                    builder: (_) => AlertDialog(
                      backgroundColor: AppColors.card,
                      shape: const RoundedRectangleBorder(
                          borderRadius: AppRadius.xxl),
                      title: Text(d.localizedName(l10n),
                          style: AppTextStyles.titleSmall
                              .copyWith(color: AppColors.forest700)),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.localizedDescription(l10n),
                              style: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.stone700)),
                          const SizedBox(height: 12),
                          Text(l10n.trTryAsking,
                              style: AppTextStyles.caption
                                  .copyWith(color: AppColors.stone500)),
                          const SizedBox(height: 4),
                          Text(d.localizedReframePrompt(l10n),
                              style: AppTextStyles.bodyMedium.copyWith(
                                  color: AppColors.forest700,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text(l10n.commonGotIt),
                        ),
                      ],
                    ),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.forest700 : AppColors.card,
                    borderRadius: AppRadius.pill,
                    border: Border.all(
                      color: sel ? AppColors.forest700 : AppColors.stone200,
                    ),
                  ),
                  child: Text(d.localizedName(l10n),
                      style: AppTextStyles.labelMedium.copyWith(
                          color: sel ? Colors.white : AppColors.stone600)),
                ),
              );
            }).toList(),
          ),
        );
      case 3:
        return _StepBlock(
          title: l10n.trStep3Title,
          subtitle: l10n.trStep3Sub,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.trEvidenceFor,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone500)),
              const SizedBox(height: 4),
              _field(_evidenceFor, hint: l10n.trEvidenceForHint),
              const SizedBox(height: 12),
              Text(l10n.trEvidenceAgainst,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone500)),
              const SizedBox(height: 4),
              _field(_evidenceAgainst, hint: l10n.trEvidenceAgainstHint),
            ],
          ),
        );
      case 4:
        return _StepBlock(
          title: l10n.trStep4Title,
          subtitle: l10n.trStep4Sub,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _field(_reframe, hint: l10n.trStep4Hint),
              const SizedBox(height: 14),
              Text(l10n.trMoodAfter,
                  style: AppTextStyles.caption
                      .copyWith(color: AppColors.stone500)),
              Slider(
                value: _moodAfter.toDouble(),
                min: 1,
                max: 10,
                divisions: 9,
                label: l10n.trMoodScale(_moodAfter),
                onChanged: (v) => setState(() => _moodAfter = v.round()),
              ),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _field(TextEditingController c, {required String hint}) => TextField(
        controller: c,
        maxLines: 4,
        minLines: 2,
        textCapitalization: TextCapitalization.sentences,
        style: AppTextStyles.bodyMedium.copyWith(color: AppColors.stone800),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle:
              AppTextStyles.bodyMedium.copyWith(color: AppColors.stone300),
          filled: true,
          fillColor: AppColors.stone50,
          contentPadding: const EdgeInsets.all(12),
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
                BorderSide(color: AppColors.forest600, width: 1.5),
          ),
        ),
      );
}

class _StepBlock extends StatelessWidget {
  const _StepBlock(
      {required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title,
            style: AppTextStyles.titleLarge
                .copyWith(color: AppColors.forest700, fontSize: 22)),
        const SizedBox(height: 4),
        Text(subtitle,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500)),
        const SizedBox(height: 14),
        child,
      ],
    );
  }
}
