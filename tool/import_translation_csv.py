#!/usr/bin/env python3
"""Import a finished translator CSV column into lib/l10n/app_<code>.arb.

This is the developer side of "give me a language and I just plug it in". It
takes the filled-in column from TRANSLATIONS/journey_forward_strings.csv and
writes a complete, valid app_<code>.arb that:

  * clones app_en.arb's EXACT key order and every @key metadata block, so the
    locale-parity test and `flutter gen-l10n` stay happy;
  * substitutes the translated text for each message key;
  * VALIDATES before writing — fails loudly (exit 1, writes nothing) if a key
    is missing from the CSV, a {placeholder} token was dropped, or an ICU
    plural/select structure was broken. A botched translation never lands
    silently as a half-English build.

Usage:
    python tool/import_translation_csv.py <lang_code> [csv_path]
    python tool/import_translation_csv.py es
    python tool/import_translation_csv.py pt --allow-missing   # fill EN for blanks

After it writes the .arb:
    1. flutter gen-l10n
    2. add one line to kSupportedLanguages in lib/l10n/app_locales.dart
    3. flutter test test/unit/localization_keys_test.dart
"""
import json
import io
import csv
import re
import sys
import collections

EN = 'lib/l10n/app_en.arb'
CSV = 'TRANSLATIONS/journey_forward_strings.csv'

# Placeholder token names: {name} and the leading name of {name, plural, ...}.
_PH = re.compile(r'\{([A-Za-z_]\w*)')


def placeholder_names(value):
    return set(_PH.findall(value))


def find_lang_column(header, code):
    """Locate the CSV column for an ISO code. Matches '... (es)' style headers
    (from gen_translation_csv.py) or an exact code header."""
    for col in header:
        c = col.strip().lower()
        if c == code or c.endswith('(%s)' % code):
            return col
    return None


def serialize(d):
    items = list(d.items())
    lines = ['{']
    for i, (k, v) in enumerate(items):
        comma = '' if i == len(items) - 1 else ','
        lines.append('  ' + json.dumps(k, ensure_ascii=False) + ': ' +
                     json.dumps(v, ensure_ascii=False) + comma)
    lines.append('}')
    return '\n'.join(lines) + '\n'


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    flags = {a for a in sys.argv[1:] if a.startswith('--')}
    if not args:
        print('usage: python tool/import_translation_csv.py <lang_code> [csv_path]')
        sys.exit(2)
    code = args[0]
    csv_path = args[1] if len(args) > 1 else CSV
    allow_missing = '--allow-missing' in flags

    with io.open(EN, encoding='utf-8') as f:
        en = json.load(f, object_pairs_hook=collections.OrderedDict)

    # Read translations keyed by ARB key.
    translations = {}
    with io.open(csv_path, encoding='utf-8-sig', newline='') as f:
        reader = csv.DictReader(f)
        col = find_lang_column(reader.fieldnames or [], code)
        if col is None:
            print('ERROR: no column for "%s" in %s.\n  Columns: %s' %
                  (code, csv_path, ', '.join(reader.fieldnames or [])))
            sys.exit(1)
        for row in reader:
            key = (row.get('Key') or '').strip()
            if key:
                translations[key] = (row.get(col) or '').strip()

    errors = []
    missing = []
    out = collections.OrderedDict()
    for k, v in en.items():
        if k == '@@locale':
            out[k] = code
            continue
        if k.startswith('@'):
            out[k] = v          # copy metadata verbatim
            continue
        if k not in translations:
            errors.append('CSV is missing key "%s" (stale CSV? re-run '
                          'gen_translation_csv.py)' % k)
            out[k] = v
            continue
        t = translations[k]
        if not t:
            missing.append(k)
            out[k] = v          # fall back to English for now
            continue
        en_ph = placeholder_names(v)
        t_ph = placeholder_names(t)
        dropped = en_ph - t_ph
        if dropped:
            errors.append('key "%s": translation dropped placeholder(s) %s'
                          % (k, ', '.join('{%s}' % p for p in sorted(dropped))))
        if ('plural' in v) != ('plural' in t):
            errors.append('key "%s": ICU plural structure mismatch '
                          '(English %s plural, translation %s)'
                          % (k, 'has' if 'plural' in v else 'has no',
                             'has' if 'plural' in t else 'has none'))
        out[k] = t

    if missing and not allow_missing:
        errors.append('%d key(s) have no translation. Fill them in, or re-run '
                      'with --allow-missing to ship English for those.\n  '
                      'First few: %s' % (len(missing), ', '.join(missing[:8])))

    if errors:
        print('VALIDATION FAILED — nothing written:')
        for e in errors:
            print('  - ' + e)
        sys.exit(1)

    dest = 'lib/l10n/app_%s.arb' % code
    with io.open(dest, 'w', encoding='utf-8') as f:
        f.write(serialize(out))
    n = sum(1 for k in en if not k.startswith('@') and k != '@@locale')
    note = (' (%d filled with English via --allow-missing)' % len(missing)
            ) if missing else ''
    print('wrote %s — %d message keys%s' % (dest, n, note))
    print('next: flutter gen-l10n  →  add to kSupportedLanguages  →  flutter test')


if __name__ == '__main__':
    main()
