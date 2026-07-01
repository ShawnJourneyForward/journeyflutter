#!/usr/bin/env python3
"""One-shot: add the pre-launch safety strings (TIPP medical caveats, crisis-mood
routing, Emergency crisis-lines card) to all 6 app_*.arb, and reword the
crisis-mood journal body so it no longer implies a breathing exercise suffices.
Idempotent."""
import io
import json
import glob

SENTINEL = '"tippTempCaution"'
ANCHOR = '"@journalCrisisBodyCrisis":'

OLD_BODY = ('"journalCrisisBodyCrisis": "Saving your entry helped. A short calm '
            'exercise can take it from here.",')
NEW_BODY = ('"journalCrisisBodyCrisis": "You said this is a crisis — you don\'t '
            'have to hold it alone. Reaching a person can help right now.",')

BLOCK = (
    '  "tippTempCaution": "Skip the cold-water or breath-hold step if you have '
    'a heart condition, low blood pressure, an eating disorder, or are pregnant '
    '— try Paced breathing instead.",\n'
    '  "@tippTempCaution": {"description": "Medical safety caveat shown on the '
    'TIPP Temperature (cold-water) card."},\n'
    '  "tippIntenseCaution": "Ease off if you have a heart condition, are '
    'pregnant, or feel faint — even a brisk walk works. Stop if you feel '
    'unwell.",\n'
    '  "@tippIntenseCaution": {"description": "Medical safety caveat shown on '
    'the TIPP Intense-movement card."},\n'
    '  "journalCrisisLinesLabel": "Talk to someone now",\n'
    '  "@journalCrisisLinesLabel": {"description": "Primary crisis action on the '
    'journal crisis-mood sheet — routes to the crisis-line list."},\n'
    '  "journalCrisisLinesDetail": "Reach a trained crisis counsellor — free, '
    'confidential, any time.",\n'
    '  "@journalCrisisLinesDetail": {"description": "Detail under the journal '
    '\\"Talk to someone now\\" crisis action."},\n'
    '  "emergencyCrisisLinesTitle": "Talk to someone now",\n'
    '  "@emergencyCrisisLinesTitle": {"description": "Title of the always-present '
    'crisis-lines card at the top of the Emergency toolkit."},\n'
    '  "emergencyCrisisLinesSubtitle": "Free, confidential crisis lines — any '
    'time",\n'
    '  "@emergencyCrisisLinesSubtitle": {"description": "Subtitle of the '
    'Emergency crisis-lines card."},\n'
)

NEW_KEYS = [
    'tippTempCaution', 'tippIntenseCaution', 'journalCrisisLinesLabel',
    'journalCrisisLinesDetail', 'emergencyCrisisLinesTitle',
    'emergencyCrisisLinesSubtitle',
]

for path in sorted(glob.glob('lib/l10n/app_*.arb')):
    with io.open(path, encoding='utf-8') as f:
        text = f.read()
    changed = False
    if OLD_BODY in text:
        text = text.replace(OLD_BODY, NEW_BODY)
        changed = True
    lines = text.splitlines(keepends=True)
    if not any(SENTINEL in ln for ln in lines):
        idx = next((i for i, ln in enumerate(lines) if ANCHOR in ln), None)
        assert idx is not None, ('anchor not found in', path)
        lines.insert(idx + 1, BLOCK)
        changed = True
    if not changed:
        print('skip (all present):', path)
        continue
    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    d = json.load(io.open(path, encoding='utf-8'))  # validate JSON
    for k in NEW_KEYS:
        assert k in d, ('missing key: %s in %s' % (k, path))
    assert "don't have to hold it alone" in d['journalCrisisBodyCrisis'], \
        ('body not reworded in', path)
    print('updated + valid ->', path)
