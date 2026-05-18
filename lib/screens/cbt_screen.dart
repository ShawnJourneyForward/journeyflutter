import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/glass_card.dart';
import '../components/luxury_widgets.dart';
import '../l10n/app_localizations.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';

// ─── CBT Thought Reframe Screen ───────────────────────────────────────────────

class CbtScreen extends ConsumerStatefulWidget {
  const CbtScreen({super.key});

  @override
  ConsumerState<CbtScreen> createState() => _CbtScreenState();
}

class _CbtScreenState extends ConsumerState<CbtScreen> {
  int _step = 0;

  final _thoughtCtrl   = TextEditingController();
  final _evidenceForCtrl   = TextEditingController();
  final _evidenceAgainstCtrl = TextEditingController();
  final _reframeCtrl   = TextEditingController();

  String? _selectedDistortion;
  bool _saving = false;
  bool _saved  = false;

  @override
  void dispose() {
    _thoughtCtrl.dispose();
    _evidenceForCtrl.dispose();
    _evidenceAgainstCtrl.dispose();
    _reframeCtrl.dispose();
    super.dispose();
  }

  bool get _canAdvance {
    return switch (_step) {
      0 => _thoughtCtrl.text.trim().isNotEmpty,
      1 => _selectedDistortion != null,
      2 => _evidenceAgainstCtrl.text.trim().isNotEmpty,
      3 => _reframeCtrl.text.trim().isNotEmpty,
      _ => true,
    };
  }

  void _next() {
    if (!_canAdvance) return;
    HapticFeedback.selectionClick();
    setState(() => _step++);
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    HapticFeedback.selectionClick();
    setState(() => _step--);
  }

  Future<void> _save() async {
    final thought = _thoughtCtrl.text.trim();
    final reframe = _reframeCtrl.text.trim();
    if (thought.isEmpty || reframe.isEmpty) return;

    setState(() => _saving = true);
    HapticFeedback.mediumImpact();

    // Save original thought as negative, reframe as positive
    await ref.read(thoughtProvider.notifier).add(
          thought,
          'negative',
          strength: _selectedDistortion,
          notes: 'Reframe: $reframe',
        );

    setState(() {
      _saving = false;
      _saved  = true;
    });
  }

  void _reset() {
    _thoughtCtrl.clear();
    _evidenceForCtrl.clear();
    _evidenceAgainstCtrl.clear();
    _reframeCtrl.clear();
    setState(() {
      _step = 0;
      _selectedDistortion = null;
      _saved = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: Stack(
          children: [
            const Positioned(
              top: -6,
              right: -18,
              child: IgnorePointer(
                child: BotanicalBackground(width: 150, height: 92),
              ),
            ),
            Column(
              children: [

                // ── Header ─────────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 14, 24, 0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: _back,
                        icon: const Icon(Icons.arrow_back_ios_new_rounded,
                            size: 20, color: AppColors.forest700),
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(l10n.cbtScreenTitle,
                            style: AppTextStyles.greetingSerif),
                      ),
                      if (_step < 4 && !_saved)
                        Text(
                          l10n.cbtStepIndicator(_step + 1),
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.stone400),
                        ),
                    ],
                  ),
                ),

                // ── Step progress bar ───────────────────────────────────────
                if (_step < 4 && !_saved) ...[
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: ClipRRect(
                      borderRadius: AppRadius.pill,
                      child: LinearProgressIndicator(
                        value: (_step + 1) / 4,
                        minHeight: 4,
                        backgroundColor: AppColors.stone100,
                        valueColor: const AlwaysStoppedAnimation(
                            AppColors.forest600),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 8),

                // ── Content ─────────────────────────────────────────────────
                Expanded(
                  child: _saved
                      ? _buildSaved()
                      : _step == 0
                          ? _buildStep0()
                          : _step == 1
                              ? _buildStep1()
                              : _step == 2
                                  ? _buildStep2()
                                  : _step == 3
                                      ? _buildStep3()
                                      : _buildSummary(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 0: Capture the thought ───────────────────────────────────────────

  Widget _buildStep0() {
    final l10n = AppLocalizations.of(context);
    return _StepShell(
      title: l10n.cbtStep0Title,
      subtitle: l10n.cbtStep0Subtitle,
      onNext: _next,
      canNext: _thoughtCtrl.text.trim().isNotEmpty,
      child: Column(
        children: [
          TextField(
            controller: _thoughtCtrl,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.cbtStep0HintText,
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.stone400),
              filled: true,
              fillColor: AppColors.stone50,
              border: OutlineInputBorder(
                borderRadius: AppRadius.xl,
                borderSide: const BorderSide(color: AppColors.stone100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.xl,
                borderSide: const BorderSide(color: AppColors.stone100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.xl,
                borderSide: const BorderSide(
                    color: AppColors.forest600, width: 1.5),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 16),
          LuxuryCard(
            backgroundColor: AppColors.mintChip,
            padding: const EdgeInsets.all(14),
            child: Text(
              l10n.cbtEducation,
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.forest700, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 1: Identify the pattern ──────────────────────────────────────────

  Widget _buildStep1() {
    final l10n = AppLocalizations.of(context);
    final distortions = [
      _Distortion(label: l10n.cbtDistortionAllOrNothing,      example: l10n.cbtDistortionAllOrNothingExample),
      _Distortion(label: l10n.cbtDistortionCatastrophising,   example: l10n.cbtDistortionCatastrophisingExample),
      _Distortion(label: l10n.cbtDistortionMindReading,       example: l10n.cbtDistortionMindReadingExample),
      _Distortion(label: l10n.cbtDistortionEmotionalReasoning,example: l10n.cbtDistortionEmotionalReasoningExample),
      _Distortion(label: l10n.cbtDistortionShouldStatements,  example: l10n.cbtDistortionShouldStatementsExample),
      _Distortion(label: l10n.cbtDistortionPersonalisation,   example: l10n.cbtDistortionPersonalisationExample),
      _Distortion(label: l10n.cbtDistortionOvergeneralisation,example: l10n.cbtDistortionOvergeneralisationExample),
      _Distortion(label: l10n.cbtDistortionNoneOfAbove,       example: l10n.cbtDistortionNoneOfAboveExample),
    ];
    return _StepShell(
      title: l10n.cbtStep1Title,
      subtitle: l10n.cbtStep1Subtitle,
      onNext: _next,
      canNext: _selectedDistortion != null,
      child: Column(
        children: distortions.map((d) {
          final selected = _selectedDistortion == d.label;
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedDistortion = d.label);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? AppColors.mintChip : AppColors.card,
                  borderRadius: AppRadius.xl,
                  border: Border.all(
                    color: selected
                        ? AppColors.forest400
                        : AppColors.stone100,
                    width: selected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.label,
                              style: AppTextStyles.titleSmall.copyWith(
                                  color: selected
                                      ? AppColors.forest700
                                      : AppColors.stone800)),
                          const SizedBox(height: 3),
                          Text(d.example,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.stone500,
                                  fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                    if (selected)
                      const Icon(Icons.check_circle_rounded,
                          size: 18, color: AppColors.forest600),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Step 2: Test the evidence ─────────────────────────────────────────────

  Widget _buildStep2() {
    final l10n = AppLocalizations.of(context);
    return _StepShell(
      title: l10n.cbtStep2Title,
      subtitle: l10n.cbtStep2Subtitle,
      onNext: _next,
      canNext: _evidenceAgainstCtrl.text.trim().isNotEmpty,
      child: Column(
        children: [
          _EvidenceField(
            controller: _evidenceForCtrl,
            label: l10n.cbtEvidenceForLabel,
            hint: l10n.cbtEvidenceForHint,
            color: AppColors.honey500,
          ),
          const SizedBox(height: 14),
          _EvidenceField(
            controller: _evidenceAgainstCtrl,
            label: l10n.cbtEvidenceAgainstLabel,
            hint: l10n.cbtEvidenceAgainstHint,
            color: AppColors.forest600,
            onChanged: () => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ── Step 3: Write the reframe ─────────────────────────────────────────────

  Widget _buildStep3() {
    final l10n = AppLocalizations.of(context);
    return _StepShell(
      title: l10n.cbtStep3Title,
      subtitle: l10n.cbtStep3Subtitle,
      onNext: _next,
      canNext: _reframeCtrl.text.trim().isNotEmpty,
      nextLabel: l10n.cbtReviewButton,
      child: Column(
        children: [
          SolidCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.cbtOriginalThoughtLabel,
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.stone400)),
                const SizedBox(height: 6),
                Text(_thoughtCtrl.text.trim(),
                    style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.stone600,
                        fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _reframeCtrl,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: l10n.cbtReframeHintText,
              hintStyle: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.stone400),
              filled: true,
              fillColor: AppColors.stone50,
              border: OutlineInputBorder(
                borderRadius: AppRadius.xl,
                borderSide: const BorderSide(color: AppColors.stone100),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: AppRadius.xl,
                borderSide: const BorderSide(color: AppColors.stone100),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: AppRadius.xl,
                borderSide: const BorderSide(
                    color: AppColors.forest600, width: 1.5),
              ),
            ),
            onChanged: (_) => setState(() {}),
          ),
        ],
      ),
    );
  }

  // ── Summary ───────────────────────────────────────────────────────────────

  Widget _buildSummary() {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      children: [
        LuxuryCard(
          backgroundColor: AppColors.forest800,
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  color: AppColors.honey300, size: 24),
              const SizedBox(height: 12),
              Text(l10n.cbtSummaryTitle,
                  style: AppTextStyles.labelSmall
                      .copyWith(color: AppColors.forest300, letterSpacing: 1)),
              const SizedBox(height: 8),
              Text(_reframeCtrl.text.trim(),
                  style: AppTextStyles.headlineSerif.copyWith(
                      color: Colors.white, fontSize: 18, height: 1.5)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SolidCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SummaryRow(
                label: l10n.cbtOriginalThoughtLabel,
                value: _thoughtCtrl.text.trim(),
              ),
              const Divider(height: 24),
              _SummaryRow(
                label: l10n.cbtPatternIdentifiedLabel,
                value: _selectedDistortion ?? '—',
              ),
              if (_evidenceForCtrl.text.trim().isNotEmpty) ...[
                const Divider(height: 24),
                _SummaryRow(
                  label: l10n.cbtEvidenceForSummaryLabel,
                  value: _evidenceForCtrl.text.trim(),
                ),
              ],
              const Divider(height: 24),
              _SummaryRow(
                label: l10n.cbtEvidenceAgainstSummaryLabel,
                value: _evidenceAgainstCtrl.text.trim(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _reset,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  side: const BorderSide(color: AppColors.stone200),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.lg),
                ),
                child: Text(l10n.cbtStartOverButton,
                    style: AppTextStyles.labelLarge
                        .copyWith(color: AppColors.stone600)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest600,
                  minimumSize: const Size.fromHeight(48),
                  shape: const RoundedRectangleBorder(
                      borderRadius: AppRadius.lg),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text(l10n.cbtSaveToJournalButton,
                        style: AppTextStyles.labelLarge
                            .copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Saved ─────────────────────────────────────────────────────────────────

  Widget _buildSaved() {
    final l10n = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: AppColors.forest600, size: 52),
            const SizedBox(height: 20),
            Text(l10n.cbtSavedTitle,
                style: AppTextStyles.displaySmall
                    .copyWith(color: AppColors.forest700)),
            const SizedBox(height: 12),
            Text(
              l10n.cbtSavedMessage,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium
                  .copyWith(color: AppColors.stone600, height: 1.6),
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _reset,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.forest600,
                minimumSize: const Size(200, 48),
                shape: const RoundedRectangleBorder(
                    borderRadius: AppRadius.lg),
              ),
              child: Text(l10n.cbtReframeAnotherButton,
                  style: AppTextStyles.labelLarge
                      .copyWith(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Step shell ───────────────────────────────────────────────────────────────

class _StepShell extends StatelessWidget {
  const _StepShell({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.onNext,
    required this.canNext,
    this.nextLabel,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final VoidCallback onNext;
  final bool canNext;
  final String? nextLabel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = nextLabel ?? l10n.cbtNextButton;
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
      children: [
        Text(title, style: AppTextStyles.displaySmall),
        const SizedBox(height: 8),
        Text(subtitle,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.stone600, height: 1.55)),
        const SizedBox(height: 22),
        child,
        const SizedBox(height: 24),
        FilledButton(
          onPressed: canNext ? onNext : null,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.forest600,
            disabledBackgroundColor: AppColors.stone100,
            minimumSize: const Size.fromHeight(52),
            shape: const RoundedRectangleBorder(
                borderRadius: AppRadius.lg),
          ),
          child: Text(label,
              style: AppTextStyles.labelLarge
                  .copyWith(color: canNext ? Colors.white : AppColors.stone400)),
        ),
      ],
    );
  }
}

// ─── Evidence field ───────────────────────────────────────────────────────────

class _EvidenceField extends StatelessWidget {
  const _EvidenceField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.color,
    this.onChanged,
  });
  final TextEditingController controller;
  final String label;
  final String hint;
  final Color color;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(label, style: AppTextStyles.titleSmall),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          onChanged: (_) => onChanged?.call(),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle:
                AppTextStyles.bodyMedium.copyWith(color: AppColors.stone400),
          ),
        ),
      ],
    );
  }
}

// ─── Summary row ──────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.caption),
        const SizedBox(height: 6),
        Text(value,
            style: AppTextStyles.bodyMedium
                .copyWith(color: AppColors.stone700, height: 1.5)),
      ],
    );
  }
}

// ─── Cognitive distortion data ────────────────────────────────────────────────

class _Distortion {
  const _Distortion({required this.label, required this.example});
  final String label;
  final String example;
}
