#!/usr/bin/env python3
"""One-shot: insert the Body Care module strings into all 6 app_*.arb, after the
existing @plannerBodyJourney anchor. English text in every locale (stubs); real
translations flow through the handoff pipeline. Idempotent."""
import io
import json
import glob

SENTINEL = '"bodyCareTitle"'
ANCHOR = '"@plannerBodyJourney":'

# (key, english, description) — placeholders handled specially below.
PAIRS = [
    ("bodyCareTitle", "Body Care", "Title of the recovery-safe weight/body module."),
    ("bodyCareGateTitle", "How do you want to care for your body here?",
     "Opt-in gate heading: how the user wants to engage with the body module."),
    ("bodyCareGateBody", "There's no right answer, and you can change this anytime.",
     "Reassuring subtitle under the body-care opt-in gate."),
    ("bodyCareModeFeelings", "Track how I feel",
     "Gate option: engage with the module without ever seeing a weight number."),
    ("bodyCareModeFeelingsDesc", "No numbers — just wins and how your body feels.",
     "Description of the number-free body-care mode."),
    ("bodyCareModeSometimes", "Weigh now and then",
     "Gate option: include occasional, gentle weighing."),
    ("bodyCareModeSometimesDesc",
     "A gentle, occasional check-in. You can hide the number anytime.",
     "Description of the occasional-weighing body-care mode."),
    ("bodyCareHeroNew", "Your garden is ready. Tend it with one small act of care.",
     "Body-care plant hero headline before any care has been logged."),
    ("bodyCareTendedThisWeek", "You've tended your journey this week.",
     "Sub-line on the plant hero when the user has done some care this week."),
    ("bodyCareTendThisWeek",
     "Tend your journey this week — log a win or a moment of care.",
     "Sub-line on the plant hero nudging a first act of care this week."),
    ("bodyCareWinsTitle", "Today's wins",
     "Section label above the non-scale-victory deck."),
    ("bodyCareWinLogged", "Win logged.",
     "Snackbar confirmation after logging a non-scale victory."),
    ("bodyCareCustomWinTitle", "Your own win",
     "Title of the free-text 'log your own win' dialog / deck chip."),
    ("bodyCareCustomWinHint", "Something kind your body did today…",
     "Hint text in the custom-win text field."),
    ("bodyCareWinEnergy", "More energy today", "Preset non-scale victory."),
    ("bodyCareWinClothes", "Clothes felt better", "Preset non-scale victory."),
    ("bodyCareWinMoved", "Moved without getting winded", "Preset non-scale victory."),
    ("bodyCareWinCraving", "Rode out a craving", "Preset non-scale victory."),
    ("bodyCareWinSleep", "Slept well", "Preset non-scale victory."),
    ("bodyCareWinNourished", "Ate to nourish, not punish", "Preset non-scale victory."),
    ("bodyCareWinStrong", "Felt strong", "Preset non-scale victory."),
    ("bodyCareWinShowedUp", "I just showed up today", "Preset non-scale victory."),
    ("bodyCareWinCustom", "A win of my own",
     "Fallback label for a custom non-scale victory with no text."),
    ("bodyCareRecentTitle", "Recent care",
     "Heading of the recent wins + reflections list."),
    ("bodyCareNoWinsYet", "Your wins will gather here.",
     "Empty state for the recent-care list."),
    ("bodyCareShowNumbers", "Show the number",
     "Button/tooltip to reveal hidden weight numbers."),
    ("bodyCareHideNumbers", "Hide the number",
     "Tooltip to frost all weight numbers (the take-a-break escape hatch)."),
    ("bodyCareNumbersHidden", "The number is resting. Your care continues.",
     "Shown in place of weight values while numbers are hidden."),
    ("bodyCareNoWeighIn", "No weigh-in yet — only when you're ready.",
     "Body-care weight card caption before any weigh-in exists."),
    ("bodyCareLogWeighIn", "Log a weigh-in",
     "Button + sheet title to record an occasional weigh-in."),
    ("bodyCareTrendTitle", "Gentle trend",
     "Title of the body-care weight trend chart card."),
    ("bodyCareTrendBandHint",
     "Day-to-day weight naturally drifts up and down — a small bump is just your body, not a setback.",
     "Reassurance under the weight trend that fluctuation is normal."),
    ("bodyCareTowardGentleGoal", "Toward your gentle goal",
     "Caption under the body-care goal progress bar (no number)."),
    ("bodyCareEnterWeight", "Enter a weight to log it.",
     "Validation message in the weigh-in sheet."),
    ("bodyCareGoalTooLow",
     "That goal looks very low. Let's choose a gentler target — your wellbeing matters far more than a number.",
     "Gentle block when a weight goal is dangerously low."),
    ("bodyCareGoalTooMuch",
     "That's a big change to aim for at once. A smaller, kinder goal tends to be more sustainable — and you can always set a new one later.",
     "Gentle block when an intended weight loss is very large."),
    ("bodyCareUseGentlerGoal", "Choose a gentler goal",
     "Dismiss button on the unsafe-goal guidance dialog."),
]

# Build the inserted block text.
parts = []
for key, en, desc in PAIRS:
    parts.append('  "%s": "%s",\n' % (key, en))
    parts.append('  "@%s": {"description": "%s"},\n' % (key, desc))
# Placeholder strings (added at the end of the block).
parts.append(
    '  "bodyCareWeeksTended": "{count, plural, =1{1 week tended} '
    'other{{count} weeks tended}}",\n')
parts.append(
    '  "@bodyCareWeeksTended": {"description": "Plant hero headline: how many '
    'distinct weeks the user has tended their body-care journey.", '
    '"placeholders": {"count": {"type": "int"}}},\n')
parts.append('  "bodyCareWeightCaption": "Latest {weight}",\n')
parts.append(
    '  "@bodyCareWeightCaption": {"description": "Quiet latest-weight caption on '
    'the body-care weight card.", "placeholders": {"weight": {"type": '
    '"String"}}},\n')
BLOCK = ''.join(parts)

ALL_KEYS = [k for k, _, _ in PAIRS] + ['bodyCareWeeksTended', 'bodyCareWeightCaption']

for path in sorted(glob.glob('lib/l10n/app_*.arb')):
    with io.open(path, encoding='utf-8') as f:
        lines = f.readlines()
    if any(SENTINEL in ln for ln in lines):
        print('skip (exists):', path)
        continue
    idx = next((i for i, ln in enumerate(lines) if ANCHOR in ln), None)
    assert idx is not None, ('anchor not found in', path)
    lines.insert(idx + 1, BLOCK)
    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    d = json.load(io.open(path, encoding='utf-8'))  # validate JSON
    for k in ALL_KEYS:
        assert k in d, ('missing key after insert: %s in %s' % (k, path))
    print('inserted + valid ->', path)
