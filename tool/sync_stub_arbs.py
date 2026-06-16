#!/usr/bin/env python3
"""Sync the non-English ARB stubs to the English template.

app_af/es/pt/zu.arb are English-mirror scaffolds awaiting a real translation
pass (the app ships English-only until a language is enabled in app_locales.dart).
They must hold the SAME key set and placeholder definitions as app_en.arb or the
generated localizations warn and the locale-parity tests fail.

This rewrites each stub as an exact copy of app_en.arb with only "@@locale"
changed. Values stay English (the translator overwrites them later via the CSV).
Re-run whenever new keys are added to app_en.arb.
"""
import json
import io
import collections

EN = 'lib/l10n/app_en.arb'
STUBS = ['af', 'es', 'pt', 'zu']


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
    with io.open(EN, encoding='utf-8') as f:
        en = json.load(f, object_pairs_hook=collections.OrderedDict)
    for lang in STUBS:
        d = collections.OrderedDict(en)
        d['@@locale'] = lang
        with io.open('lib/l10n/app_{}.arb'.format(lang), 'w', encoding='utf-8') as f:
            f.write(serialize(d))
    n = sum(1 for k in en if not k.startswith('@'))
    print('synced {} stubs to {} message keys each'.format(len(STUBS), n))


if __name__ == '__main__':
    main()
