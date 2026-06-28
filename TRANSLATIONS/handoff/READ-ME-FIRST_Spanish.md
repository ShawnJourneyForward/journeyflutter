# Translating Journey Forward into Spanish

Thank you — truly. Journey Forward is a free, offline app that helps people stay
sober, and a translation means it can help Spanish-speaking people too. There's no
deadline and no pressure; even a little helps.

## How to do it

1. Open **`journey_Spanish_es.csv`** in Google Sheets or Excel.
2. Each row is one piece of text from the app. Type your translation into the
   **last column** (titled "Spanish (es)"). That column starts empty — that's
   your job; everything to its left is just reference.
3. Save the file and send it back. Done.

## Work top-to-bottom — the rows are sorted by importance

The **Batch** column tells you what matters most. If you only have time for some
of it, start at the top and go as far as you can:

| Batch | What it is | Why |
| --- | --- | --- |
| **1** | Short buttons, tabs and labels | Does the most — it makes the whole app *look* like it speaks Spanish. Quick: a few words each. |
| **2** | Sentences and helper text | The substance. |
| **3** | Long paragraphs (onboarding, essays) | Nice-to-have. Buried and rarely read — leave for last or skip. |

Finishing **just Batch 1** already makes the app feel native. That alone is a win.

## Five small rules that keep the app working

1. **Don't touch the `Key` column.** It's the app's internal name — translating
   it breaks the text.
2. **Keep every `{token}` exactly as-is.** Things like `{count}` or `{name}`
   get replaced by a real number or name when the app runs. `Day {count}` →
   `Dag {count}` ✅ — never `Dag 5` ❌. You *may* move the token to wherever it
   reads naturally in Spanish.
3. **Plurals:** a few rows look like
   `{count, plural, =1{1 day} other{{count} days}}`. Translate only the
   words inside the `{ }` braces; keep the structure and the `{count}`.
4. **Keep any emoji** (🔔 ✨ etc.) where they are.
5. **Tone:** warm, calm, plain, never clinical or shaming. Picture talking gently
   to a friend who's having a hard day. When a phrase doesn't translate literally,
   choose the wording a kind person would actually say in Spanish.

If a row is confusing, read the **Context** column — it says where the text shows
up. Still unsure? Leave it blank and flag it; that's completely fine.

Thank you for helping someone you'll never meet have a better day. 🌱
