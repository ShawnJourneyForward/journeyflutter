#!/usr/bin/env python3
"""Insert new keys into lib/l10n/app_en.arb from a JSON spec.

Usage: python tool/add_arb_keys.py <spec.json>

Spec format (object, insertion order preserved):
  {
    "keyName": {"en": "English text", "desc": "context for translator",
                 "placeholders": {"count": {"type": "int"}}},
    ...
  }

- Keys already present in app_en.arb are skipped (idempotent).
- The whole file is re-serialised one entry per line ("key": value,) which is
  the file's existing style, so re-runs produce clean additive diffs.
"""
import json
import io
import sys
import collections

ARB = 'lib/l10n/app_en.arb'


def main():
    spec_path = sys.argv[1]
    with io.open(ARB, encoding='utf-8') as f:
        d = json.load(f, object_pairs_hook=collections.OrderedDict)
    with io.open(spec_path, encoding='utf-8') as f:
        new = json.load(f, object_pairs_hook=collections.OrderedDict)

    added = 0
    for k, info in new.items():
        if k in d:
            continue
        d[k] = info['en']
        meta = collections.OrderedDict()
        if info.get('desc'):
            meta['description'] = info['desc']
        if info.get('placeholders'):
            meta['placeholders'] = info['placeholders']
        d['@' + k] = meta
        added += 1

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
    print('added {}, total string keys {}'.format(added, total))


if __name__ == '__main__':
    main()
