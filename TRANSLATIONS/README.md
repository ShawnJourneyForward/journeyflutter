# Journey Forward — Translations

This folder holds everything needed to translate the app into a new language.

## Quick start — volunteer hand-off packets (recommended)

For handing one language to one volunteer, don't send the big multi-column
master CSV. Instead generate ready-to-send packets:

```
python tool/gen_handoff_packets.py
```

This writes, under `TRANSLATIONS/handoff/`, three files **per language**:

- `journey_<Lang>_<code>.csv` — a clean sheet with a single **empty** target
  column and a **Batch** column (1 = short core UI, 2 = sentences,
  3 = long-form). Rows are sorted so Batch 1 is at the top, so a volunteer who
  only finishes the first batch still makes the app feel native.
- `READ-ME-FIRST_<Lang>.md` — a short, warm one-page guide for the volunteer.
- `ask-message_<Lang>.txt` — a paste-ready WhatsApp/email message to send them.

When a filled-in file comes back, import its single column directly (partial is
fine — blanks fall back to English):

```
python tool/import_translation_csv.py af TRANSLATIONS/handoff/journey_Afrikaans_af.csv --allow-missing
```

Then follow the "adding a finished language" steps below from `flutter gen-l10n`.

## For the translator

Open **`journey_forward_strings.csv`** in Google Sheets or Excel. Each row is
one piece of text shown in the app.

| Column | What to do |
| --- | --- |
| **Section** | Just a grouping (which part of the app the text is in). Read-only. |
| **Key** | The app's internal name for the string. **Do not change or translate.** |
| **English** | The source text. |
| **Placeholders** | Tokens like `{count}` or `{title}`. **Keep them exactly as-is** in your translation — the app fills them in at runtime (e.g. a name, a number). You may move them within the sentence to suit the grammar. |
| **Context** | A short note about where/how the text appears, to help you choose the right wording. |
| **Afrikaans / Spanish / Portuguese / isiZulu** | Type your translation here. Add a new column for any other language. |

### A few rules that keep the app working

1. **Never edit the `Key` column.**
2. **Keep every `{placeholder}` token.** `Day {count}` → (es) `Día {count}` ✅, not `Día 5` ❌.
3. Some English values use **plural syntax**, e.g.
   `{count, plural, =1{1 day} other{{count} days}}`. Translate the words inside
   `=1{…}` and `other{…}`, keep the structure and the `{count}` tokens. Languages
   with more plural forms may add `=2{…}` / `few{…}` / `many{…}` branches.
4. Keep emoji (🔔, ✨, etc.) if present.
5. Tone: warm, calm, plain-language, non-judgemental. This is a recovery app —
   avoid clinical or shaming phrasing.

When done, send the file back with your language column filled in.

## For the developer — adding a finished language

1. Drop the translator's filled-in CSV back at
   `TRANSLATIONS/journey_forward_strings.csv`, then import the language column
   straight into its ARB — this validates as it goes (fails loudly on a missing
   key, a dropped `{placeholder}`, or a broken plural; writes nothing if so):

   ```
   python tool/import_translation_csv.py es        # reads the "Spanish (es)" column
   ```

   (Use `--allow-missing` to ship English for any still-blank rows.)
2. Run `flutter gen-l10n`.
3. Add one line to `kSupportedLanguages` in `lib/l10n/app_locales.dart`, e.g.
   `AppLanguage(Locale('es'), 'Spanish', 'Español'),`.
4. `flutter test test/unit/localization_keys_test.dart` — the "not an English
   clone" check activates automatically once a language is enabled and fails a
   half-translated ARB before it can ship.
5. That's it — the Settings → Language picker and `MaterialApp.supportedLocales`
   both read from that list, so the language goes live with no other changes.
   `intl` date/number/currency formatting follows the active locale automatically.

> Non-Latin scripts (CJK, Arabic, Cyrillic, …) additionally need a script-covering
> font added to `fontFamilyFallback`, and a right-to-left language needs an RTL
> layout pass — the current Fraunces/Inter fonts cover af/es/pt/zu (all LTR).

## Regenerating this CSV

The source of truth is `lib/l10n/app_en.arb`. Whenever new strings are added,
regenerate the sheet with:

```
python tool/gen_translation_csv.py
```

> Coverage note: this CSV is generated from every key currently in
> `app_en.arb`. As the last hardcoded strings in the UI are migrated into the
> ARB, re-run the command above to pick them up before sending a final copy to
> a translator.
