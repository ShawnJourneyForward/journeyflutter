#!/usr/bin/env python3
"""One-shot: split the old 'Puzzle' tile into real games + a separate
'Calm Activities' tile.

  - ADD new keys to every app_*.arb (Puzzles home header, Slide-puzzle strings,
    2048 strings, and the new Calm Activities tile label).
  - UPDATE two existing values so the labels stop lying:
      emergencyPuzzleTitle  "Puzzle"           -> "Puzzles"
      puzzleHomeTitle       "Mindful Activities"-> "Calm Activities"
    (en is the source; the 5 stub languages are English copies, so updating the
    value everywhere just keeps the stubs faithful — translators re-translate.)

The 5 moved activities reuse their EXISTING keys (puzzleActivity0/1/3/4/5 + the
per-activity detail keys), so nothing there changes.
"""
import io
import json
import glob

ANCHOR = '"puzzleHomeSubtitle":'

# (key, value, description)
NEW_KEYS = [
    ("puzzlesHomeTitle", "Puzzles",
     "Header on the Puzzles games hub (the Toolkit 'Puzzles' tile)."),
    ("puzzlesHomeSubtitle", "A few minutes of focused play",
     "Subheader on the Puzzles games hub."),
    ("puzzleSlideLabel", "Slide Puzzle",
     "Title of the classic sliding 15-puzzle game."),
    ("puzzleSlideDesc", "Slide the tiles into order, 1 through 15.",
     "One-line description of the slide puzzle on the games hub."),
    ("puzzleSlideDuration", "5 min",
     "Rough play time shown on the slide puzzle card."),
    ("puzzleSlideHint", "Tap a tile next to the gap to slide it in.",
     "In-game hint for the slide puzzle."),
    ("puzzle2048Label", "2048",
     "Title of the 2048 merge game."),
    ("puzzle2048Desc", "Swipe to merge matching numbers. Can you reach 2048?",
     "One-line description of 2048 on the games hub."),
    ("puzzle2048Duration", "10 min",
     "Rough play time shown on the 2048 card."),
    ("puzzle2048Score", "Score",
     "Label before the running score in 2048."),
    ("puzzle2048Win", "You reached 2048!",
     "Win banner heading in 2048."),
    ("puzzle2048GameOver", "Board full — no moves left.",
     "Game-over message in 2048 when no moves remain."),
    ("puzzle2048Hint", "Swipe up, down, left or right to move the tiles.",
     "In-game hint for 2048."),
    ("puzzle2048KeepGoing", "Keep going",
     "Button to keep playing 2048 after reaching the 2048 tile."),
    ("emergencyCalmTitle", "Calm Activities",
     "Toolkit tile label for the calm/mindfulness activities (Slow Count, "
     "Gratitude Shuffle, Strength Compass, Now Moment, Colour Calm)."),
]

# existing key -> new value
VALUE_UPDATES = {
    "emergencyPuzzleTitle": "Puzzles",
    "puzzleHomeTitle": "Calm Activities",
}


def block():
    out = []
    for k, v, desc in NEW_KEYS:
        out.append('  ' + json.dumps(k, ensure_ascii=False) + ': '
                   + json.dumps(v, ensure_ascii=False) + ',\n')
        out.append('  ' + json.dumps('@' + k, ensure_ascii=False) + ': '
                   + json.dumps({"description": desc}, ensure_ascii=False)
                   + ',\n')
    return ''.join(out)


BLOCK = block()

for path in sorted(glob.glob('lib/l10n/app_*.arb')):
    with io.open(path, encoding='utf-8') as f:
        lines = f.readlines()

    # 1. Value updates (replace the whole value line, preserve trailing comma).
    for i, ln in enumerate(lines):
        stripped = ln.lstrip()
        for key, newval in VALUE_UPDATES.items():
            if stripped.startswith(json.dumps(key) + ':'):
                indent = ln[:len(ln) - len(stripped)]
                lines[i] = (indent + json.dumps(key) + ': '
                            + json.dumps(newval, ensure_ascii=False) + ',\n')

    # 2. Insert new keys after puzzleHomeSubtitle (skip if already present).
    if not any('"puzzlesHomeTitle"' in ln for ln in lines):
        idx = next((i for i, ln in enumerate(lines)
                    if ln.lstrip().startswith(ANCHOR)), None)
        assert idx is not None, ('anchor not found in', path)
        ins_at = idx + 1
        if ins_at < len(lines) and '"@puzzleHomeSubtitle"' in lines[ins_at]:
            ins_at += 1
        lines.insert(ins_at, BLOCK)

    with io.open(path, 'w', encoding='utf-8') as f:
        f.writelines(lines)

    d = json.load(io.open(path, encoding='utf-8'))  # validate JSON
    assert d['puzzlesHomeTitle'] == 'Puzzles', path
    assert d['emergencyPuzzleTitle'] == 'Puzzles', path
    assert d['puzzleHomeTitle'] == 'Calm Activities', path
    assert d['emergencyCalmTitle'] == 'Calm Activities', path
    assert d['puzzle2048Label'] == '2048', path
    print('ok ->', path)
