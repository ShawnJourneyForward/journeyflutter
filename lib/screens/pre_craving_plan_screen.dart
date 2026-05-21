import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Pre-craving plan ────────────────────────────────────────────────────────
//
// Three short steps the user pre-commits to running when a craving hits.
// Surfaces *before* the craving log, not after — the goal is to interrupt
// the impulse with a remembered plan, not analyse it afterwards.

class PreCravingPlanScreen extends ConsumerStatefulWidget {
  const PreCravingPlanScreen({super.key});

  @override
  ConsumerState<PreCravingPlanScreen> createState() =>
      _PreCravingPlanScreenState();
}

class _PreCravingPlanScreenState extends ConsumerState<PreCravingPlanScreen> {
  late final List<TextEditingController> _ctrls;
  bool _dirty = false;

  static const _hints = [
    'e.g. Take three slow box-breaths',
    'e.g. Drink a glass of cold water',
    'e.g. Text my sponsor: "Craving"',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider).valueOrNull;
    final plan = profile?.preCravingPlan ?? const <String>[];
    _ctrls = List.generate(
      3,
      (i) => TextEditingController(text: i < plan.length ? plan[i] : ''),
    );
    for (final c in _ctrls) {
      c.addListener(() => setState(() => _dirty = true));
    }
  }

  @override
  void dispose() {
    for (final c in _ctrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    H.medium();
    final steps = _ctrls
        .map((c) => c.text.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    await ref
        .read(profileProvider.notifier)
        .patch((p) => p.copyWith(preCravingPlan: steps));
    if (mounted) {
      setState(() => _dirty = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Plan saved — you\'ll see it when a craving hits.',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.forest600,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
              child: Text('Pre-craving plan',
                  style: AppTextStyles.greetingSerif.copyWith(
                      fontSize: 30,
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w400)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Three things you commit to doing the moment a craving hits — written in calm so you don\'t have to think in a storm.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500, height: 1.4),
              ),
            ),
            const SizedBox(height: 22),
            SolidCard(
              borderRadius: AppRadius.xxl,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(3, (i) {
                  return Padding(
                    padding:
                        EdgeInsets.only(bottom: i == 2 ? 0 : 14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          margin: const EdgeInsets.only(top: 6),
                          decoration: const BoxDecoration(
                            color: AppColors.forest50,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text('${i + 1}',
                                style: AppTextStyles.labelMedium.copyWith(
                                    color: AppColors.forest700,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: _ctrls[i],
                            maxLines: 2,
                            minLines: 1,
                            textCapitalization: TextCapitalization.sentences,
                            style: AppTextStyles.bodyMedium
                                .copyWith(color: AppColors.stone800),
                            decoration: InputDecoration(
                              hintText: _hints[i],
                              hintStyle: AppTextStyles.bodyMedium
                                  .copyWith(color: AppColors.stone300),
                              filled: true,
                              fillColor: AppColors.stone50,
                              contentPadding: const EdgeInsets.all(12),
                              border: OutlineInputBorder(
                                borderRadius: AppRadius.lg,
                                borderSide: const BorderSide(
                                    color: AppColors.stone100),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: AppRadius.lg,
                                borderSide: const BorderSide(
                                    color: AppColors.stone100),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: AppRadius.lg,
                                borderSide: const BorderSide(
                                    color: AppColors.forest600, width: 1.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _dirty ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest700,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.stone200,
                  disabledForegroundColor: AppColors.stone500,
                  minimumSize: const Size.fromHeight(52),
                  shape:
                      const RoundedRectangleBorder(borderRadius: AppRadius.lg),
                ),
                child: Text(_dirty ? 'Save plan' : 'Saved',
                    style:
                        AppTextStyles.labelLarge.copyWith(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Plan-runner sheet (surfaces from craving log) ───────────────────────────
//
// Shown by the craving log button BEFORE the log UI opens. Lets the user
// run through their plan first; if it works, they don't need to log. If it
// doesn't, "I still want to log" continues to the normal craving sheet.

Future<bool> showPreCravingPlan(BuildContext context, WidgetRef ref) async {
  final profile = ref.read(profileProvider).valueOrNull;
  final plan = profile?.preCravingPlan ?? const <String>[];
  if (plan.isEmpty) return false;
  H.medium();
  final logAnyway = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlanRunnerSheet(steps: plan),
  );
  return logAnyway ?? false;
}

class _PlanRunnerSheet extends StatefulWidget {
  const _PlanRunnerSheet({required this.steps});
  final List<String> steps;

  @override
  State<_PlanRunnerSheet> createState() => _PlanRunnerSheetState();
}

class _PlanRunnerSheetState extends State<_PlanRunnerSheet> {
  final _done = <int>{};

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 80),
      padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
      decoration: const BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: AppColors.stone200,
                borderRadius: AppRadius.pill,
              ),
            ),
          ),
          Text('Your plan',
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.forest700)),
          const SizedBox(height: 4),
          Text('Run through these before logging. Breathe between each one.',
              style: AppTextStyles.bodySmall
                  .copyWith(color: AppColors.stone500)),
          const SizedBox(height: 16),
          ...List.generate(widget.steps.length, (i) {
            final checked = _done.contains(i);
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: AppRadius.lg,
                onTap: () {
                  H.selection();
                  setState(() {
                    checked ? _done.remove(i) : _done.add(i);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: checked
                        ? AppColors.forest50
                        : AppColors.stone50,
                    borderRadius: AppRadius.lg,
                    border: Border.all(
                      color: checked
                          ? AppColors.forest200
                          : AppColors.stone100,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        checked
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: checked
                            ? AppColors.forest600
                            : AppColors.stone400,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.steps[i],
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: checked
                                ? AppColors.forest800
                                : AppColors.stone700,
                            decoration: checked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    H.light();
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('I\'m okay'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    H.medium();
                    Navigator.of(context).pop(true);
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.forest700),
                  child: const Text('Still log it'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
