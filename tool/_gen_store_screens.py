# -*- coding: utf-8 -*-
"""Generate Play Store promotional screenshots (1080x1920) as self-contained
HTML using the app's REAL fonts + Stillwater palette. Render to PNG with
headless Chrome separately. Mockups faithfully represent each tab."""
import os, urllib.parse

PROJ = r"C:\Users\shawn\Documents\Personal Docs\Personal\Journey Forward Flutter"
FONT_DIR = os.path.join(PROJ, "assets", "fonts")
def furl(name):
    return "file:///" + urllib.parse.quote(os.path.join(FONT_DIR, name).replace("\\", "/"))
INTER, FRAUNCES = furl("Inter-Variable.ttf"), furl("Fraunces-Variable.ttf")

OUT = r"C:\Users\shawn\Desktop\JourneyForward-store-screenshots"
WORK = os.path.join(OUT, "_html")
os.makedirs(WORK, exist_ok=True)

C = {
    "cream": "#F5F2EE", "card": "#FFFDF8", "mint": "#E8F1E8",
    "f50": "#EEF5EE", "f100": "#DCE8DC", "f300": "#8DBBA0", "f500": "#518A6B",
    "f600": "#3E745A", "f700": "#2E5844", "fdark": "#1F4D38", "f800": "#1E3D2F",
    "leaf": "#3F7A5A",
    "s100": "#EDE8E1", "s200": "#D6CFC5", "s300": "#B8AFA3", "s400": "#8D99A6",
    "s500": "#69736F", "s600": "#55605C", "s800": "#26332F",
    "honey": "#C99846", "honey50": "#FAF1DD", "honeySoft": "#F8EBCB",
    "blush": "#C45E5E", "white": "#FFFFFF",
}

def sub(t):
    for k, v in C.items():
        t = t.replace("@@%s@@" % k, v)
    return t

BASE = """
@font-face{font-family:'Inter';src:url('__INTER__');}
@font-face{font-family:'Fraunces';src:url('__FRAUNCES__');}
*{margin:0;padding:0;box-sizing:border-box;-webkit-font-smoothing:antialiased;}
html,body{width:1080px;height:1920px;overflow:hidden;}
body{font-family:'Inter',sans-serif;display:flex;flex-direction:column;}
.cap{padding:96px 78px 18px;text-align:center;}
.cap h1{font-family:'Fraunces',serif;font-weight:600;font-size:86px;line-height:1.04;letter-spacing:-1.5px;}
.cap p{margin-top:26px;font-size:35px;line-height:1.4;font-weight:400;opacity:.86;}
.stage{flex:1;display:flex;align-items:flex-start;justify-content:center;}
.phone{width:566px;height:1146px;margin-top:8px;background:@@cream@@;border-radius:62px;
  overflow:hidden;position:relative;border:14px solid #20302A;
  box-shadow:0 46px 120px rgba(15,35,24,.34),0 0 0 2px rgba(0,0,0,.05);}
.scr{position:absolute;inset:0;display:flex;flex-direction:column;}
.sb{height:46px;display:flex;align-items:center;justify-content:space-between;padding:0 36px;
  font-size:21px;font-weight:600;color:@@s800@@;}
.sb .dots{display:flex;gap:7px;align-items:center;}
.sb .dots i{width:9px;height:9px;border-radius:50%;background:@@s400@@;display:inline-block;}
.body{flex:1;padding:14px 30px 0;overflow:hidden;}
.hd{display:flex;align-items:center;justify-content:space-between;margin:8px 4px 18px;}
.hd .t{font-family:'Fraunces',serif;font-size:42px;font-weight:600;color:@@fdark@@;}
.hd .chip{width:54px;height:54px;border-radius:50%;background:@@mint@@;border:1px solid @@f100@@;
  display:flex;align-items:center;justify-content:center;}
.card{background:@@card@@;border:1px solid @@f100@@;border-radius:30px;padding:26px 28px;
  box-shadow:0 10px 26px rgba(31,77,56,.06);margin-bottom:20px;}
.eyebrow{font-size:19px;letter-spacing:2px;text-transform:uppercase;color:@@s500@@;font-weight:700;}
.nav{height:118px;background:@@card@@;border-top:1px solid @@s100@@;display:flex;align-items:center;
  justify-content:space-around;padding:0 12px 8px;}
.nav .it{display:flex;flex-direction:column;align-items:center;gap:9px;color:@@s400@@;font-size:18px;font-weight:600;}
.nav .it.on{color:@@f600@@;}
.nav .ic{width:34px;height:34px;}
svg{display:block;}
"""

# --- tiny inline icons (stroke) -------------------------------------------
def ic(paths, c="currentColor", sw=2.4, fill="none", vb="0 0 24 24", extra=""):
    return ('<svg viewBox="%s" width="100%%" height="100%%" fill="%s" stroke="%s" '
            'stroke-width="%s" stroke-linecap="round" stroke-linejoin="round" %s>%s</svg>'
            ) % (vb, fill, c, sw, extra, paths)

I_HOME = '<path d="M3 11l9-8 9 8"/><path d="M5 10v10h14V10"/>'
I_PROG = '<path d="M4 20V10"/><path d="M10 20V4"/><path d="M16 20v-7"/><path d="M22 20H2"/>'
I_TOOL = '<path d="M12 3c3 3 4 6 0 12-4-6-3-9 0-12z"/><path d="M12 21c-4-2-6-5-6-9"/><path d="M12 21c4-2 6-5 6-9"/>'
I_JOUR = '<path d="M5 4h11a2 2 0 012 2v14H7a2 2 0 01-2-2V4z"/><path d="M5 16h13"/>'
I_PLAN = '<path d="M13 4l-2 7h5l-3 9"/><circle cx="16" cy="4" r="2"/>'
I_PROF = '<circle cx="12" cy="8" r="4"/><path d="M5 21c0-4 3-6 7-6s7 2 7 6"/>'
I_LOCK = '<rect x="5" y="11" width="14" height="9" rx="2.5"/><path d="M8 11V8a4 4 0 018 0v3"/>'
I_WIFI_OFF = '<path d="M2 2l20 20"/><path d="M5 12.5a11 11 0 015-2.8"/><path d="M2 8.8a16 16 0 014.6-3"/><path d="M19 12.5a11 11 0 00-3.4-2.5"/><path d="M22 8.8a16 16 0 00-5-3.2"/><path d="M9 16a5 5 0 015-1"/><circle cx="12" cy="20" r="1" fill="@@f600@@" stroke="none"/>'
I_SHIELD = '<path d="M12 3l8 3v6c0 5-3.5 8-8 9-4.5-1-8-4-8-9V6z"/><path d="M9 12l2 2 4-4"/>'
I_FLAME = '<path d="M12 3c3 3 4 6 0 12-4-6-3-9 0-12z"/>'
I_CHECK = '<path d="M5 12l4 4 10-10"/>'

def navbar(active):
    items = [("Home", I_HOME), ("Progress", I_PROG), ("Toolkit", I_TOOL),
             ("Journal", I_JOUR), ("Planner", I_PLAN), ("You", I_PROF)]
    out = '<div class="nav">'
    for name, path in items:
        on = " on" if name.lower().startswith(active) else ""
        col = "@@f600@@" if on else "@@s400@@"
        out += '<div class="it%s"><div class="ic">%s</div>%s</div>' % (on, ic(path, col, 2.2), name)
    return out + '</div>'

def screen(active, header_title, body):
    return ('<div class="sb"><span>9:41</span><div class="dots"><i></i><i></i><i></i></div></div>'
            '<div class="body"><div class="hd"><div class="t">%s</div>'
            '<div class="chip">%s</div></div>%s</div>%s'
            ) % (header_title, ic(I_FLAME, "@@f600@@", 2, vb="0 0 24 24"), body, navbar(active))

def page(slug, bg, fg, h1, p, active, header, body):
    css = sub(BASE.replace("__INTER__", INTER).replace("__FRAUNCES__", FRAUNCES))
    html = ('<!doctype html><html><head><meta charset="utf-8"><style>%s\n'
            'body{background:%s;} .cap h1{color:%s;} .cap p{color:%s;}</style></head><body>'
            '<div class="cap"><h1>%s</h1><p>%s</p></div>'
            '<div class="stage"><div class="phone"><div class="scr">%s</div></div></div>'
            '</body></html>') % (css, bg, fg, fg, h1, p, sub(screen(active, header, body)))
    open(os.path.join(WORK, slug + ".html"), "w", encoding="utf-8").write(sub(html))

# ── 1. HOME ────────────────────────────────────────────────────────────────
plant = ('<svg viewBox="0 0 120 120" width="190" height="190" fill="none">'
  '<ellipse cx="60" cy="104" rx="34" ry="8" fill="@@f100@@"/>'
  '<path d="M44 70h32l-4 30a4 4 0 01-4 4H52a4 4 0 01-4-4z" fill="@@honeySoft@@" stroke="@@honey@@" stroke-width="2"/>'
  '<path d="M60 72V40" stroke="@@f600@@" stroke-width="4" stroke-linecap="round"/>'
  '<path d="M60 52c-12-2-20-12-20-22 12 0 20 8 20 22z" fill="@@f500@@"/>'
  '<path d="M60 44c10-2 18-10 18-20-10 0-18 8-18 20z" fill="@@f600@@"/>'
  '<path d="M60 38c-7-2-12-9-12-16 8 0 12 6 12 16z" fill="@@leaf@@"/></svg>')
home_body = (
  '<div style="text-align:center;margin-top:6px;">' + plant +
  '<div class="eyebrow" style="margin-top:10px;">47 days alcohol-free</div>'
  '<div style="font-family:\'Fraunces\',serif;font-size:150px;font-weight:600;color:@@f700@@;line-height:1;margin-top:6px;">47</div>'
  '<div style="font-size:26px;color:@@s600@@;margin-top:2px;">days of courage · keep growing</div></div>'
  '<div class="card" style="margin-top:26px;display:flex;align-items:center;gap:20px;">'
  '<div style="width:64px;height:64px;border-radius:18px;background:@@honeySoft@@;display:flex;align-items:center;justify-content:center;color:@@honey@@;">'
  + ic(I_FLAME, "@@honey@@", 2) + '</div>'
  '<div><div style="font-size:22px;color:@@s500@@;">Money reclaimed</div>'
  '<div style="font-family:\'Fraunces\',serif;font-size:40px;color:@@fdark@@;font-weight:600;">R 2,350</div></div></div>')
page("01_home", "linear-gradient(160deg,#EAF3EA 0%,#F5F2EE 60%)", "#1F4D38",
     "Grow through\nwhat you go through", "A calm, private companion for every sober day.",
     "home", "Home", home_body)

# ── 2. PROGRESS ─────────────────────────────────────────────────────────────
ring = ('<svg viewBox="0 0 200 200" width="300" height="300">'
  '<circle cx="100" cy="100" r="86" fill="none" stroke="@@s100@@" stroke-width="16"/>'
  '<circle cx="100" cy="100" r="86" fill="none" stroke="@@f600@@" stroke-width="16" stroke-linecap="round"'
  ' stroke-dasharray="540" stroke-dashoffset="120" transform="rotate(-90 100 100)"/>'
  '<text x="100" y="92" text-anchor="middle" font-family="Fraunces" font-size="62" font-weight="600" fill="@@f700@@">47</text>'
  '<text x="100" y="126" text-anchor="middle" font-family="Inter" font-size="20" fill="@@s500@@">day streak</text></svg>')
def stat(v, l):
    return ('<div class="card" style="flex:1;margin:0;text-align:center;padding:22px 8px;">'
      '<div style="font-family:\'Fraunces\',serif;font-size:38px;color:@@fdark@@;font-weight:600;">%s</div>'
      '<div style="font-size:19px;color:@@s500@@;margin-top:4px;">%s</div></div>') % (v, l)
heat = '<div style="display:grid;grid-template-columns:repeat(13,1fr);gap:7px;">'
import math
for i in range(13*4):
    lvl = (i*7 % 5)
    cols = ["@@s100@@", "@@f100@@", "@@f300@@", "@@f500@@", "@@f600@@"]
    heat += '<div style="aspect-ratio:1;border-radius:6px;background:%s;"></div>' % cols[lvl]
heat += '</div>'
prog_body = (
  '<div style="text-align:center;margin-top:4px;">' + ring + '</div>'
  '<div style="display:flex;gap:16px;margin:6px 0 22px;">' + stat("63", "best streak") + stat("R 2.3k", "saved") + stat("1,128", "hrs back") + '</div>'
  '<div class="card"><div class="eyebrow" style="margin-bottom:16px;">This month</div>' + heat + '</div>')
page("02_progress", "linear-gradient(160deg,#DDEBDD 0%,#F5F2EE 65%)", "#1F4D38",
     "Watch your\nprogress bloom", "Streaks, savings and milestones — all yours.",
     "progress", "Progress", prog_body)

# ── 3. TOOLKIT ──────────────────────────────────────────────────────────────
def tool(title, desc, icon, tint, col):
    return ('<div class="card" style="margin:0;padding:24px;">'
      '<div style="width:62px;height:62px;border-radius:18px;background:%s;display:flex;align-items:center;justify-content:center;color:%s;margin-bottom:16px;">%s</div>'
      '<div style="font-family:\'Fraunces\',serif;font-size:30px;color:@@fdark@@;font-weight:600;">%s</div>'
      '<div style="font-size:20px;color:@@s500@@;margin-top:6px;line-height:1.35;">%s</div></div>') % (tint, col, ic(icon, col, 2), title, desc)
sos = ('<div class="card" style="background:@@f700@@;border:none;margin:0 0 20px;display:flex;align-items:center;gap:22px;">'
  '<div style="width:70px;height:70px;border-radius:20px;background:rgba(255,255,255,.16);display:flex;align-items:center;justify-content:center;color:#fff;">'
  + ic(I_FLAME, "#fff", 2) + '</div>'
  '<div><div style="font-family:\'Fraunces\',serif;font-size:32px;color:#fff;font-weight:600;">Urge timer</div>'
  '<div style="font-size:21px;color:#D9E7DD;margin-top:4px;">Ride the wave — it passes in minutes.</div></div></div>')
tk_body = (sos +
  '<div style="display:grid;grid-template-columns:1fr 1fr;gap:18px;">'
  + tool("Breathe", "Box-breathing to steady you.", I_TOOL, "@@mint@@", "@@f600@@")
  + tool("Gratitude", "Three good things, daily.", I_FLAME, "@@honeySoft@@", "@@honey@@")
  + tool("Meetings", "Find support near you.", I_PROF, "@@f50@@", "@@leaf@@")
  + tool("Vision", "Picture the life you want.", I_SHIELD, "@@mint@@", "@@f600@@")
  + '</div>')
page("03_toolkit", "linear-gradient(160deg,#F6ECD6 0%,#F5F2EE 60%)", "#5A4A1F",
     "Calm tools for\nthe hard moments", "Reach for help the second a craving hits.",
     "toolkit", "Toolkit", tk_body)

# ── 4. JOURNAL ──────────────────────────────────────────────────────────────
def jentry(mood, mcol, mtint, date, txt):
    return ('<div class="card" style="margin:0 0 18px;">'
      '<div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:12px;">'
      '<span style="background:%s;color:%s;font-size:19px;font-weight:600;padding:7px 16px;border-radius:20px;">%s</span>'
      '<span style="font-size:19px;color:@@s400@@;">%s</span></div>'
      '<div style="font-size:22px;color:@@s600@@;line-height:1.45;">%s</div></div>') % (mtint, mcol, mood, date, txt)
lockbadge = ('<div class="card" style="margin:0 0 20px;background:@@f50@@;border-color:@@f100@@;display:flex;align-items:center;gap:18px;">'
  '<div style="color:@@f600@@;width:40px;height:40px;">' + ic(I_LOCK, "@@f600@@", 2) + '</div>'
  '<div style="font-size:22px;color:@@f700@@;font-weight:600;">Locked &amp; encrypted on your device</div></div>')
j_body = (lockbadge
  + jentry("Proud", "@@f700@@", "@@mint@@", "Today", "Said no at dinner and meant it. Felt lighter walking home.")
  + jentry("Steady", "@@honey@@", "@@honeySoft@@", "Yesterday", "A hard afternoon — used the urge timer twice. It worked.")
  + jentry("Hopeful", "@@leaf@@", "@@f50@@", "Tue", "Three weeks. Sleeping better than I have in years."))
page("04_journal", "linear-gradient(160deg,#E3EBE6 0%,#F5F2EE 65%)", "#1F4D38",
     "A private space,\nlocked to you", "Your words never leave your phone. Ever.",
     "journal", "Journal", j_body)

# ── 5. PLANNER ──────────────────────────────────────────────────────────────
goalcard = ('<div class="card" style="margin:0 0 22px;">'
  '<div style="display:flex;align-items:center;justify-content:space-between;">'
  '<div style="font-family:\'Fraunces\',serif;font-size:34px;color:@@fdark@@;font-weight:600;">Run 10K</div>'
  '<span style="background:@@f50@@;color:@@f600@@;font-size:18px;font-weight:600;padding:6px 14px;border-radius:16px;">Exercise</span></div>'
  '<div style="font-size:21px;color:@@s600@@;margin:16px 0 12px;">\U0001F6A9 Training Apr 1 → Goal Oct 12</div>'
  '<div style="height:16px;border-radius:10px;background:@@s100@@;overflow:hidden;"><div style="width:46%;height:100%;background:@@f600@@;"></div></div>'
  '<div style="display:flex;align-items:center;gap:8px;margin-top:12px;color:@@f600@@;font-weight:700;font-size:22px;">'
  + '<span style="width:22px;height:22px;display:inline-block;">' + ic(I_PLAN, "@@f600@@", 2) + '</span>183 days left</div></div>')
# mini calendar
days = ""
import calendar
for d in range(1, 31):
    state = ""
    if d in (2, 4, 6, 9, 11, 13):  # done
        state = "background:@@f50@@;color:@@f600@@;font-weight:700;"
        mark = ic(I_CHECK, "@@f600@@", 3)
    elif d in (16, 18, 20, 23):  # planned
        state = "background:@@mint@@;color:@@f700@@;font-weight:700;"
        mark = str(d)
    else:
        state = "color:@@s400@@;"
        mark = str(d)
    today = "box-shadow:0 0 0 2px @@f500@@;" if d == 13 else ""
    days += '<div style="aspect-ratio:1;border-radius:11px;display:flex;align-items:center;justify-content:center;font-size:20px;%s%s">%s</div>' % (state, today, mark)
cal = ('<div class="card" style="margin:0;"><div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:14px;">'
  '<span style="color:@@s300@@;font-size:28px;">‹</span>'
  '<span style="font-family:\'Fraunces\',serif;font-size:28px;color:@@fdark@@;font-weight:600;">October 2026</span>'
  '<span style="color:@@s300@@;font-size:28px;">›</span></div>'
  '<div style="display:grid;grid-template-columns:repeat(7,1fr);gap:9px;">' + days + '</div></div>')
pl_body = goalcard + cal
page("05_planner", "linear-gradient(160deg,#E0EDE3 0%,#F5F2EE 62%)", "#1F4D38",
     "Train for\nwhat's next", "Set a goal, plan the weeks, watch the countdown.",
     "planner", "Planner", pl_body)

# ── 6. PRIVACY USP ──────────────────────────────────────────────────────────
def bullet(txt, icon):
    return ('<div style="display:flex;align-items:center;gap:20px;margin-bottom:22px;">'
      '<div style="width:56px;height:56px;border-radius:16px;background:@@f50@@;color:@@f600@@;display:flex;align-items:center;justify-content:center;flex:0 0 auto;">%s</div>'
      '<div style="font-size:27px;color:@@s800@@;font-weight:600;">%s</div></div>') % (ic(icon, "@@f600@@", 2.2), txt)
priv_body = (
  '<div style="text-align:center;margin:18px 0 8px;">'
  '<div style="width:170px;height:170px;border-radius:46px;background:@@mint@@;display:inline-flex;align-items:center;justify-content:center;color:@@f600@@;">'
  '<div style="width:96px;height:96px;">' + ic(I_WIFI_OFF, "@@f600@@", 2) + '</div></div>'
  '<div style="font-family:\'Fraunces\',serif;font-size:40px;color:@@fdark@@;font-weight:600;margin-top:22px;">Zero data leaves your phone</div></div>'
  '<div class="card" style="margin-top:26px;">'
  + bullet("No account, no sign-up", I_PROF)
  + bullet("No internet permission at all", I_WIFI_OFF)
  + bullet("No ads, no tracking, ever", I_SHIELD)
  + bullet("Encrypted on your device", I_LOCK)
  + '</div>')
page("06_privacy", "linear-gradient(165deg,#23493A 0%,#1B3A2D 100%)", "#F2F8F2",
     "100% offline.\nTotally private.", "Built so your recovery stays only yours.",
     "you", "Private by design", priv_body)

print("Wrote 6 HTML files to", WORK)
