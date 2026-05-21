import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../components/back_button.dart';
import '../components/glass_card.dart';
import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import '../utils/notification_service.dart';

// ─── Meetings Screen ─────────────────────────────────────────────────────────
//
// User-managed schedule for recovery meetings (AA/NA/SMART), sponsor calls,
// therapy sessions, etc. Each meeting is persisted locally (no cloud) and
// can fire an optional one-shot reminder N minutes before it starts.

class MeetingsScreen extends ConsumerWidget {
  const MeetingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(meetingsProvider);
    final all = async.valueOrNull ?? [];
    final now = DateTime.now();
    final upcoming = all.where((m) => m.dateTime.isAfter(now)).toList();
    final past = all
        .where((m) => !m.dateTime.isAfter(now))
        .toList()
        .reversed
        .toList();

    return Scaffold(
      backgroundColor: AppColors.stone50,
      floatingActionButton: SafeArea(
        child: FloatingActionButton.extended(
          backgroundColor: AppColors.forest700,
          foregroundColor: Colors.white,
          elevation: 2,
          onPressed: () => _openEditor(context, ref),
          icon: const Icon(Icons.add_rounded),
          label: const Text('New meeting'),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 96),
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
              child: Text('Meetings',
                  style: AppTextStyles.greetingSerif.copyWith(
                      fontSize: 32,
                      color: AppColors.forestDark,
                      fontWeight: FontWeight.w400)),
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Text(
                'Plan recovery meetings, sponsor calls, and therapy sessions. Get a quiet reminder before each one.',
                style: AppTextStyles.bodyMedium
                    .copyWith(color: AppColors.stone500, height: 1.4),
              ),
            ),
            const SizedBox(height: 22),
            if (all.isEmpty)
              _EmptyState(onAdd: () => _openEditor(context, ref))
            else ...[
              if (upcoming.isNotEmpty) ...[
                _SectionLabel('Upcoming · ${upcoming.length}'),
                const SizedBox(height: 10),
                ...upcoming.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _MeetingCard(
                        meeting: m,
                        onTap: () => _openEditor(context, ref, existing: m),
                        onDelete: () => _confirmDelete(context, ref, m),
                      ),
                    )),
                const SizedBox(height: 12),
              ],
              if (past.isNotEmpty) ...[
                _SectionLabel('Past · ${past.length}'),
                const SizedBox(height: 10),
                ...past.map((m) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Opacity(
                        opacity: 0.6,
                        child: _MeetingCard(
                          meeting: m,
                          onTap: () =>
                              _openEditor(context, ref, existing: m),
                          onDelete: () => _confirmDelete(context, ref, m),
                        ),
                      ),
                    )),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    WidgetRef ref, {
    Meeting? existing,
  }) async {
    H.light();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MeetingEditorSheet(existing: existing),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    Meeting m,
  ) async {
    H.light();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.xxl),
        title: Text('Delete meeting?', style: AppTextStyles.titleMedium),
        content: Text(
          'This will remove "${m.title}" from your schedule.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.stone500)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.blush500),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style:
                    AppTextStyles.labelMedium.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
    if (ok != true) return;
    await NotificationService.cancelMeetingReminder(m.id);
    await ref.read(meetingsProvider.notifier).remove(m.id);
  }
}

// ─── Empty state ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
                color: AppColors.forest50, shape: BoxShape.circle),
            child: const Icon(Icons.event_available_outlined,
                size: 32, color: AppColors.forest600),
          ),
          const SizedBox(height: 16),
          Text('No meetings yet',
              style: AppTextStyles.titleMedium
                  .copyWith(color: AppColors.forest700)),
          const SizedBox(height: 6),
          Text(
            'Tap "New meeting" to schedule your first one. We\'ll quietly remind you before it starts.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone500),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text('Add meeting'),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.forest700,
              foregroundColor: Colors.white,
              shape:
                  const RoundedRectangleBorder(borderRadius: AppRadius.pill),
              padding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section label ───────────────────────────────────────────────────────────

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

// ─── Meeting card ────────────────────────────────────────────────────────────

class _MeetingCard extends StatelessWidget {
  const _MeetingCard({
    required this.meeting,
    required this.onTap,
    required this.onDelete,
  });
  final Meeting meeting;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final dayLabel = DateFormat('EEE d MMM').format(meeting.dateTime);
    final timeLabel = DateFormat('HH:mm').format(meeting.dateTime);
    return SolidCard(
      borderRadius: AppRadius.xxl,
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.xxl,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date chip
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.forest50,
                  borderRadius: AppRadius.lg,
                  border: Border.all(color: AppColors.forest100),
                ),
                child: Column(
                  children: [
                    Text(
                      DateFormat('MMM').format(meeting.dateTime).toUpperCase(),
                      style: AppTextStyles.overline.copyWith(
                          color: AppColors.forest600,
                          fontSize: 10,
                          letterSpacing: 1.1),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      meeting.dateTime.day.toString(),
                      style: AppTextStyles.titleLarge.copyWith(
                          color: AppColors.forestDark,
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              // Body
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(meeting.title,
                        style: AppTextStyles.titleSmall
                            .copyWith(color: AppColors.forest700)),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded,
                            size: 14, color: AppColors.stone400),
                        const SizedBox(width: 4),
                        Text('$dayLabel · $timeLabel',
                            style: AppTextStyles.bodySmall
                                .copyWith(color: AppColors.stone500)),
                      ],
                    ),
                    if (meeting.location != null &&
                        meeting.location!.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 14, color: AppColors.stone400),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              meeting.location!,
                              style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.stone500),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (meeting.notify) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: AppColors.mintChip,
                          borderRadius: AppRadius.pill,
                        ),
                        child: Text(
                          '🔔 ${_formatReminder(meeting.reminderMinutesBefore)} before',
                          style: AppTextStyles.caption.copyWith(
                              color: AppColors.forest700, fontSize: 10),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              IconButton(
                onPressed: onDelete,
                tooltip: 'Delete',
                icon: const Icon(Icons.delete_outline_rounded,
                    color: AppColors.stone400, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatReminder(int minutes) {
    if (minutes >= 1440) {
      final d = minutes ~/ 1440;
      return d == 1 ? '1 day' : '$d days';
    }
    if (minutes >= 60) {
      final h = minutes ~/ 60;
      return h == 1 ? '1 hour' : '$h hours';
    }
    return '$minutes min';
  }
}

// ─── Editor sheet (add / edit) ───────────────────────────────────────────────

class _MeetingEditorSheet extends ConsumerStatefulWidget {
  const _MeetingEditorSheet({this.existing});
  final Meeting? existing;

  @override
  ConsumerState<_MeetingEditorSheet> createState() =>
      _MeetingEditorSheetState();
}

class _MeetingEditorSheetState extends ConsumerState<_MeetingEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _notesCtrl;
  late DateTime _dateTime;
  late bool _notify;
  late int _reminderMinutes;
  bool _saving = false;

  static const _reminderOptions = [
    (5, '5 min'),
    (15, '15 min'),
    (30, '30 min'),
    (60, '1 hour'),
    (1440, '1 day'),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _titleCtrl = TextEditingController(text: e?.title ?? '');
    _locationCtrl = TextEditingController(text: e?.location ?? '');
    _notesCtrl = TextEditingController(text: e?.notes ?? '');
    _dateTime = e?.dateTime ??
        DateTime.now().add(const Duration(hours: 1)).copyWith(
              minute: 0,
              second: 0,
              millisecond: 0,
              microsecond: 0,
            );
    _notify = e?.notify ?? true;
    _reminderMinutes = e?.reminderMinutesBefore ?? 15;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _locationCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    H.selection();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 5)),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(
        picked.year,
        picked.month,
        picked.day,
        _dateTime.hour,
        _dateTime.minute,
      );
    });
  }

  Future<void> _pickTime() async {
    H.selection();
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _dateTime = DateTime(
        _dateTime.year,
        _dateTime.month,
        _dateTime.day,
        picked.hour,
        picked.minute,
      );
    });
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please give your meeting a name',
            style: AppTextStyles.bodySmall.copyWith(color: Colors.white)),
        backgroundColor: AppColors.blush500,
        behavior: SnackBarBehavior.floating,
      ));
      return;
    }
    setState(() => _saving = true);
    H.medium();
    final id =
        widget.existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
    final meeting = Meeting(
      id: id,
      title: title,
      dateTime: _dateTime,
      location: _locationCtrl.text.trim().isEmpty
          ? null
          : _locationCtrl.text.trim(),
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      notify: _notify,
      reminderMinutesBefore: _reminderMinutes,
    );
    final notifier = ref.read(meetingsProvider.notifier);
    if (widget.existing == null) {
      await notifier.add(meeting);
    } else {
      await notifier.edit(meeting);
    }
    if (_notify) {
      await NotificationService.scheduleMeetingReminder(
        meetingId: meeting.id,
        title: meeting.title,
        when: meeting.dateTime,
        minutesBefore: meeting.reminderMinutesBefore,
        location: meeting.location,
      );
    } else {
      await NotificationService.cancelMeetingReminder(meeting.id);
    }
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;
    final dayLabel = DateFormat('EEE d MMM yyyy').format(_dateTime);
    final timeLabel = DateFormat('HH:mm').format(_dateTime);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 60),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 28),
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
              Text(isEdit ? 'Edit meeting' : 'New meeting',
                  style: AppTextStyles.titleLarge
                      .copyWith(color: AppColors.forest700)),
              const SizedBox(height: 16),

              // Title
              _LabeledField(
                label: 'Name',
                child: TextField(
                  controller: _titleCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _fieldDecoration('e.g. AA Monday night'),
                ),
              ),
              const SizedBox(height: 14),

              // Date + time
              Row(
                children: [
                  Expanded(
                    child: _LabeledField(
                      label: 'Date',
                      child: _PickerTile(
                        icon: Icons.calendar_today_rounded,
                        label: dayLabel,
                        onTap: _pickDate,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _LabeledField(
                      label: 'Time',
                      child: _PickerTile(
                        icon: Icons.schedule_rounded,
                        label: timeLabel,
                        onTap: _pickTime,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Location
              _LabeledField(
                label: 'Where (optional)',
                child: TextField(
                  controller: _locationCtrl,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _fieldDecoration('Zoom, church hall, etc.'),
                ),
              ),
              const SizedBox(height: 14),

              // Notes
              _LabeledField(
                label: 'Notes (optional)',
                child: TextField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: _fieldDecoration('Anything to remember'),
                ),
              ),
              const SizedBox(height: 18),

              // Notify toggle
              SolidCard(
                borderRadius: AppRadius.xl,
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 4),
                child: SwitchListTile.adaptive(
                  contentPadding: EdgeInsets.zero,
                  value: _notify,
                  activeColor: AppColors.forest600,
                  onChanged: (v) {
                    H.selection();
                    setState(() => _notify = v);
                  },
                  title: Text('Remind me before',
                      style: AppTextStyles.titleSmall),
                  subtitle: Text(
                    _notify
                        ? 'A quiet notification will fire ${_reminderLabel()} early.'
                        : 'No reminder will be sent.',
                    style: AppTextStyles.caption
                        .copyWith(color: AppColors.stone500),
                  ),
                ),
              ),
              if (_notify) ...[
                const SizedBox(height: 10),
                _LabeledField(
                  label: 'How early?',
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _reminderOptions.map((opt) {
                      final sel = _reminderMinutes == opt.$1;
                      return GestureDetector(
                        onTap: () {
                          H.selection();
                          setState(() => _reminderMinutes = opt.$1);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel
                                ? AppColors.forest700
                                : AppColors.card,
                            borderRadius: AppRadius.pill,
                            border: Border.all(
                              color: sel
                                  ? AppColors.forest700
                                  : AppColors.stone200,
                            ),
                          ),
                          child: Text(opt.$2,
                              style: AppTextStyles.labelMedium.copyWith(
                                  color: sel
                                      ? Colors.white
                                      : AppColors.stone600)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
              const SizedBox(height: 22),

              // Save button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.forest700,
                    foregroundColor: Colors.white,
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
                      : Text(isEdit ? 'Save changes' : 'Add meeting',
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

  String _reminderLabel() => switch (_reminderMinutes) {
        5 => '5 minutes',
        15 => '15 minutes',
        30 => '30 minutes',
        60 => '1 hour',
        1440 => '1 day',
        _ => '$_reminderMinutes min',
      };

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        hintText: hint,
        hintStyle:
            AppTextStyles.bodyMedium.copyWith(color: AppColors.stone300),
        filled: true,
        fillColor: AppColors.stone50,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
          borderSide: const BorderSide(color: AppColors.forest600, width: 1.5),
        ),
      );
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child});
  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTextStyles.caption.copyWith(color: AppColors.stone500)),
          const SizedBox(height: 6),
          child,
        ],
      );
}

class _PickerTile extends StatelessWidget {
  const _PickerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: AppRadius.lg,
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
              Icon(icon, size: 16, color: AppColors.forest600),
              const SizedBox(width: 10),
              Expanded(
                child: Text(label,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.forestDark),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
            ],
          ),
        ),
      );
}
