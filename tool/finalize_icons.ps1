# Writes the final launcher asset set from the parametric renderer.
# Run AFTER render_icon.ps1 visual approval:
#   powershell -File tool/finalize_icons.ps1
. (Join-Path $PSScriptRoot "render_icon.ps1")

$root = Split-Path -Parent $PSScriptRoot
$res = Join-Path $root "android\app\src\main\res"
$preview = Join-Path $root "build_icon_preview"

# ── Foreground master: white mark on transparency (no bg, no glow) ──────────
function Render-Foreground {
    param([string]$outPath, [double]$contentScale)
    $bmp = New-Object System.Drawing.Bitmap(1024, 1024)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0xFF, 0xFD, 0xF8))
    $sw = 16.0 * $contentScale
    $sTop = 512.0 - (292.0 * $contentScale)
    $sBot = 512.0 + (292.0 * $contentScale)
    $stem = New-Object System.Drawing.Drawing2D.GraphicsPath
    $stem.AddArc([float](512.0 - $sw/2), [float]$sTop, [float]$sw, [float]$sw, 180, 180)
    $stem.AddArc([float](512.0 - $sw/2), [float]($sBot - $sw), [float]$sw, [float]$sw, 0, 180)
    $stem.CloseFigure()
    $g.FillPath($white, $stem)
    $g.FillPath($white, (New-IconPath -scale $contentScale))
    $g.Dispose()
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

# Re-render masters with final scales
Render-Master -outPath (Join-Path $preview "master_square.png") -roundMask $false -contentScale 1.12 -cornerRadius 174
Render-Master -outPath (Join-Path $preview "master_round.png")  -roundMask $true  -contentScale 1.0  -cornerRadius 0
Render-Master -outPath (Join-Path $preview "master_play.png")   -roundMask $false -contentScale 1.0  -cornerRadius 0
Render-Foreground -outPath (Join-Path $preview "master_fg.png") -contentScale 1.0

# ── Adaptive foreground PNGs (108dp canvas per density) ─────────────────────
$fg = Join-Path $preview "master_fg.png"
Resample $fg (Join-Path $res "drawable-mdpi\ic_launcher_foreground.png") 108
Resample $fg (Join-Path $res "drawable-hdpi\ic_launcher_foreground.png") 162
Resample $fg (Join-Path $res "drawable-xhdpi\ic_launcher_foreground.png") 216
Resample $fg (Join-Path $res "drawable-xxhdpi\ic_launcher_foreground.png") 324
Resample $fg (Join-Path $res "drawable-xxxhdpi\ic_launcher_foreground.png") 432

# ── Legacy mipmaps ───────────────────────────────────────────────────────────
$sq = Join-Path $preview "master_square.png"
$rd = Join-Path $preview "master_round.png"
Resample $sq (Join-Path $res "mipmap-mdpi\ic_launcher.png") 48
Resample $sq (Join-Path $res "mipmap-hdpi\ic_launcher.png") 72
Resample $sq (Join-Path $res "mipmap-xhdpi\ic_launcher.png") 96
Resample $sq (Join-Path $res "mipmap-xxhdpi\ic_launcher.png") 144
Resample $sq (Join-Path $res "mipmap-xxxhdpi\ic_launcher.png") 192
Resample $rd (Join-Path $res "mipmap-mdpi\ic_launcher_round.png") 48
Resample $rd (Join-Path $res "mipmap-hdpi\ic_launcher_round.png") 72
Resample $rd (Join-Path $res "mipmap-xhdpi\ic_launcher_round.png") 96
Resample $rd (Join-Path $res "mipmap-xxhdpi\ic_launcher_round.png") 144
Resample $rd (Join-Path $res "mipmap-xxxhdpi\ic_launcher_round.png") 192

# ── Play Store 512 (full-bleed, no text — Play applies its own mask) ────────
Resample (Join-Path $preview "master_play.png") (Join-Path $root "play_store_assets\app_icon_512_v2.png") 512

Write-Output "All launcher assets written."
