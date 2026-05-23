// Shared metadata + helpers for the Diary v2 feature.
//
// Lives outside journal_screen.dart so the new detail screen can import the
// same prompts, sub-mood vocab, mood metadata, and re-auth helper without a
// circular import. All copy is English-only for v2.0 — localisation lands in
// a follow-up so we don't bloat 5 ARB files with 80 strings the user will
// keep tuning.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/app_theme.dart';
import '../utils/pin_hash.dart';

// ─── Primary moods ───────────────────────────────────────────────────────────
// The five values that already exist in stored entries. Don't rename keys.

class MoodOption {
  const MoodOption({
    required this.key,
    required this.emoji,
    required this.label,
    required this.icon,
    required this.color,
    required this.score, // 1-5, used by insights
  });
  final String key;
  final String emoji;
  final String label;
  final IconData icon;
  final Color color;
  final int score;
}

const kMoodOptions = <MoodOption>[
  MoodOption(
    key: 'great',
    emoji: '😄',
    label: 'Great',
    icon: Icons.sentiment_very_satisfied_rounded,
    color: AppColors.forest600,
    score: 5,
  ),
  MoodOption(
    key: 'good',
    emoji: '🙂',
    label: 'Good',
    icon: Icons.sentiment_satisfied_rounded,
    color: AppColors.forest400,
    score: 4,
  ),
  MoodOption(
    key: 'okay',
    emoji: '😐',
    label: 'Okay',
    icon: Icons.sentiment_neutral_rounded,
    color: AppColors.honey500,
    score: 3,
  ),
  MoodOption(
    key: 'hard',
    emoji: '😔',
    label: 'Hard',
    icon: Icons.sentiment_dissatisfied_rounded,
    color: AppColors.honey500,
    score: 2,
  ),
  MoodOption(
    key: 'crisis',
    emoji: '😰',
    label: 'Crisis',
    icon: Icons.sentiment_very_dissatisfied_rounded,
    color: AppColors.blush600,
    score: 1,
  ),
];

MoodOption moodFor(String key) => kMoodOptions.firstWhere(
      (m) => m.key == key,
      orElse: () => kMoodOptions[2], // okay
    );

// ─── Sub-mood vocabulary ─────────────────────────────────────────────────────
// Surfaced when the primary mood is `great` or `hard`/`crisis` — the two ends
// where richer vocabulary actually changes the conversation the user has with
// themselves. (`okay`/`good` rarely need refinement.)

const kSubMoodsHard = <String>[
  'anxious',
  'ashamed',
  'lonely',
  'angry',
  'grieving',
  'numb',
  'overwhelmed',
  'craving',
];

const kSubMoodsGreat = <String>[
  'proud',
  'energized',
  'peaceful',
  'grateful',
  'hopeful',
  'connected',
  'focused',
  'free',
];

/// Returns the sub-mood vocabulary appropriate for the given primary mood,
/// or null when refinement doesn't help (okay/good days).
List<String>? subMoodsFor(String primaryMood) {
  switch (primaryMood) {
    case 'great':
      return kSubMoodsGreat;
    case 'hard':
    case 'crisis':
      return kSubMoodsHard;
    default:
      return null;
  }
}

// ─── Suggested tags ──────────────────────────────────────────────────────────
// Seed list — the entry sheet merges these with the user's own previously-used
// tags so the chips show what's most relevant to them over time.

const kSuggestedTags = <String>[
  'work',
  'family',
  'sleep',
  'craving',
  'meeting',
  'exercise',
  'gratitude',
  'lonely',
  'relationship',
  'money',
  'pride',
  'doubt',
];

// ─── Journal prompts ─────────────────────────────────────────────────────────
// Sixty prompts grouped by category. The entry sheet rotates a daily prompt
// per category so the user doesn't see the same one every day; tapping a
// prompt seeds it into the text field as a soft starter.
//
// Each prompt has a stable `id` written to the entry's promptId field (useful
// later for "prompts that produced your hardest reflections" insights).

class JournalPromptCategory {
  const JournalPromptCategory({
    required this.id,
    required this.label,
    required this.icon,
    required this.color,
    required this.prompts,
  });
  final String id;
  final String label;
  final IconData icon;
  final Color color;
  final List<JournalPrompt> prompts;
}

class JournalPrompt {
  const JournalPrompt({required this.id, required this.text});
  final String id;
  final String text;
}

const kPromptCategories = <JournalPromptCategory>[
  JournalPromptCategory(
    id: 'reflection',
    label: 'Reflection',
    icon: Icons.psychology_outlined,
    color: AppColors.forest500,
    prompts: [
      JournalPrompt(id: 'r1', text: 'What pulled at me today — and what held me steady?'),
      JournalPrompt(id: 'r2', text: 'If today had a colour, what would it be? Why?'),
      JournalPrompt(id: 'r3', text: 'What did my body tell me today that I almost ignored?'),
      JournalPrompt(id: 'r4', text: 'Where did I show up for myself today, even imperfectly?'),
      JournalPrompt(id: 'r5', text: 'What truth am I avoiding right now?'),
      JournalPrompt(id: 'r6', text: 'What story did I tell myself today — and was it kind, or just familiar?'),
      JournalPrompt(id: 'r7', text: 'What would the wisest version of me say about today?'),
      JournalPrompt(id: 'r8', text: 'What is one thing I am ready to set down?'),
      JournalPrompt(id: 'r9', text: 'What feeling have I been outrunning?'),
      JournalPrompt(id: 'r10', text: 'When did I feel most like myself today?'),
    ],
  ),
  JournalPromptCategory(
    id: 'gratitude',
    label: 'Gratitude',
    icon: Icons.spa_outlined,
    color: AppColors.honey500,
    prompts: [
      JournalPrompt(id: 'g1', text: 'Three small things I am grateful for right now.'),
      JournalPrompt(id: 'g2', text: 'Someone who made my life easier this week — and why.'),
      JournalPrompt(id: 'g3', text: 'A body part that did its job today without me noticing.'),
      JournalPrompt(id: 'g4', text: 'A sound, smell, or taste that landed today.'),
      JournalPrompt(id: 'g5', text: 'A thing I have now that past-me would have begged for.'),
      JournalPrompt(id: 'g6', text: 'A small comfort that softened a hard moment.'),
      JournalPrompt(id: 'g7', text: 'A piece of music, a view, a meal — what fed me today?'),
      JournalPrompt(id: 'g8', text: 'Who in my life right now is steady? Name them.'),
      JournalPrompt(id: 'g9', text: 'A skill I have today that I did not have a year ago.'),
      JournalPrompt(id: 'g10', text: 'One ordinary moment today that I want to remember.'),
    ],
  ),
  JournalPromptCategory(
    id: 'hard',
    label: 'Hard day',
    icon: Icons.cloud_outlined,
    color: AppColors.blush600,
    prompts: [
      JournalPrompt(id: 'h1', text: 'What hurt today? Just name it — no fix, no spin.'),
      JournalPrompt(id: 'h2', text: 'If this feeling could speak, what would it say it needs?'),
      JournalPrompt(id: 'h3', text: 'What part of today felt unfair?'),
      JournalPrompt(id: 'h4', text: 'Is there a feeling I am calling anger that is actually something else underneath?'),
      JournalPrompt(id: 'h5', text: 'What would I say to a friend who was where I am right now?'),
      JournalPrompt(id: 'h6', text: 'What is the smallest next step I can take, even if I do not feel like it?'),
      JournalPrompt(id: 'h7', text: 'Who can I tell about this — even one person, even one sentence?'),
      JournalPrompt(id: 'h8', text: 'What am I making this mean about me — and is that true?'),
      JournalPrompt(id: 'h9', text: 'What did today take from me? What did it leave?'),
      JournalPrompt(id: 'h10', text: 'If I could fast-forward 24 hours, what would I want to be true?'),
    ],
  ),
  JournalPromptCategory(
    id: 'win',
    label: 'Wins',
    icon: Icons.emoji_events_outlined,
    color: AppColors.honey400,
    prompts: [
      JournalPrompt(id: 'w1', text: 'A moment today I am quietly proud of.'),
      JournalPrompt(id: 'w2', text: 'Something I did today that past-me could not have done.'),
      JournalPrompt(id: 'w3', text: 'A risk I took — however small — and how it landed.'),
      JournalPrompt(id: 'w4', text: 'Where did I choose myself today?'),
      JournalPrompt(id: 'w5', text: 'A boundary I held, even if no one noticed.'),
      JournalPrompt(id: 'w6', text: 'A craving I rode through.'),
      JournalPrompt(id: 'w7', text: 'A conversation I am glad I had.'),
      JournalPrompt(id: 'w8', text: 'Something I finished. Anything.'),
      JournalPrompt(id: 'w9', text: 'A way my body felt strong today.'),
      JournalPrompt(id: 'w10', text: 'A way I treated myself the way I would treat someone I love.'),
    ],
  ),
  JournalPromptCategory(
    id: 'craving',
    label: 'Craving',
    icon: Icons.local_fire_department_outlined,
    color: AppColors.blush500,
    prompts: [
      JournalPrompt(id: 'c1', text: 'When did the urge start today, and what was happening around me?'),
      JournalPrompt(id: 'c2', text: 'What was my body doing when the craving hit?'),
      JournalPrompt(id: 'c3', text: 'What was the lie the craving was telling me?'),
      JournalPrompt(id: 'c4', text: 'What did I actually need underneath the craving — rest, connection, food, quiet?'),
      JournalPrompt(id: 'c5', text: 'How long did it last before it began to pass?'),
      JournalPrompt(id: 'c6', text: 'What did I do instead — and how do I feel about that choice now?'),
      JournalPrompt(id: 'c7', text: 'Who or what helped me ride this one out?'),
      JournalPrompt(id: 'c8', text: 'If this craving returns tomorrow, what is one thing I can have ready?'),
      JournalPrompt(id: 'c9', text: 'What would the version of me a year sober say to this craving?'),
      JournalPrompt(id: 'c10', text: 'What is the craving costing me, even when I do not use?'),
    ],
  ),
  JournalPromptCategory(
    id: 'relationships',
    label: 'People',
    icon: Icons.people_outline_rounded,
    color: AppColors.forest400,
    prompts: [
      JournalPrompt(id: 'p1', text: 'Who do I owe an honest sentence to — even if I never say it?'),
      JournalPrompt(id: 'p2', text: 'A relationship that feels lighter than it did a year ago.'),
      JournalPrompt(id: 'p3', text: 'Someone I keep replaying conversations with — what is unfinished there?'),
      JournalPrompt(id: 'p4', text: 'A person I keep meaning to reach out to — what is one sentence I could send?'),
      JournalPrompt(id: 'p5', text: 'Where do I feel most seen lately? Where do I feel most invisible?'),
      JournalPrompt(id: 'p6', text: 'What is one boundary I am proud of — even a small one?'),
      JournalPrompt(id: 'p7', text: 'Who in my life has earned more of me? Who has earned less?'),
      JournalPrompt(id: 'p8', text: 'A thing someone said to me that I am still carrying.'),
      JournalPrompt(id: 'p9', text: 'What would a healthier version of me say to the people in my life right now?'),
      JournalPrompt(id: 'p10', text: 'Who do I want to be remembered as — by the people closest to me?'),
    ],
  ),
];

JournalPrompt? promptById(String id) {
  for (final cat in kPromptCategories) {
    for (final p in cat.prompts) {
      if (p.id == id) return p;
    }
  }
  return null;
}

/// Three starter prompts shown in the empty state — one reflection, one
/// gratitude, one hard-day so the door is open whatever the user is feeling.
List<JournalPrompt> starterPromptsForEmptyState() => const [
      JournalPrompt(id: 'r1', text: 'What pulled at me today — and what held me steady?'),
      JournalPrompt(id: 'g6', text: 'A small comfort that softened a hard moment.'),
      JournalPrompt(id: 'h5', text: 'What would I say to a friend who was where I am right now?'),
    ];

/// Returns the daily-rotating prompt for a category — same on a given day,
/// so the user sees consistency through the day but variety across days.
JournalPrompt dailyPromptFor(JournalPromptCategory category) {
  final now = DateTime.now();
  final dayOfYear = now.difference(DateTime(now.year)).inDays;
  return category.prompts[dayOfYear % category.prompts.length];
}

/// Picks the *suggested* category to open the prompt strip with, given
/// time-of-day and recent emotional history. Quiet intelligence — the user
/// still has full control to pick any category, but the default has a chance
/// of matching where they actually are.
///
/// Logic:
///   • If the most recent entry (within ~36h) was 'crisis' → suggest a hard
///     prompt. The user is still in the wake of it; meet them there.
///   • If the most recent entry (within ~36h) was 'hard' → suggest a hard
///     prompt for the same reason.
///   • If the most recent entry was 'great'/'good' → suggest a gratitude
///     prompt to capture and savour the momentum.
///   • Otherwise time-of-day: morning (5-11) reflection, midday (11-17)
///     reflection, evening (17-23) gratitude, night (23-5) reflection.
JournalPromptCategory smartDefaultCategory({
  required DateTime now,
  required String? mostRecentMood,
  required Duration? sinceMostRecent,
}) {
  // Mood-driven first (only honour if recent — old moods aren't relevant).
  if (mostRecentMood != null &&
      sinceMostRecent != null &&
      sinceMostRecent <= const Duration(hours: 36)) {
    if (mostRecentMood == 'crisis' || mostRecentMood == 'hard') {
      return kPromptCategories.firstWhere((c) => c.id == 'hard');
    }
    if (mostRecentMood == 'great' || mostRecentMood == 'good') {
      return kPromptCategories.firstWhere((c) => c.id == 'gratitude');
    }
  }
  // Time-of-day fallback.
  final h = now.hour;
  if (h >= 17 && h < 23) {
    return kPromptCategories.firstWhere((c) => c.id == 'gratitude');
  }
  return kPromptCategories.firstWhere((c) => c.id == 'reflection');
}

// ─── Draft autosave ──────────────────────────────────────────────────────────
//
// Holds the user's in-progress entry between sheet closures. Stored to
// SharedPreferences as JSON so an OS kill, accidental swipe-down, or a phone
// call that closes the keyboard doesn't lose 200 words of raw emotion the
// user just typed.
//
// Drafts older than 48 hours are considered stale and dropped on read — the
// user almost certainly moved on, and surfacing day-old text would feel
// uncanny rather than helpful.

class JournalDraft {
  const JournalDraft({
    required this.text,
    required this.mood,
    required this.subMood,
    required this.tags,
    required this.promptId,
    required this.locked,
    required this.savedAt,
  });

  final String text;
  final String mood;
  final String? subMood;
  final List<String> tags;
  final String? promptId;
  final bool locked;
  final DateTime savedAt;

  Map<String, dynamic> toJson() => {
        'text': text,
        'mood': mood,
        if (subMood != null) 'subMood': subMood,
        if (tags.isNotEmpty) 'tags': tags,
        if (promptId != null) 'promptId': promptId,
        if (locked) 'locked': true,
        'savedAt': savedAt.toIso8601String(),
      };

  static JournalDraft? fromJson(Map<String, dynamic> j) {
    try {
      return JournalDraft(
        text: j['text'] as String? ?? '',
        mood: j['mood'] as String? ?? 'okay',
        subMood: j['subMood'] as String?,
        tags: ((j['tags'] as List?) ?? const [])
            .whereType<String>()
            .toList(),
        promptId: j['promptId'] as String?,
        locked: (j['locked'] as bool?) ?? false,
        savedAt: DateTime.tryParse(j['savedAt'] as String? ?? '') ??
            DateTime.now(),
      );
    } catch (_) {
      return null;
    }
  }
}

class JournalDraftStore {
  JournalDraftStore._();

  static const _key = 'journal_draft_v1';
  static const _staleAfter = Duration(hours: 48);

  /// Reads the draft if one exists and isn't stale. Returns null otherwise.
  /// Stale drafts are cleared on read so the next open is fresh.
  static Future<JournalDraft?> read() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      final draft = JournalDraft.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      if (draft == null) return null;
      if (DateTime.now().difference(draft.savedAt) > _staleAfter) {
        await prefs.remove(_key);
        return null;
      }
      // Treat empty drafts as no-draft.
      if (draft.text.trim().isEmpty) {
        await prefs.remove(_key);
        return null;
      }
      return draft;
    } catch (_) {
      await prefs.remove(_key);
      return null;
    }
  }

  /// Write — debounced by the sheet, never by this store. Safe to call often.
  static Future<void> write(JournalDraft draft) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(draft.toJson()));
  }

  /// Clear after a successful save.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

// ─── Re-auth helper (per-entry lock) ─────────────────────────────────────────
//
// The app already gates startup with biometric or PIN. The per-entry lock is
// "extra-private — hide preview from over-the-shoulder, re-prove identity to
// view." We try biometric first (one tap, no UI), then fall back to a PIN
// prompt if the user has a PIN set. If neither is configured we degrade
// gracefully — the lock still hides previews in the list, but viewing the
// entry just confirms.
//
// Returns true on success / no-auth-available, false on cancel/fail.

class JournalReauth {
  JournalReauth._();

  static final _auth = LocalAuthentication();
  static const _storage = FlutterSecureStorage();

  /// One-shot re-auth. Caller passes [context] so we can show the PIN dialog
  /// fallback ourselves; no callback hell required.
  static Future<bool> require(BuildContext context, {String reason = 'Unlock this entry'}) async {
    // 1. Try biometric / device credential. The OS handles the UI.
    try {
      final canCheck = await _auth.canCheckBiometrics;
      final isAvailable = await _auth.isDeviceSupported();
      if (canCheck || isAvailable) {
        final ok = await _auth.authenticate(
          localizedReason: reason,
          options: const AuthenticationOptions(
            biometricOnly: false,
            stickyAuth: true,
          ),
        );
        if (ok) return true;
        // User cancelled or failed — fall through to the PIN path if one
        // exists. They might still want to enter their PIN.
      }
    } on PlatformException {
      // No biometric / not enrolled — fall through to PIN.
    }

    // 2. PIN fallback if the user has one set.
    final storedHash = await _storage.read(key: PinHash.storageKey) ??
        await _storage.read(key: PinHash.legacyKey);
    if (storedHash == null) {
      // No device auth, no PIN — the lock can only obfuscate previews.
      // Open the entry; the user has no real second factor to prove anyway.
      return true;
    }
    if (!context.mounted) return false;
    return await _showPinDialog(context, storedHash);
  }

  static Future<bool> _showPinDialog(BuildContext context, String storedHash) async {
    final ctrl = TextEditingController();
    var error = false;
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return StatefulBuilder(builder: (ctx, setSt) {
          return AlertDialog(
            backgroundColor: AppColors.card,
            title: Text('Enter your PIN',
                style: AppTextStyles.titleMedium
                    .copyWith(color: AppColors.stone800)),
            content: TextField(
              controller: ctrl,
              autofocus: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              obscureText: true,
              decoration: InputDecoration(
                hintText: '••••',
                errorText: error ? 'Incorrect PIN' : null,
                counterText: '',
              ),
              style: AppTextStyles.titleLarge
                  .copyWith(color: AppColors.stone800, letterSpacing: 8),
              onSubmitted: (v) {
                if (PinHash.verify(v, storedHash)) {
                  Navigator.pop(ctx, true);
                } else {
                  setSt(() => error = true);
                }
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancel',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.stone500)),
              ),
              TextButton(
                onPressed: () {
                  if (PinHash.verify(ctrl.text, storedHash)) {
                    Navigator.pop(ctx, true);
                  } else {
                    setSt(() => error = true);
                  }
                },
                child: Text('Unlock',
                    style: AppTextStyles.labelMedium
                        .copyWith(color: AppColors.forest600)),
              ),
            ],
          );
        });
      },
    );
    ctrl.dispose();
    return ok ?? false;
  }
}
