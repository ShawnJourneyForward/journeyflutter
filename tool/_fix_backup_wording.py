#!/usr/bin/env python3
"""One-shot: scrub 'slip records' from backup wording across all 6 app_*.arb.
  - reword backupExportDesc (drop slips; representative + accurate)
  - add backupItemPlanner (replaces the removed 'Slip log' included-list row)
The slip_log KEY stays in the export internals so legacy data still travels;
only the user-facing copy changes.
"""
import io
import json
import glob

NEW_EXPORT_DESC = (
    "Save your profile, journal, gratitude, vision board, planner, and "
    "everything else you've logged. Choose an encrypted backup (.jfwbk) "
    "protected by a passphrase, or a plain JSON file."
)
PLANNER_VALUE = "Planner & training"

NEW_DESC_LINE = ('  "backupExportDesc": '
                 + json.dumps(NEW_EXPORT_DESC, ensure_ascii=False) + ',\n')
PLANNER_BLOCK = (
    '  "backupItemPlanner": ' + json.dumps(PLANNER_VALUE, ensure_ascii=False) + ',\n'
    '  "@backupItemPlanner": {"description": "Included-list row on the backup '
    'screen: the planner (goals, training sessions, weight logs)."},\n'
)

for path in sorted(glob.glob('lib/l10n/app_*.arb')):
    with io.open(path, encoding='utf-8') as f:
        lines = f.readlines()

    changed = False

    # 1. Reword backupExportDesc (replace the whole value line).
    for i, ln in enumerate(lines):
        if ln.lstrip().startswith('"backupExportDesc":'):
            lines[i] = NEW_DESC_LINE
            changed = True
            break

    # 2. Insert backupItemPlanner right after the backupItemSlipLog block,
    #    unless it already exists.
    if not any('"backupItemPlanner"' in ln for ln in lines):
        idx = next((i for i, ln in enumerate(lines)
                    if ln.lstrip().startswith('"backupItemSlipLog":')), None)
        assert idx is not None, ('backupItemSlipLog anchor missing in', path)
        ins_at = idx + 1
        if ins_at < len(lines) and '"@backupItemSlipLog"' in lines[ins_at]:
            ins_at += 1
        lines.insert(ins_at, PLANNER_BLOCK)
        changed = True

    assert changed, ('nothing changed in', path)
    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    d = json.load(io.open(path, encoding='utf-8'))  # validate JSON
    assert 'slip' not in d['backupExportDesc'].lower(), d['backupExportDesc']
    assert d['backupItemPlanner'] == PLANNER_VALUE
    print('fixed + valid ->', path)
