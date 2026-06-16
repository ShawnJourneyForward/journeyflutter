# Journey Forward — Translations

This folder holds everything needed to translate the app into a new language.

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

1. Save the translator's column into `lib/l10n/app_<code>.arb` (one key per line,
   same keys as `app_en.arb`). The existing `app_af.arb` / `app_es.arb` /
   `app_pt.arb` / `app_zu.arb` files are scaffolds you can overwrite.
2. Run `flutter gen-l10n`.
3. Add one line to `kSupportedLanguages` in `lib/l10n/app_locales.dart`, e.g.
   `AppLanguage(Locale('es'), 'Spanish', 'Español'),`.
4. That's it — the Settings → Language picker and `MaterialApp.supportedLocales`
   both read from that list, so the language goes live with no other changes.

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
