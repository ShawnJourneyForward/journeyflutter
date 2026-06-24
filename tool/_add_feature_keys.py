#!/usr/bin/env python3
"""One-shot: append the new feature strings to app_en.arb (template only).

Adds the keys for the "What I've learned" safety-plan screen, the TIPP module,
the accessibility summaries, and the new entry-point labels. Idempotent:
re-running overwrites the same keys in place rather than duplicating them.

After this, run tool/sync_stub_arbs.py then `flutter gen-l10n`.
"""
import json
import io
import collections

EN = 'lib/l10n/app_en.arb'


def ph(**types):
    """Build a placeholders meta block: ph(count='int', window='String')."""
    return {k: {'type': v} for k, v in types.items()}


# (key, english value, meta-dict-or-None)
ENTRIES = [
    # ── "What I've learned" screen ──────────────────────────────────────────
    ('learnedTitle', "What I've learned", None),
    ('learnedShareButton', 'Share my plan', None),
    ('learnedSubtitle',
     "Quiet patterns from your own check-ins — kept on this device, no judgement.",
     None),
    ('learnedEmptyTitle', 'Your insights are still growing', None),
    ('learnedEmptyBody',
     "As you log how cravings go and what you did about them, this page fills "
     "with what actually works for you. Nothing to get right — just keep "
     "checking in.",
     None),
    ('learnedEmptyCta', 'Check in now', None),
    ('learnedWorkedHeader', "WHAT'S WORKED FOR YOU", None),
    ('learnedWorkedIntro',
     "When you tried these, here's how often the urge passed without a slip.",
     None),
    ('learnedWorkedStat', 'stayed sober {sober} of {total}',
     {'placeholders': ph(sober='int', total='int')}),
    ('learnedRiskHeader', 'YOUR TENDER HOURS', None),
    ('learnedRiskBody',
     '{count} of your {total} logged cravings landed around {window}. '
     'Worth planning something steadying for then.',
     {'placeholders': {'count': {'type': 'int'},
                       'total': {'type': 'int'},
                       'window': {'type': 'String'}}}),
    ('learnedHaltHeader', "WHAT'S OFTEN UNDERNEATH", None),
    ('learnedHaltBody', 'Your cravings most often showed up when you were:',
     None),
    ('learnedTimesCount', '{count, plural, =1{1 time} other{{count} times}}',
     {'placeholders': ph(count='int')}),
    ('learnedTriggersHeader', 'YOUR COMMON TRIGGERS', None),
    ('learnedTriggersIntro', "The situations you've named most often:", None),
    ('learnedTriggerChip', '{label} ×{count}',
     {'placeholders': {'label': {'type': 'String'},
                       'count': {'type': 'int'}}}),
    ('learnedWinsHeader', 'YOUR WINS', None),
    ('learnedWinsRidden',
     '{count, plural, =1{1 urge ridden out} other{{count} urges ridden out}}',
     {'placeholders': ph(count='int')}),
    ('learnedWinsSober',
     '{count, plural, =1{stayed sober through 1 craving} '
     'other{stayed sober through {count} cravings}}',
     {'placeholders': ph(count='int')}),
    ('learnedPlanHeader', 'YOUR PLAN WHEN A CRAVING HITS', None),
    ('learnedPlanEmpty',
     "You haven't written a plan yet. A few lines now can carry you through a "
     "hard moment later.",
     None),
    ('learnedPlanCreate', 'Create my plan', None),
    ('learnedPlanEdit', 'Edit plan', None),
    ('learnedReasonsHeader', "WHY YOU'RE DOING THIS", None),
    ('learnedFooter',
     'Slips are information, not failure. Every line here is something you '
     'learned by showing up.',
     None),
    ('learnedShareHeading', 'My recovery safety plan', None),

    # ── TIPP module ─────────────────────────────────────────────────────────
    ('tippTitle', 'TIPP — fast reset', None),
    ('tippIntroTitle', 'When it spikes past thinking', None),
    ('tippIntro',
     'These four shift your body chemistry in minutes — no thinking required. '
     'Pick one and follow along.',
     None),
    ('tippTempLabel', 'Temperature', None),
    ('tippTempWhy', 'Cold on your face slows a racing heart fast.', None),
    ('tippTempStep1', 'Fill a bowl with cold water, or grab a cold pack or ice.',
     None),
    ('tippTempStep2',
     'Hold your breath and put your face in the cold water — or hold the cold '
     'to your eyes and cheeks — for about 30 seconds.',
     None),
    ('tippTempStep3',
     'Notice your body settle as your heart rate drops. Repeat once if you '
     'need to.',
     None),
    ('tippIntenseLabel', 'Intense movement', None),
    ('tippIntenseWhy', 'A short burst burns off the surge of stress hormones.',
     None),
    ('tippIntenseStep1',
     'Pick something you can do hard for a short burst — jumping jacks, '
     'running on the spot, fast stairs.',
     None),
    ('tippIntenseStep2',
     "Go all-out for 1 to 5 minutes, until you're a little out of breath.",
     None),
    ('tippIntenseStep3',
     'Let your breathing come back down. The urge usually drops with it.',
     None),
    ('tippPacedLabel', 'Paced breathing', None),
    ('tippPacedWhy',
     "Longer out-breaths than in-breaths switch on the body's calming system.",
     None),
    ('tippPacedHint', 'Follow the circle. The out-breath is the longest part.',
     None),
    ('tippBreatheIn', 'Breathe in', None),
    ('tippHold', 'Hold', None),
    ('tippBreatheOut', 'Breathe out', None),
    ('tippPmrLabel', 'Paired muscle relaxation', None),
    ('tippPmrWhy',
     'Tense as you breathe in, release as you breathe out — tension leaves '
     'with the breath.',
     None),
    ('tippPmrStep1',
     'Breathe in and tense a muscle group — fists, shoulders, or jaw — firmly '
     'but not to the point of pain.',
     None),
    ('tippPmrStep2', 'Hold the tension for a few seconds while you notice it.',
     None),
    ('tippPmrStep3',
     'Breathe out and let it go all at once. Move through your body, group by '
     'group.',
     None),
    ('tippStartTimer', 'Start 30-second timer', None),
    ('tippTimerRemaining', '{seconds}s', {'placeholders': ph(seconds='int')}),
    ('tippNeedMore', 'Need more than this right now?', None),
    ('tippCrisisButton', 'Crisis lines', None),

    # ── Entry-point labels ──────────────────────────────────────────────────
    ('emergencyTippTitle', 'TIPP reset', None),
    ('progressLearnedCardTitle', "What I've learned", None),
    ('progressLearnedCardSubtitle',
     'Your patterns & safety plan, from your own logs', None),
    ('slipSupportTryTipp', 'Try a TIPP reset', None),
    ('slipSupportTryTippSub', 'Fast body-based skills for when it spikes', None),
    ('planToolkitTippLabel', 'TIPP reset', None),
    ('planToolkitTippSub', 'Temperature · move · breathe · release',
     None),

    # ── Accessibility summaries ─────────────────────────────────────────────
    ('a11ySoberDuration',
     '{days} days, {hours} hours, {minutes} minutes, {seconds} seconds sober',
     {'placeholders': ph(days='int', hours='int', minutes='int',
                         seconds='int')}),
    ('a11yCountdownDuration',
     'Starts in {days} days, {hours} hours, {minutes} minutes, {seconds} seconds',
     {'placeholders': ph(days='int', hours='int', minutes='int',
                         seconds='int')}),
    ('a11yHeatmapSummary',
     '{count, plural, =0{Cravings heatmap, last 28 days. None logged yet.} '
     '=1{Cravings heatmap, last 28 days. 1 logged.} '
     'other{Cravings heatmap, last 28 days. {count} logged.}}',
     {'placeholders': ph(count='int')}),
    ('a11yHeatmapDayCravings',
     '{count, plural, =0{no cravings} =1{1 craving} other{{count} cravings}}',
     {'placeholders': ph(count='int')}),
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
