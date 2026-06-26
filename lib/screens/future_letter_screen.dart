import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../l10n/app_localizations.dart';
import '../models/future_letter.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';

// ─── Letters to your future self ─────────────────────────────────────────────
//
// Write a sealed letter to yourself at day 1; open it on day 30/90/365 (or
// a custom day) of your sobriety streak. Letters sit in a list — already
// unlocked ones tap-open with a soft reveal; locked ones show a countdown.

class FutureLetterScreen extends ConsumerWidget {
  const FutureLetterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(futureLetterProvider);
    final letters = async.valueOrNull ?? [];
    final now = DateTime.now();
    final unlocked = letters.where((l) => l.unlockedAt(now)).toList();
    final sealed = letters.where((l) => !l.unlockedAt(now)).toList();

    return Scaffold(
      backgroundColor: AppColors.stone50,
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.forest700,
          foregroundColor: AppColors.onForest,
          elevation: 2,
          onPressed: () => _openWriter(context, ref),
          icon: const Icon(Icons.edit_outlined),
          label: Text(l10n.letterWrite),
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
              child: Text(l10n.letterTitle,
                  style: AppTextStyles.greetingSerif.copyWith(
                      fontSize: 30,
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w400)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                l10n.letterSubtitle,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500, height: 1.4),
              ),
            ),
            const SizedBox(height: 22),
            if (letters.isEmpty)
              _EmptyState(onWrite: () => _openWriter(context, ref))
            else ...[
              if (unlocked.isNotEmpty) ...[
                _SectionLabel('${l10n.letterReady} · ${unlocked.length}'),
                const SizedBox(height: 10),
                ...unlocked.map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LetterCard(
                        letter: l,
                        onTap: () => _openLetter(context, ref, l),
                      ),
                    )),
                const SizedBox(height: 14),
              ],
              if (sealed.isNotEmpty) ...[
                _SectionLabel('${l10n.letterSealed} · ${sealed.length}'),
                const SizedBox(height: 10),
                ...sealed.map((l) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _LetterCard(letter: l, onTap: null),
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openWriter(BuildContext context, WidgetRef ref) async {
    H.light();
    final profile = ref.read(profileProvider).valueOrNull;
    final soberDate = profile == null
        ? DateTime.now()
        : (DateTime.tryParse(profile.soberDate) ?? DateTime.now());
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _WriterSheet(soberDate: soberDate),
    );
  }

  Future<void> _openLetter(
      BuildContext context, WidgetRef ref, FutureLetter letter) async {
    if (!letter.opened) {
      await ref.read(futureLetterProvider.notifier).markOpened(letter.id);
    }
    if (!context.mounted) return;
    H.medium();
    await showDialog<void>(
      context: context,
      builder: (_) => _LetterReader(letter: letter),
    );
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onWrite});
  final VoidCallback onWrite;

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
                color: AppColors.honey50, shape: BoxShape.circle),
            child: Icon(Icons.mail_outline_rounded,
                size: 32, color: AppColors.honey600),
          ),
          const SizedBox(height: 16),
          Text(l10n.letterEmptyTitle,
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.forest700)),
          const SizedBox(height: 6),
          Text(
            l10n.letterEmptyBody,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onWrite,
            icon: const Icon(Icons.edit_outlined, size: 18),
            label: Text(l10n.letterWrite),
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

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          text.toUpperCase(),
          style: AppTextStyles.overline.copyWith(
            color: AppColors.stone500,
            letterSpacing: 1.2,
          ),
        ),
      );
}

// ─── Letter card ─────────────────────────────────────────────────────────────

class _LetterCard extends StatelessWidget {
  const _LetterCard({required this.letter, required this.onTap});
  final FutureLetter letter;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isSealed = onTap == null;
    final now = DateTime.now();
    final daysToGo = letter.unlockAt.difference(now).inDays;
    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xxl,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isSealed ? AppColors.stone100 : AppColors.honey50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isSealed
                      ? Icons.lock_outline_rounded
                      : Icons.mark_email_unread_outlined,
                  color: isSealed ? AppColors.stone400 : AppColors.honey600,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isSealed
                          ? l10n.letterSealedUntil(letter.unlockDay)
                          : l10n.letterOpenMe(letter.unlockDay),
                      style: AppTextStyles.titleSmall.copyWith(
                          color: isSealed
                              ? AppColors.stone500
                              : AppColors.forest700),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isSealed
                          ? '${daysToGo == 0 ? l10n.letterTomorrow : l10n.letterDaysToGo(daysToGo)} · ${l10n.letterWritten(DateFormat('d MMM').format(letter.writtenAt))}'
                          : letter.opened
                              ? l10n.letterAlreadyRead
                              : l10n.letterNewSeal,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.stone500),
                    ),
                  ],
                ),
              ),
              if (!isSealed)
                Icon(Icons.chevron_right_rounded,
                    color: AppColors.stone300),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Letter reader dialog ────────────────────────────────────────────────────

class _LetterReader extends StatelessWidget {
  const _LetterReader({required this.letter});
  final FutureLetter letter;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Dialog(
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
      insetPadding: const EdgeInsets.all(20),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.mark_email_read_outlined,
                    color: AppColors.honey600),
                const SizedBox(width: 8),
                Text(l10n.letterFromPast(letter.unlockDay),
                    style: AppTextStyles.titleSmall
                        .copyWith(color: AppColors.forest700)),
                const Spacer(),
                IconButton(
                  icon: Icon(Icons.close, color: AppColors.stone400),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.letterWrittenFull(
                  DateFormat('EEE d MMM yyyy').format(letter.writtenAt)),
              style: AppTextStyles.caption.copyWith(color: AppColors.stone500),
            ),
            const SizedBox(height: 16),
            Flexible(
              child: SingleChildScrollView(
                child: Text(
                  letter.body,
                  style: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone800, height: 1.55),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Writer sheet ────────────────────────────────────────────────────────────

class _WriterSheet extends ConsumerStatefulWidget {
  const _WriterSheet({required this.soberDate});
  final DateTime soberDate;

  @override
  ConsumerState<_WriterSheet> createState() => _WriterSheetState();
}

class _WriterSheetState extends ConsumerState<_WriterSheet> {
  final _ctrl = TextEditingController();
  int _day = 30;
  bool _saving = false;

  static const _presets = [30, 90, 365];

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final body = _ctrl.text.trim();
    if (body.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(l10n.letterWriteFirst,
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.stone600,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _saving = true);
    H.medium();
    final unlockAt = widget.soberDate.add(Duration(days: _day));
    await ref.read(futureLetterProvider.notifier).add(FutureLetter(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          writtenAt: DateTime.now(),
          unlockAt: unlockAt,
          unlockDay: _day,
          body: body,
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final unlockOn = widget.soberDate.add(Duration(days: _day));
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
        child: SingleChildScrollView(
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
              Text(l10n.letterWriterTitle,
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.forest700)),
              const SizedBox(height: 8),
              Text(
                l10n.letterUnlocks(
                    _day, DateFormat('EEE d MMM yyyy').format(unlockOn)),
                style:
                    AppTextStyles.caption.copyWith(color: AppColors.stone500),
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  ..._presets.map((d) {
                    final sel = _day == d;
                    return GestureDetector(
                      onTap: () {
                        H.selection();
                        setState(() => _day = d);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: sel ? AppColors.forest700 : AppColors.card,
                          borderRadius: AppRadius.pill,
                          border: Border.all(
                            color:
                                sel ? AppColors.forest700 : AppColors.stone200,
                          ),
                        ),
                        child: Text(l10n.letterDayChip(d),
                            style: AppTextStyles.labelMedium.copyWith(
                                color:
                                    sel ? Colors.white : AppColors.stone600)),
                      ),
                    );
                  }),
                  GestureDetector(
                    onTap: () async {
                      H.selection();
                      final picked = await showDialog<int>(
                        context: context,
                        builder: (_) => const _CustomDayPicker(),
                      );
                      if (picked != null) setState(() => _day = picked);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: AppRadius.pill,
                        border: Border.all(color: AppColors.stone200),
                      ),
                      child: Text(l10n.letterCustom,
                          style: AppTextStyles.labelMedium
                              .copyWith(color: AppColors.stone600)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _ctrl,
                maxLines: 10,
                minLines: 6,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone800),
                decoration: InputDecoration(
                  hintText: l10n.letterBodyHint,
                  hintStyle: AppTextStyles.bodyMedium
                      .copyWith(color: AppColors.stone300),
                  filled: true,
                  fillColor: AppColors.stone50,
                  contentPadding: const EdgeInsets.all(14),
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
                        color: AppColors.forest600, width: 1.5),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest700,
                    foregroundColor: AppColors.onForest,
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
                      : Text(l10n.letterSeal,
                          style: AppTextStyles.labelLarge
                              .copyWith(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CustomDayPicker extends StatefulWidget {
  const _CustomDayPicker();

  @override
  State<_CustomDayPicker> createState() => _CustomDayPickerState();
}

class _CustomDayPickerState extends State<_CustomDayPicker> {
  int _value = 180;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
      title: Text(l10n.letterCustomDayTitle, style: AppTextStyles.titleMedium),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.letterCustomDaysFromSober(_value),
              style:
                  AppTextStyles.bodyMedium.copyWith(color: AppColors.stone600)),
          Slider(
            value: _value.toDouble(),
            min: 7,
            max: 1825, // 5 years
            divisions: 1818,
            label: l10n.commonDays(_value),
            onChanged: (v) => setState(() => _value = v.round()),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.commonCancel,
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.stone500)),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_value),
          style: FilledButton.styleFrom(backgroundColor: AppColors.forest700),
          child: Text(l10n.letterUseDay(_value),
              style: AppTextStyles.labelMedium
                  .copyWith(color: AppColors.onForest)),
        ),
      ],
    );
  }
}
