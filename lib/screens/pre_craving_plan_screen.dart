import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Toolkit exercise options ─────────────────────────────────────────────────
// Curated exercises the user can quick-link to from their plan. Each has a
// display label, sub-label, icon, and a GoRouter route that opens it.

class _ToolkitExercise {
  const _ToolkitExercise({
    required this.label,
    required this.sub,
    required this.icon,
    required this.color,
    required this.route,
  });
  final String label;
  final String sub;
  final IconData icon;
  final Color color;
  final String route; // empty = no navigation (informational only)
}

final _kToolkitExercises = [
  _ToolkitExercise(
    label: 'Box Breathing',
    sub: 'Guided 4-4-4-4 breath cycle',
    icon: Icons.air_rounded,
    color: AppColors.forest500,
    route: '/emergency',
  ),
  _ToolkitExercise(
    label: '5-4-3-2-1 Grounding',
    sub: 'Ground yourself through your senses',
    icon: Icons.touch_app_rounded,
    color: AppColors.forest600,
    route: '/emergency',
  ),
  _ToolkitExercise(
    label: 'CBT Thought Reframe',
    sub: 'Challenge the craving thought',
    icon: Icons.psychology_outlined,
    color: AppColors.forest700,
    route: '/cbt',
  ),
  _ToolkitExercise(
    label: 'Affirmations',
    sub: 'Read a personal affirmation',
    icon: Icons.spa_outlined,
    color: AppColors.honey500,
    route: '/journal',
  ),
  _ToolkitExercise(
    label: 'Cold Water',
    sub: 'Splash cold water on your face',
    icon: Icons.water_drop_outlined,
    color: AppColors.forest400,
    route: '',
  ),
  _ToolkitExercise(
    label: 'Walk Outside',
    sub: 'Take a short walk to reset',
    icon: Icons.directions_walk_rounded,
    color: AppColors.forest500,
    route: '',
  ),
  _ToolkitExercise(
    label: 'Call Someone',
    sub: 'Reach out to your sponsor or a friend',
    icon: Icons.phone_outlined,
    color: AppColors.forest600,
    route: '',
  ),
  _ToolkitExercise(
    label: 'Body Scan',
    sub: 'Scan from toes to head, release tension',
    icon: Icons.self_improvement_rounded,
    color: AppColors.forest400,
    route: '/emergency',
  ),
];

// ─── Pre-craving plan ────────────────────────────────────────────────────────
//
// Three short steps the user pre-commits to running when a craving hits.
// Each step can optionally be linked to a Toolkit exercise that opens with
// one tap during the plan runner.

class PreCravingPlanScreen extends ConsumerStatefulWidget {
  const PreCravingPlanScreen({super.key});

  @override
  ConsumerState<PreCravingPlanScreen> createState() =>
      _PreCravingPlanScreenState();
}

class _PreCravingPlanScreenState extends ConsumerState<PreCravingPlanScreen> {
  late final List<TextEditingController> _ctrls;
  // 3 optionally-linked toolkit exercises (null = no link for that step)
  final List<_ToolkitExercise?> _linkedExercises = [null, null, null];
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
    final links = profile?.preCravingLinks ?? const <String>[];
    _ctrls = List.generate(
      3,
      (i) => TextEditingController(text: i < plan.length ? plan[i] : ''),
    );
    // Restore saved links
    for (var i = 0; i < 3 && i < links.length; i++) {
      if (links[i].isNotEmpty) {
        _linkedExercises[i] = _kToolkitExercises
            .cast<_ToolkitExercise?>()
            .firstWhere((e) => e?.route == links[i], orElse: () => null);
      }
    }
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
    final steps = _ctrls.map((c) => c.text.trim()).toList();
    final links = _linkedExercises.map((e) => e?.route ?? '').toList();
    await ref.read(profileProvider.notifier).patch(
          (p) => p.copyWith(preCravingPlan: steps, preCravingLinks: links),
        );
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

  Future<void> _pickExercise(int slot) async {
    H.selection();
    final picked = await showModalBottomSheet<_ToolkitExercise>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => const _ExercisePickerSheet(),
    );
    if (picked != null && mounted) {
      setState(() {
        _linkedExercises[slot] = picked;
        // Auto-fill text if the field is empty
        if (_ctrls[slot].text.trim().isEmpty) {
          _ctrls[slot].text = picked.label;
        }
        _dirty = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.stone50,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
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

            // ── Step inputs ────────────────────────────────────────────────
            SolidCard(
              borderRadius: AppRadius.xxl,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(3, (i) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: i == 2 ? 0 : 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              margin: const EdgeInsets.only(top: 6),
                              decoration: BoxDecoration(
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
                                textCapitalization:
                                    TextCapitalization.sentences,
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
                                    borderSide: BorderSide(
                                        color: AppColors.stone100),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: AppRadius.lg,
                                    borderSide: BorderSide(
                                        color: AppColors.stone100),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: AppRadius.lg,
                                    borderSide: BorderSide(
                                        color: AppColors.forest600, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // ── Toolkit exercise link ──────────────────────────
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 44),
                          child: _linkedExercises[i] != null
                              ? _ExerciseLinkChip(
                                  exercise: _linkedExercises[i]!,
                                  onRemove: () => setState(() {
                                    _linkedExercises[i] = null;
                                    _dirty = true;
                                  }),
                                )
                              : GestureDetector(
                                  onTap: () => _pickExercise(i),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.add_link_rounded,
                                          size: 15, color: AppColors.forest400),
                                      const SizedBox(width: 5),
                                      Text('Link a Toolkit exercise',
                                          style: AppTextStyles.labelSmall
                                              .copyWith(
                                                  color: AppColors.forest500)),
                                    ],
                                  ),
                                ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 12),

            // ── Toolkit exercise info ──────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.mintChip,
                borderRadius: AppRadius.lg,
                border: Border.all(color: AppColors.softBorder),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: AppColors.forest500),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Linking a Toolkit exercise adds a one-tap "Open" button during your plan so you can jump straight into the exercise.',
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.forest700, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _dirty ? _save : null,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.forest700,
                  foregroundColor: AppColors.onForest,
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

// ─── Exercise link chip ───────────────────────────────────────────────────────

class _ExerciseLinkChip extends StatelessWidget {
  const _ExerciseLinkChip({required this.exercise, required this.onRemove});
  final _ToolkitExercise exercise;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: exercise.color.withOpacity(0.08),
            borderRadius: AppRadius.full,
            // ignore: deprecated_member_use
            border: Border.all(color: exercise.color.withOpacity(0.3)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(exercise.icon, size: 14, color: exercise.color),
              const SizedBox(width: 5),
              Text(exercise.label,
                  style: TextStyle(
                    fontSize: 12,
                    color: exercise.color,
                    fontWeight: FontWeight.w500,
                  )),
            ],
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: Icon(Icons.close_rounded,
              size: 16, color: AppColors.stone400),
        ),
      ],
    );
  }
}

// ─── Exercise picker sheet ────────────────────────────────────────────────────

class _ExercisePickerSheet extends StatelessWidget {
  const _ExercisePickerSheet();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Choose a Toolkit Exercise',
                    style: AppTextStyles.titleLarge
                        .copyWith(color: AppColors.forest700)),
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: AppColors.stone100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 16, color: AppColors.stone500),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text('Tap to add a one-tap link to this exercise in your plan.',
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone400)),
          const SizedBox(height: 16),
          ..._kToolkitExercises.map((ex) => _ExerciseRow(exercise: ex)),
        ],
      ),
    );
  }
}

class _ExerciseRow extends StatelessWidget {
  const _ExerciseRow({required this.exercise});
  final _ToolkitExercise exercise;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        H.selection();
        Navigator.pop(context, exercise);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.stone50,
          borderRadius: AppRadius.lg,
          border: Border.all(color: AppColors.stone100),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                // ignore: deprecated_member_use
                color: exercise.color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(exercise.icon, size: 19, color: exercise.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(exercise.label,
                      style: AppTextStyles.titleSmall
                          .copyWith(color: AppColors.stone800)),
                  Text(exercise.sub,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone400)),
                ],
              ),
            ),
            if (exercise.route.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.forest50,
                  borderRadius: AppRadius.full,
                ),
                child: Text('Opens in app',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.forest600,
                        fontWeight: FontWeight.w500)),
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
  // Filter to non-empty steps only
  if (plan.every((s) => s.trim().isEmpty)) return false;
  final links = profile?.preCravingLinks ?? const <String>[];
  H.medium();
  final logAnyway = await showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _PlanRunnerSheet(steps: plan, links: links),
  );
  return logAnyway ?? false;
}

class _PlanRunnerSheet extends StatefulWidget {
  const _PlanRunnerSheet({required this.steps, this.links = const []});
  final List<String> steps;
  final List<String> links;

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
      decoration: BoxDecoration(
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
              style:
                  AppTextStyles.bodySmall.copyWith(color: AppColors.stone500)),
          const SizedBox(height: 16),
          ...List.generate(widget.steps.length, (i) {
            final step = widget.steps[i].trim();
            if (step.isEmpty) return const SizedBox.shrink();
            final checked = _done.contains(i);
            final link = i < widget.links.length ? widget.links[i] : '';
            // Find the matching toolkit exercise for its icon/colour
            final exercise = link.isNotEmpty
                ? _kToolkitExercises
                    .cast<_ToolkitExercise?>()
                    .firstWhere((e) => e?.route == link, orElse: () => null)
                : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    borderRadius: AppRadius.lg,
                    onTap: () {
                      H.selection();
                      setState(() => checked ? _done.remove(i) : _done.add(i));
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: checked ? AppColors.forest50 : AppColors.stone50,
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
                              step,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: checked
                                    ? AppColors.forest800
                                    : AppColors.stone700,
                                decoration:
                                    checked ? TextDecoration.lineThrough : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Open exercise button
                  if (exercise != null) ...[
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: GestureDetector(
                        onTap: () {
                          H.light();
                          final router = GoRouter.of(context);
                          Navigator.pop(context, false);
                          // Navigate after the sheet closes
                          Future.microtask(() => router.push(exercise.route));
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(exercise.icon,
                                size: 14, color: exercise.color),
                            const SizedBox(width: 5),
                            Text(
                              'Open ${exercise.label} →',
                              style: TextStyle(
                                fontSize: 12,
                                color: exercise.color,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
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
