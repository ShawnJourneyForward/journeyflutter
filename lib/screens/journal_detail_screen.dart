// Diary v2 — detail screen.
//
// Opens when the user taps an entry card in the journal tab. Shows the full
// text without truncation, the mood + sub-mood + tags context, and the
// actions that didn't fit on a card: edit, delete, lock-toggle, "on this
// day" echoes from prior years.
//
// The edit flow is delegated back to the journal screen via `onEdit` so the
// existing bottom-sheet stays the single source of truth for editing.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../providers/app_providers.dart';
import '../theme/app_theme.dart';
import '../utils/haptic_service.dart';
import 'journal_shared.dart';

class JournalDetailScreen extends ConsumerWidget {
  const JournalDetailScreen({
    super.key,
    required this.entryId,
    required this.onEdit,
  });

  /// We watch the provider for the live entry rather than holding it
  /// directly, so edits flow back automatically and a deletion pops us out.
  final String entryId;

  /// Edit handler comes from the journal tab so the bottom-sheet stays in
  /// one place. We pass it the live entry, not the stale one we opened with.
  final void Function(JournalEntry entry) onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(journalProvider).valueOrNull ?? const [];
    final entry = list.firstWhere(
      (e) => e.id == entryId,
      // If the entry was just deleted, return a sentinel and pop on the next
      // frame — we can't pop synchronously inside build().
      orElse: () => JournalEntry(
          id: '', date: DateTime(1970), text: '', mood: 'okay'),
    );
    if (entry.id.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(backgroundColor: AppColors.stone50);
    }

    final mood = moodFor(entry.mood);
    final onThisDay = ref.watch(onThisDayProvider)
        .where((e) => e.id != entry.id)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.stone50,
      appBar: AppBar(
        backgroundColor: AppColors.stone50,
        foregroundColor: AppColors.stone800,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: entry.locked ? 'Unlock entry' : 'Lock entry',
            icon: Icon(
              entry.locked ? Icons.lock : Icons.lock_open_outlined,
              color: entry.locked ? AppColors.honey500 : AppColors.stone600,
            ),
            onPressed: () async {
              if (entry.locked) {
                // Locking → unlocking removes the safeguard, so re-auth first.
                final ok = await JournalReauth.require(context,
                    reason: 'Unlock this entry');
                if (!ok || !context.mounted) return;
              }
              H.medium();
              await ref
                  .read(journalProvider.notifier)
                  .toggleLocked(entry.id);
            },
          ),
          IconButton(
            tooltip: 'Edit',
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              H.selection();
              onEdit(entry);
            },
          ),
          IconButton(
            tooltip: 'Delete',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () => _confirmDelete(context, ref, entry),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date + edited stamp ─────────────────────────────────────
            Text(
              DateFormat('EEEE, MMMM d, y').format(entry.date),
              style: AppTextStyles.titleSmall
                  .copyWith(color: AppColors.stone500),
            ),
            const SizedBox(height: 2),
            Text(
              DateFormat('h:mm a').format(entry.date),
              style: AppTextStyles.bodySmall.copyWith(color: AppColors.stone400),
            ),
            if (entry.editedAt != null) ...[
              const SizedBox(height: 4),
              Text(
                'Edited ${_relativeAgo(entry.editedAt!)}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone400, fontStyle: FontStyle.italic),
              ),
            ],
            const SizedBox(height: 18),

            // ── Mood + sub-mood pill ────────────────────────────────────
            _MoodHeader(mood: mood, subMood: entry.subMood),

            // ── Tag chips ───────────────────────────────────────────────
            if (entry.tags.isNotEmpty) ...[
              const SizedBox(height: 14),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: entry.tags.map((t) => _TagChip(label: t)).toList(),
              ),
            ],

            // ── Prompt the entry was seeded from ────────────────────────
            if (entry.promptId != null) ...[
              const SizedBox(height: 18),
              _PromptCard(promptId: entry.promptId!),
            ],

            // ── Body text ───────────────────────────────────────────────
            const SizedBox(height: 22),
            SelectableText(
              entry.text,
              style: AppTextStyles.bodySerif.copyWith(
                color: AppColors.stone800,
                height: 1.6,
                fontSize: 17,
              ),
            ),

            // ── On-this-day echoes ──────────────────────────────────────
            if (onThisDay.isNotEmpty) ...[
              const SizedBox(height: 32),
              const _SectionLabel(
                icon: Icons.history_rounded,
                label: 'On this day, earlier',
              ),
              const SizedBox(height: 10),
              ...onThisDay.take(3).map((e) => _EchoCard(entry: e)),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, JournalEntry entry) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: Text('Delete this entry?',
            style: AppTextStyles.titleMedium
                .copyWith(color: AppColors.stone800)),
        content: Text('This cannot be undone.',
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.stone500)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Keep',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.stone500)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AppTextStyles.labelMedium
                    .copyWith(color: AppColors.blush600)),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    await ref.read(journalProvider.notifier).delete(entry.id);
    if (context.mounted) Navigator.of(context).pop();
  }

  String _relativeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat.yMMMd().format(dt);
  }
}

// ─── Mood header pill ────────────────────────────────────────────────────────

class _MoodHeader extends StatelessWidget {
  const _MoodHeader({required this.mood, required this.subMood});
  final MoodOption mood;
  final String? subMood;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: mood.color.withOpacity(0.10),
        borderRadius: AppRadius.lg,
        // ignore: deprecated_member_use
        border: Border.all(color: mood.color.withOpacity(0.30)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(mood.icon, size: 22, color: mood.color),
          const SizedBox(width: 10),
          Text(mood.label,
              style: AppTextStyles.titleSmall.copyWith(color: mood.color)),
          if (subMood != null && subMood!.isNotEmpty) ...[
            const SizedBox(width: 8),
            Container(
              width: 3,
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.stone400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(subMood!,
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone600)),
          ],
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.forest50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.forest100),
      ),
      child: Text(
        '#$label',
        style: AppTextStyles.labelSmall
            .copyWith(color: AppColors.forest600, letterSpacing: 0.2),
      ),
    );
  }
}

class _PromptCard extends StatelessWidget {
  const _PromptCard({required this.promptId});
  final String promptId;

  @override
  Widget build(BuildContext context) {
    final prompt = promptById(promptId);
    if (prompt == null) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mintChip,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.forest100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.format_quote_rounded,
              size: 16, color: AppColors.forest400),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              prompt.text,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.forest700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.stone500),
        const SizedBox(width: 6),
        Text(label.toUpperCase(),
            style: AppTextStyles.overline.copyWith(
              color: AppColors.stone500,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            )),
      ],
    );
  }
}

class _EchoCard extends StatelessWidget {
  const _EchoCard({required this.entry});
  final JournalEntry entry;

  @override
  Widget build(BuildContext context) {
    final mood = moodFor(entry.mood);
    final years = DateTime.now().year - entry.date.year;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppRadius.lg,
        border: Border.all(color: AppColors.softBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(mood.icon, size: 14, color: mood.color),
              const SizedBox(width: 6),
              Text(mood.label,
                  style: AppTextStyles.labelSmall.copyWith(color: mood.color)),
              const Spacer(),
              Text(
                years == 1 ? '1 year ago' : '$years years ago',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppColors.stone400),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            entry.locked ? 'Locked entry' : entry.text,
            style: AppTextStyles.bodySmall.copyWith(
              color:
                  entry.locked ? AppColors.stone400 : AppColors.stone700,
              fontStyle: entry.locked ? FontStyle.italic : FontStyle.normal,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
