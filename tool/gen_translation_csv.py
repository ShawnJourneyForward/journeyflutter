#!/usr/bin/env python3
"""Generate a translator-friendly CSV from lib/l10n/app_en.arb.

Usage: python tool/gen_translation_csv.py

Output: TRANSLATIONS/journey_forward_strings.csv

Columns:
  Section      - grouping inferred from the key prefix (Meetings, CBT, Common…)
  Key          - the ARB key (do NOT translate; the app looks strings up by this)
  English      - the source text to translate
  Placeholders - {tokens} that MUST be kept verbatim in the translation
  Context      - note for the translator (from the @key "description")
  Afrikaans / isiZulu / German / Spanish / Portuguese - each PRE-FILLED with
                 the verbatim English text. The translator edits these cells
                 in place (overwrite English with the translation). They are
                 safe to change freely; the locked reference columns to the
                 left (Key / English / Placeholders / Context) are untouched.

Add more language columns by editing TARGET_LANGUAGES below (or just add a
column in the spreadsheet).
"""
import json
import io
import csv
import os
import re
import collections

ARB = 'lib/l10n/app_en.arb'
OUT_DIR = 'TRANSLATIONS'
OUT = os.path.join(OUT_DIR, 'journey_forward_strings.csv')

# (column header, ISO code) — purely for the translator's convenience.
TARGET_LANGUAGES = [
    ('Afrikaans (af)', 'af'),
    ('isiZulu (zu)', 'zu'),
    ('German (de)', 'de'),
    ('Spanish (es)', 'es'),
    ('Portuguese (pt)', 'pt'),
]


def section_for(key):
    # Leading lowercase run before the first capital → screen/area bucket.
    m = re.match(r'^([a-z0-9]+)', key)
    return (m.group(1).capitalize() if m else 'Other')


def placeholders_for(meta):
    ph = meta.get('placeholders') if isinstance(meta, dict) else None
    if not ph:
        return ''
    return ', '.join('{' + name + '}' for name in ph.keys())


def main():
    with io.open(ARB, encoding='utf-8') as f:
        d = json.load(f, object_pairs_hook=collections.OrderedDict)

    os.makedirs(OUT_DIR, exist_ok=True)
    rows = 0
    with io.open(OUT, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.writer(f)
        w.writerow(['Section', 'Key', 'English', 'Placeholders', 'Context'] +
                   [name for name, _ in TARGET_LANGUAGES])
        for k, v in d.items():
            if k.startswith('@'):
                continue
            if k == '@@locale':
                continue
            meta = d.get('@' + k, {})
            desc = meta.get('description', '') if isinstance(meta, dict) else ''
            # Each language column is PRE-FILLED with the verbatim English text
            # so the translator overwrites it in place. They can change these
            # cells freely without touching the locked reference columns
            # (Key / English / Placeholders / Context), which the app and the
            # import step read — editing a language cell affects nothing else.
            w.writerow([
                section_for(k), k, v, placeholders_for(meta), desc
            ] + [v for _ in TARGET_LANGUAGES])
            rows += 1
    print('wrote {} rows to {}'.format(rows, OUT))


if __name__ == '__main__':
    main()
