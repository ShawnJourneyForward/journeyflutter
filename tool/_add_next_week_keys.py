#!/usr/bin/env python3
"""One-shot: insert plannerNextWeek + plannerNextWeekEmpty into all 6 app_*.arb,
right after the existing plannerCurrentWeek key."""
import io
import json
import glob

ANCHOR = '"plannerCurrentWeek":'
BLOCK = (
    '  "plannerNextWeek": "Next week",\n'
    '  "@plannerNextWeek": {"description": "Header for the next-week '
    'look-ahead list under the planner calendar."},\n'
    '  "plannerNextWeekEmpty": "Nothing planned for next week yet.",\n'
    '  "@plannerNextWeekEmpty": {"description": "Shown under the Next week '
    'header when no sessions are planned for next week."},\n'
)

for path in sorted(glob.glob('lib/l10n/app_*.arb')):
    with io.open(path, encoding='utf-8') as f:
        lines = f.readlines()
    if any('"plannerNextWeek"' in ln for ln in lines):
        print('skip (exists):', path)
        continue
    idx = next((i for i, ln in enumerate(lines) if ANCHOR in ln), None)
    assert idx is not None, ('anchor not found in', path)
    lines.insert(idx + 1, BLOCK)
    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    d = json.load(io.open(path, encoding='utf-8'))  # validate JSON
    assert d['plannerNextWeek'] == 'Next week'
    assert d['plannerNextWeekEmpty'] == 'Nothing planned for next week yet.'
    print('inserted + valid ->', path)
