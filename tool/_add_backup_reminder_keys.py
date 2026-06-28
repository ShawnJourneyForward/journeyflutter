#!/usr/bin/env python3
"""One-shot: insert the backup-reminder card strings into all 6 app_*.arb,
after the existing homeBackupNudgeAction key."""
import io
import json
import glob

ANCHOR = '"homeBackupNudgeAction":'
KEYS = [
    ("backupReminderTitle", "Protect your progress",
     "Title of the gentle backup reminder card on Home (shown when an export is overdue)."),
    ("backupReminderBody",
     "It's been a while since your last backup. Save a copy so a new or lost "
     "phone never costs you your streak.",
     "Body of the Home backup reminder card."),
    ("backupReminderDismiss", "Dismiss",
     "Accessibility label for the close (snooze) button on the Home backup reminder card."),
]


def block():
    out = []
    for k, v, desc in KEYS:
        out.append('  ' + json.dumps(k, ensure_ascii=False) + ': '
                   + json.dumps(v, ensure_ascii=False) + ',\n')
        out.append('  ' + json.dumps('@' + k, ensure_ascii=False) + ': '
                   + json.dumps({"description": desc}, ensure_ascii=False) + ',\n')
    return ''.join(out)


BLOCK = block()

for path in sorted(glob.glob('lib/l10n/app_*.arb')):
    with io.open(path, encoding='utf-8') as f:
        lines = f.readlines()
    if any('"backupReminderTitle"' in ln for ln in lines):
        print('skip (exists):', path)
        continue
    idx = next((i for i, ln in enumerate(lines)
                if ln.lstrip().startswith(ANCHOR)), None)
    assert idx is not None, ('anchor not found in', path)
    ins_at = idx + 1
    if ins_at < len(lines) and '"@homeBackupNudgeAction"' in lines[ins_at]:
        ins_at += 1
    lines.insert(ins_at, BLOCK)
    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    d = json.load(io.open(path, encoding='utf-8'))  # validate JSON
    assert d['backupReminderTitle'] == 'Protect your progress'
    assert d['backupReminderDismiss'] == 'Dismiss'
    print('inserted + valid ->', path)
