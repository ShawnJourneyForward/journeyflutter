# One-shot script: soften clinical/medical recovery copy across every ARB
# file. Idempotent: a second run is a no-op once strings have been
# replaced. After running, regenerate Dart code with:
#   flutter gen-l10n
$ErrorActionPreference = "Stop"
$arbDir = Join-Path (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)) "lib\l10n"
$files = Get-ChildItem -Path $arbDir -Filter "app_*.arb"
if (-not $files) { Write-Host "No ARB files found at $arbDir"; exit 1 }

# Em-dash and apostrophe via char codes so the script source stays ASCII-safe
# under any console code page.
$em = [char]0x2014
$ap = [char]0x0027  # straight apostrophe

# Ordered list of [old, new] pairs.
$replacements = @(
  @(
    "Your liver has begun repairing itself",
    "Your body has had a real break from the load"
  ),
  @(
    "Your liver is repairing itself",
    "Your body has had a real break from the load"
  ),
  @(
    "Your risk of disease is dropping",
    "You are building real momentum"
  ),
  @(
    "Alcohol is clearing from your bloodstream. Many people see blood pressure begin to normalise as the body starts its repair work. Tonight${ap}s sleep $em though possibly restless $em is the first night of genuine, sober healing.",
    "One full day. Alcohol typically clears from the body within this window. For many people, tonight${ap}s sleep $em though sometimes restless $em feels different from the nights that came before."
  ),
  @(
    "Alcohol is clearing from your bloodstream. Blood pressure is normalising and your liver has begun its repair work. Tonight${ap}s sleep $em though possibly restless $em is the first night of genuine, sober healing.",
    "One full day. Alcohol typically clears from the body within this window. For many people, tonight${ap}s sleep $em though sometimes restless $em feels different from the nights that came before."
  ),
  @(
    "One full week. For many people, liver enzymes start to trend lower around this stage. Some notice sharper thinking, better skin hydration, and more natural energy as the brain${ap}s dopamine system begins to recover.",
    "One full week. Many people start to notice sharper thinking, more natural energy, and better hydration around this stage. Your body has had a meaningful stretch of recovery time."
  ),
  @(
    "One full week. Liver enzymes are already measurably lower. Many people notice sharper thinking, better skin hydration, and more natural energy. Your brain${ap}s dopamine system has begun to heal.",
    "One full week. Many people start to notice sharper thinking, more natural energy, and better hydration around this stage. Your body has had a meaningful stretch of recovery time."
  ),
  @(
    "Two weeks of healing. For many people, fatty deposits in the liver start to reduce and blood pressure trends downward. Anxiety often begins to stabilise, and many sleep more deeply than they have in a long time.",
    "Two weeks. For many people, anxiety begins to stabilise and sleep deepens. The early-recovery storm often starts to soften here, though every person${ap}s timeline is different."
  ),
  @(
    "Two weeks of healing. Fatty deposits in your liver are reducing and blood pressure has dropped meaningfully. Anxiety is stabilising. Most people sleep more deeply and wake more rested than in a long time.",
    "Two weeks. For many people, anxiety begins to stabilise and sleep deepens. The early-recovery storm often starts to soften here, though every person${ap}s timeline is different."
  ),
  @(
    "One month. Many people see meaningful improvements in liver function and immune response around this stage. Mental clarity and emotional stability often feel noticeably better, and cravings can become easier to observe without acting on them.",
    "One month. Many people describe meaningful gains in clarity and emotional steadiness at this point. Cravings can become easier to observe without acting on them."
  ),
  @(
    "Three months of genuine healing. Skin is clearer, sleep is deeper, and cognitive function continues to improve. Research shows immune function is measurably stronger. You have built real momentum.",
    "Three months. Skin can look clearer, sleep can feel deeper, and concentration often continues to sharpen. You have built real momentum."
  ),
  @(
    "Six months. For many people, the liver has made substantial progress in reversing alcohol-related damage and blood pressure is meaningfully lower. Many report that at this point, sobriety has begun to feel like their identity $em not their goal.",
    "Six months. Many people report that around this point, sobriety has begun to feel like part of who they are $em not just a goal they${ap}re chasing."
  ),
  @(
    "Six months. Your liver has made substantial progress in reversing alcohol-related damage. Blood pressure is meaningfully lower. Many people report that at this point, sobriety has begun to feel like their identity $em not their goal.",
    "Six months. Many people report that around this point, sobriety has begun to feel like part of who they are $em not just a goal they${ap}re chasing."
  ),
  @(
    "One year. Research suggests the risk of coronary heart disease may drop substantially compared with continuing drinkers, and for many people the liver has largely repaired itself. This is a profound milestone $em one that can change the trajectory of your life.",
    "One year. This is a profound milestone. Many people describe genuine, lasting changes in how they feel and how they relate to themselves. The cumulative gains of a year without alcohol are real $em and they are yours."
  ),
  @(
    "One year. Research suggests the risk of coronary heart disease drops to roughly half that of a continuing drinker. Your liver has largely repaired itself. This is a profound milestone $em one that changes the statistical trajectory of your life.",
    "One year. This is a profound milestone. Many people describe genuine, lasting changes in how they feel and how they relate to themselves. The cumulative gains of a year without alcohol are real $em and they are yours."
  ),
  @(
    "For many people, heart rate, blood pressure, hydration, and sleep patterns begin to shift as the body adjusts. This can feel calming for some and uncomfortable for others.",
    "For many people, the body${ap}s basic rhythms $em heart rate, hydration, sleep $em start to shift as it adjusts. This can feel calming for some and uncomfortable for others."
  ),
  @(
    "Your liver and vital organs may be experiencing meaningful relief from the strain of alcohol. Many people notice steadier energy, clearer thinking, and improved sleep around this stage.",
    "Your body has had a meaningful stretch of relief from the strain of alcohol. Many people notice steadier energy, clearer thinking, and improved sleep around this stage."
  ),
  @(
    "For many people, the long-term strain on the heart, liver, sleep, mood, and daily energy is meaningfully reduced after a year without alcohol.",
    "For many people, the long-term load on energy, sleep, and mood is meaningfully lighter after a year without alcohol."
  )
)

foreach ($file in $files) {
  $original = Get-Content $file.FullName -Raw -Encoding utf8
  $modified = $original
  $hits = 0
  foreach ($pair in $replacements) {
    if ($modified.Contains($pair[0])) {
      $modified = $modified.Replace($pair[0], $pair[1])
      $hits++
    }
  }
  if ($modified -ne $original) {
    [System.IO.File]::WriteAllText($file.FullName, $modified, (New-Object System.Text.UTF8Encoding($false)))
    Write-Host "$($file.Name): replaced $hits strings"
  } else {
    Write-Host "$($file.Name): nothing to do (already softened)"
  }
}
