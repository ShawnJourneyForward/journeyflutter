#!/usr/bin/env python3
"""One-shot: insert plannerGoalEncourageTitle + ...Body into all 6 app_*.arb,
right after the plannerHealthDisclaimer key."""
import io
import json
import glob

ANCHOR = '"plannerHealthDisclaimer":'
TITLE = 'Every goal counts'
BODY = (
    "Setting a goal and working towards it is one of the most rewarding parts "
    "of recovery — it gives your days shape and your energy somewhere to "
    "go. It doesn’t have to be big: getting out to walk more, sleeping "
    "better, losing a little weight, running your first 5k, or one day a "
    "marathon. Whatever it is, any goal is worth working towards. Start small, "
    "stay steady, and let it grow with you."
)
BLOCK = (
    '  "plannerGoalEncourageTitle": ' + json.dumps(TITLE, ensure_ascii=False) + ',\n'
    '  "@plannerGoalEncourageTitle": {"description": "Heading of the large '
    'encouragement note at the bottom of the planner Overview tab."},\n'
    '  "plannerGoalEncourageBody": ' + json.dumps(BODY, ensure_ascii=False) + ',\n'
    '  "@plannerGoalEncourageBody": {"description": "Body of the encouragement '
    'note about why setting and pursuing goals matters in recovery."},\n'
)

for path in sorted(glob.glob('lib/l10n/app_*.arb')):
    with io.open(path, encoding='utf-8') as f:
        lines = f.readlines()
    if any('"plannerGoalEncourageTitle"' in ln for ln in lines):
        print('skip (exists):', path)
        continue
    idx = next((i for i, ln in enumerate(lines) if ANCHOR in ln), None)
    assert idx is not None, ('anchor not found in', path)
    lines.insert(idx + 1, BLOCK)
    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    d = json.load(io.open(path, encoding='utf-8'))  # validate JSON
    assert d['plannerGoalEncourageTitle'] == TITLE
    assert d['plannerGoalEncourageBody'] == BODY
    print('inserted + valid ->', path)
