#!/usr/bin/env python3
"""Generate friendly, per-language translation hand-off packets for volunteers.

Reads the master TRANSLATIONS/journey_forward_strings.csv (whose language
columns are English stubs) and, for EACH target language, emits:

  TRANSLATIONS/handoff/journey_<Language>_<code>.csv
      One clean spreadsheet with a SINGLE, EMPTY target column for that
      language, a "Batch" priority column (1=Core UI, 2=Sentences,
      3=Long-form) and the rows sorted so Batch 1 floats to the top. The
      column header is "<Language> (<code>)" so tool/import_translation_csv.py
      auto-detects it on the way back in.

  TRANSLATIONS/handoff/READ-ME-FIRST_<Language>.md
      A warm, short one-pager the volunteer actually reads.

  TRANSLATIONS/handoff/ask-message_<Language>.txt
      A paste-ready WhatsApp/email ask you send to the person.

The master CSV is never modified. Re-run after gen_translation_csv.py picks up
new strings.
"""
import csv
import io
import os
import re

MASTER = 'TRANSLATIONS/journey_forward_strings.csv'
OUTDIR = 'TRANSLATIONS/handoff'

LANGS = [
    ('af', 'Afrikaans'),
    ('zu', 'isiZulu'),
    ('de', 'German'),
    ('es', 'Spanish'),
    ('pt', 'Portuguese'),
]

WORD = re.compile(r"[\w']+")


def batch_of(english):
    w = len(WORD.findall(english))
    if w <= 6:
        return 1
    if w <= 25:
        return 2
    return 3


def load_rows():
    with io.open(MASTER, encoding='utf-8-sig', newline='') as f:
        rows = list(csv.DictReader(f))
    out = []
    for i, r in enumerate(rows):
        en = (r.get('English') or '').strip()
        if not en:
            continue
        out.append({
            'order': i,
            'batch': batch_of(en),
            'Section': (r.get('Section') or '').strip(),
            'Key': (r.get('Key') or '').strip(),
            'English': r.get('English') or '',
            'Placeholders': r.get('Placeholders') or '',
            'Context': r.get('Context') or '',
        })
    # Batch 1 first, then original order within each batch.
    out.sort(key=lambda r: (r['batch'], r['order']))
    return out


def write_csv(rows, code, lang):
    col = '%s (%s)' % (lang, code)
    path = os.path.join(OUTDIR, 'journey_%s_%s.csv' % (lang, code))
    with io.open(path, 'w', encoding='utf-8-sig', newline='') as f:
        w = csv.writer(f)
        w.writerow(['Batch', 'Section', 'Key', 'English',
                    'Placeholders', 'Context', col])
        for r in rows:
            w.writerow([r['batch'], r['Section'], r['Key'], r['English'],
                        r['Placeholders'], r['Context'], ''])
    return path


READ_ME = """# Translating Journey Forward into {lang}

Thank you — truly. Journey Forward is a free, offline app that helps people stay
sober, and a translation means it can help {lang}-speaking people too. There's no
deadline and no pressure; even a little helps.

## How to do it

1. Open **`journey_{lang}_{code}.csv`** in Google Sheets or Excel.
2. Each row is one piece of text from the app. Type your translation into the
   **last column** (titled "{lang} ({code})"). That column starts empty — that's
   your job; everything to its left is just reference.
3. Save the file and send it back. Done.

## Work top-to-bottom — the rows are sorted by importance

The **Batch** column tells you what matters most. If you only have time for some
of it, start at the top and go as far as you can:

| Batch | What it is | Why |
| --- | --- | --- |
| **1** | Short buttons, tabs and labels | Does the most — it makes the whole app *look* like it speaks {lang}. Quick: a few words each. |
| **2** | Sentences and helper text | The substance. |
| **3** | Long paragraphs (onboarding, essays) | Nice-to-have. Buried and rarely read — leave for last or skip. |

Finishing **just Batch 1** already makes the app feel native. That alone is a win.

## Five small rules that keep the app working

1. **Don't touch the `Key` column.** It's the app's internal name — translating
   it breaks the text.
2. **Keep every `{{token}}` exactly as-is.** Things like `{{count}}` or `{{name}}`
   get replaced by a real number or name when the app runs. `Day {{count}}` →
   `Dag {{count}}` ✅ — never `Dag 5` ❌. You *may* move the token to wherever it
   reads naturally in {lang}.
3. **Plurals:** a few rows look like
   `{{count, plural, =1{{1 day}} other{{{{count}} days}}}}`. Translate only the
   words inside the `{{ }}` braces; keep the structure and the `{{count}}`.
4. **Keep any emoji** (🔔 ✨ etc.) where they are.
5. **Tone:** warm, calm, plain, never clinical or shaming. Picture talking gently
   to a friend who's having a hard day. When a phrase doesn't translate literally,
   choose the wording a kind person would actually say in {lang}.

If a row is confusing, read the **Context** column — it says where the text shows
up. Still unsure? Leave it blank and flag it; that's completely fine.

Thank you for helping someone you'll never meet have a better day. 🌱
"""

ASK = """Hey! I built a free app called Journey Forward — it helps people stay sober, \
works fully offline, no ads, no accounts, nothing tracked. I'd love to make it \
available in {lang} so it can help more people, and I thought of you.

Would you be up for translating some of it? It's a spreadsheet — English on one \
side, you type the {lang} on the other. It's sorted by importance, so even doing \
just the first batch (short buttons and labels, a few evenings' worth) would make \
a real difference. No deadline, no pressure, stop whenever.

If you're in, I'll send you the file and a short one-page guide. Thank you either \
way 🙏
"""


def main():
    os.makedirs(OUTDIR, exist_ok=True)
    rows = load_rows()
    b1 = sum(1 for r in rows if r['batch'] == 1)
    b2 = sum(1 for r in rows if r['batch'] == 2)
    b3 = sum(1 for r in rows if r['batch'] == 3)
    print('loaded %d translatable strings (Batch1=%d, Batch2=%d, Batch3=%d)'
          % (len(rows), b1, b2, b3))
    for code, lang in LANGS:
        csv_path = write_csv(rows, code, lang)
        rm_path = os.path.join(OUTDIR, 'READ-ME-FIRST_%s.md' % lang)
        ask_path = os.path.join(OUTDIR, 'ask-message_%s.txt' % lang)
        with io.open(rm_path, 'w', encoding='utf-8') as f:
            f.write(READ_ME.format(lang=lang, code=code))
        with io.open(ask_path, 'w', encoding='utf-8') as f:
            f.write(ASK.format(lang=lang))
        print('  %-10s -> %s  + guide + ask-message' % (lang, csv_path))
    print('\nWhen a file comes back, import it with:')
    for code, lang in LANGS:
        print('  python tool/import_translation_csv.py %s '
              'TRANSLATIONS/handoff/journey_%s_%s.csv --allow-missing'
              % (code, lang, code))


if __name__ == '__main__':
    main()
