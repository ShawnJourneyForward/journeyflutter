#!/usr/bin/env python3
"""One-shot: insert the test-feedback-round keys (weekly-goals reset/history,
journal edit button, planner-insights week selector) into all 6 app_*.arb.

Each block is inserted after a stable existing anchor key. English text is used
in every locale (stubs); real translations flow through the handoff pipeline.
Idempotent — re-running skips files that already have the keys."""
import io
import json
import glob

# (sentinel-key, anchor-substring, block-text)
INSERTS = [
    (
        '"homeWeeklyGoalsProgress"',
        '"@homeWeeklyGoals":',
        '  "homeWeeklyGoalsProgress": "{done} of {total}",\n'
        '  "@homeWeeklyGoalsProgress": {"description": "Progress chip on the '
        'weekly-goals card, e.g. 2 of 4.", "placeholders": {"done": {"type": '
        '"int"}, "total": {"type": "int"}}},\n'
        '  "homeWeeklyGoalsResetHint": "Resets every Sunday — achieved goals '
        'are saved to your history.",\n'
        '  "@homeWeeklyGoalsResetHint": {"description": "Caption under the '
        'weekly-goals title explaining the Sunday reset and history."},\n'
        '  "homeWeeklyGoalsHistoryTitle": "Weekly goals history",\n'
        '  "@homeWeeklyGoalsHistoryTitle": {"description": "Title of the sheet '
        'listing achieved weekly goals from past weeks."},\n'
    ),
    (
        '"journalDetailEditEntry"',
        '"@journalDetailEdit":',
        '  "journalDetailEditEntry": "Edit entry",\n'
        '  "@journalDetailEditEntry": {"description": "Label of the full-width '
        'edit button on the journal entry detail screen."},\n'
    ),
    (
        '"plannerWeekThis"',
        '"@plannerCurrentWeek":',
        '  "plannerNoActivitiesThisWeek": "No activity logged this week.",\n'
        '  "@plannerNoActivitiesThisWeek": {"description": "Shown in the '
        'planner insights by-activity section when the selected week has no '
        'logged activities."},\n'
        '  "plannerTrendLast8Weeks": "Last 8 weeks",\n'
        '  "@plannerTrendLast8Weeks": {"description": "Section header above the '
        'multi-week trend charts on the planner insights screen."},\n'
        '  "plannerWeekThis": "This week",\n'
        '  "@plannerWeekThis": {"description": "Relative label under the planner '
        'insights week selector when the current week is selected."},\n'
        '  "plannerWeekLast": "Last week",\n'
        '  "@plannerWeekLast": {"description": "Relative label under the planner '
        'insights week selector when the previous week is selected."},\n'
        '  "plannerWeekPrev": "Previous week",\n'
        '  "@plannerWeekPrev": {"description": "Accessibility tooltip for the '
        'previous-week chevron on the planner insights week selector."},\n'
        '  "plannerWeekNext": "Next week",\n'
        '  "@plannerWeekNext": {"description": "Accessibility tooltip for the '
        'next-week chevron on the planner insights week selector."},\n'
    ),
]

for path in sorted(glob.glob('lib/l10n/app_*.arb')):
    with io.open(path, encoding='utf-8') as f:
        lines = f.readlines()
    changed = False
    for sentinel, anchor, block in INSERTS:
        if any(sentinel in ln for ln in lines):
            continue
        idx = next((i for i, ln in enumerate(lines) if anchor in ln), None)
        assert idx is not None, ('anchor not found: %s in %s' % (anchor, path))
        lines.insert(idx + 1, block)
        changed = True
    if not changed:
        print('skip (all exist):', path)
        continue
    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    d = json.load(io.open(path, encoding='utf-8'))  # validate JSON
    for k in ('homeWeeklyGoalsProgress', 'homeWeeklyGoalsResetHint',
              'homeWeeklyGoalsHistoryTitle', 'journalDetailEditEntry',
              'plannerNoActivitiesThisWeek', 'plannerTrendLast8Weeks',
              'plannerWeekThis', 'plannerWeekLast', 'plannerWeekPrev',
              'plannerWeekNext'):
        assert k in d, ('missing key after insert: %s in %s' % (k, path))
    print('inserted + valid ->', path)
