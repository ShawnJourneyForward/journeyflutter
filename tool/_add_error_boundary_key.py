#!/usr/bin/env python3
"""One-shot: insert errorBoundaryMessage into all 6 app_*.arb files."""
import io
import json
import glob

KEY = 'errorBoundaryMessage'
# raw string -> the file gets a literal backslash-n, i.e. a JSON \n escape
VAL = r'Something went wrong loading this screen.\nPlease restart the app.'
DESC = ('Full-screen fallback shown if a screen fails to build (the app error '
        'boundary). Keep it short and calm.')

ins = ('  "%s": "%s",\n  "@%s": {"description": "%s"},\n'
       % (KEY, VAL, KEY, DESC))

for path in sorted(glob.glob('lib/l10n/app_*.arb')):
    with io.open(path, encoding='utf-8') as f:
        lines = f.readlines()
    if any('"%s"' % KEY in ln for ln in lines):
        print('skip (exists):', path)
        continue
    assert lines[0].strip() == '{', (path, lines[0])
    lines.insert(1, ins)
    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    # validate this file parses and the value round-trips with a real newline
    d = json.load(io.open(path, encoding='utf-8'))
    assert d[KEY] == 'Something went wrong loading this screen.\nPlease restart the app.', d[KEY]
    print('inserted + valid ->', path)
