#!/usr/bin/env python3
"""Merge every per-screen key spec in tool/i18n_keys/*.json into app_en.arb.

Each spec file is a JSON object mapping key -> {"en":..., "desc":...,
optional "placeholders": {"name": {"type": "int|String|num"}}} (the
add_arb_keys.py format, which the fan-out agents wrote directly).

- Skips keys already present in app_en.arb (idempotent).
- Detects and reports conflicts:
    * two spec files defining the same NEW key with different English
    * a spec key whose name already exists in app_en.arb with different English
      (agent picked a colliding name — must be fixed by hand)
- Re-serialises app_en.arb one entry per line (the file's existing style).
"""
import json
import io
import os
import glob
import collections

ARB = 'lib/l10n/app_en.arb'
SPEC_DIR = 'tool/i18n_keys'


def main():
    with io.open(ARB, encoding='utf-8') as f:
        d = json.load(f, object_pairs_hook=collections.OrderedDict)
    existing = {k: d[k] for k in d if not k.startswith('@')}

    spec_files = sorted(glob.glob(os.path.join(SPEC_DIR, '*.json')))
    added = 0
    seen = {}            # key -> (en, source_file) for newly added keys
    conflicts = []       # human-readable conflict notes
    per_file = []

    for path in spec_files:
        name = os.path.basename(path)
        try:
            with io.open(path, encoding='utf-8') as f:
                spec = json.load(f, object_pairs_hook=collections.OrderedDict)
        except Exception as e:
            conflicts.append('UNREADABLE {}: {}'.format(name, e))
            continue
        file_added = 0
        for k, info in spec.items():
            en = info.get('en', '')
            if k in existing:
                if existing[k] != en:
                    conflicts.append(
                        'NAME-COLLIDES-WITH-EXISTING: "{}" (spec {}) en={!r} but arb has {!r}'
                        .format(k, name, en, existing[k]))
                continue
            if k in seen:
                if seen[k][0] != en:
                    conflicts.append(
                        'CROSS-FILE-DUP: "{}" en={!r} ({}) vs en={!r} ({}) — kept first'
                        .format(k, seen[k][0], seen[k][1], en, name))
                continue
            # add it
            d[k] = en
            meta = collections.OrderedDict()
            if info.get('desc'):
                meta['description'] = info['desc']
            if info.get('placeholders'):
                meta['placeholders'] = info['placeholders']
            d['@' + k] = meta
            seen[k] = (en, name)
            added += 1
            file_added += 1
        per_file.append((name, file_added))

    items = list(d.items())
    lines = ['{']
    for i, (k, v) in enumerate(items):
        comma = '' if i == len(items) - 1 else ','
        lines.append('  ' + json.dumps(k, ensure_ascii=False) + ': ' +
                     json.dumps(v, ensure_ascii=False) + comma)
    lines.append('}')
    with io.open(ARB, 'w', encoding='utf-8') as f:
        f.write('\n'.join(lines) + '\n')

    total = sum(1 for k in d if not k.startswith('@'))
    print('spec files:', len(spec_files))
    for name, n in per_file:
        print('  {:40s} +{}'.format(name, n))
    print('added {} new keys, total string keys {}'.format(added, total))
    if conflicts:
        print('\n!!! {} CONFLICT(S) — review:'.format(len(conflicts)))
        for c in conflicts:
            print('  -', c)
    else:
        print('no conflicts')


if __name__ == '__main__':
    main()
