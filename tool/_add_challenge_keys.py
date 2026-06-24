#!/usr/bin/env python3
"""One-shot: append the 100-Day Challenge strings to app_en.arb (template only).

Idempotent: re-running overwrites the same keys in place rather than
duplicating them. After this, run tool/sync_stub_arbs.py then `flutter gen-l10n`.
"""
import json
import io
import collections

EN = 'lib/l10n/app_en.arb'


def ph(**types):
    """Build a placeholders meta block: ph(day='int')."""
    return {k: {'type': v} for k, v in types.items()}


# (key, english value, meta-dict-or-None)
ENTRIES = [
    ('challengeTitle', '100-day challenge', None),
    ('challengeSubtitle',
     'One hundred days, marked off one at a time.', None),
    ('challengeCountLabel', '{done} of {total} days',
     {'placeholders': ph(done='int', total='int')}),
    ('challengeHint',
     'Tap a day to tick it off. Press and hold to add a sticker or clear it.',
     None),
    ('challengeOnDay', "You're on day {day} of your streak.",
     {'placeholders': ph(day='int')}),
    ('challengeComplete', "All 100 days. What a thing you've done. 🏆", None),
    ('challengeStickerSheetTitle', 'Day {day}',
     {'placeholders': ph(day='int')}),
    ('challengePickSticker', 'Choose a sticker', None),
    ('challengeClearDay', 'Clear this day', None),
    ('challengeShareSectionLabel', 'SHARE YOUR PROGRESS', None),
    ('challengeShareButton', 'Share my progress', None),
    ('challengeShareCardBrand', '100 DAYS SOBER', None),
    ('challengeShareText',
     '{done} of my 100 sober days, marked off. 🌱 One day at a time.',
     {'placeholders': ph(done='int')}),
    ('challengeReset', 'Reset challenge', None),
    ('challengeResetTitle', 'Reset the challenge?', None),
    ('challengeResetBody',
     'This clears every day you have marked off. Your sobriety streak and all '
     'your other data stay exactly as they are.',
     None),
    ('challengeResetConfirm', 'Reset', None),
    ('challengeResetCancel', 'Keep my progress', None),
    ('challengeA11yDayDone', 'Day {day}, marked off',
     {'placeholders': ph(day='int')}),
    ('challengeA11yDayTodo', 'Day {day}, not yet marked',
     {'placeholders': ph(day='int')}),
]


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

    added, updated = 0, 0
    for key, value, meta in ENTRIES:
        if key in en:
            updated += 1
        else:
            added += 1
        en[key] = value
        en['@' + key] = meta if meta is not None else {}

    with io.open(EN, 'w', encoding='utf-8') as f:
        f.write(serialize(en))

    total = sum(1 for k in en if not k.startswith('@'))
    print('added {} keys, updated {} existing; {} message keys total'.format(
        added, updated, total))


if __name__ == '__main__':
    main()
