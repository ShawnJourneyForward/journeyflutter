# ===========================================================================
# Generate Play Store launch assets using the app's brand palette + bundled
# fonts. Run from anywhere:
#
#   powershell -ExecutionPolicy Bypass -File `
#     "C:\Users\shawn\Documents\Personal Docs\Personal\Journey Forward Flutter\play_store_assets\generate_assets.ps1"
#
# Outputs (overwritten on every run):
#   app_icon_512.png             - Play Console "App icon" (required)
#   feature_graphic_1024x500.png - Play Console "Feature graphic" (required)
#   notification_icon_preview.png - visual reference for the white silhouette
#                                   notification icon shipped in res/drawable/
#
# Colours mirror lib/theme/app_theme.dart:
#   forest600 = #3E745A   forest700 = #2D6A4F   forest800 = #1B4332
#   stone50   = #FAF7F2   stone300  = #C8C0AF   stone700  = #4B4B47
# ===========================================================================

Add-Type -AssemblyName System.Drawing

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent $scriptDir
$fraunces = Join-Path $projectRoot "assets\fonts\Fraunces-Variable.ttf"
$inter    = Join-Path $projectRoot "assets\fonts\Inter-Variable.ttf"

if (-not (Test-Path $fraunces)) { Write-Host "ERROR: Fraunces font missing at $fraunces"; exit 1 }
if (-not (Test-Path $inter))    { Write-Host "ERROR: Inter font missing at $inter"; exit 1 }

# Load bundled fonts so the rendered text matches what the app uses.
$fontCollection = New-Object System.Drawing.Text.PrivateFontCollection
$fontCollection.AddFontFile($fraunces)
$fontCollection.AddFontFile($inter)

function Get-Font($familyName, $size, $style = [System.Drawing.FontStyle]::Regular) {
    foreach ($f in $fontCollection.Families) {
        if ($f.Name -eq $familyName) {
            return New-Object System.Drawing.Font($f, $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
        }
    }
    Write-Host "WARN: family $familyName not loaded; falling back."
    return New-Object System.Drawing.Font("Arial", $size, $style, [System.Drawing.GraphicsUnit]::Pixel)
}

# Brand palette (ARGB)
$forest600 = [System.Drawing.Color]::FromArgb(255, 0x3E, 0x74, 0x5A)
$forest700 = [System.Drawing.Color]::FromArgb(255, 0x2D, 0x6A, 0x4F)
$forest800 = [System.Drawing.Color]::FromArgb(255, 0x1B, 0x43, 0x32)
$forest300 = [System.Drawing.Color]::FromArgb(255, 0xA5, 0xC9, 0xB4)
$white     = [System.Drawing.Color]::White

# --- Helper: stylised sprout glyph (two mirrored teardrops + stem) ---------
# All numeric multiplications are pre-computed because PowerShell mis-parses
# `$r * 0.85` inside a method-call argument as an Object[] op_Multiply.
function Draw-LeafGlyph($graphics, $centerX, $centerY, $size, $color) {
    $brush = New-Object System.Drawing.SolidBrush($color)
    $r = [double]($size / 2.0)
    $tipY    = [single]($r * 0.95)
    $tipNegY = [single](-1 * $r * 0.95)
    $outerX  = [single]($r * 0.85)
    $outerNX = [single](-1 * $r * 0.85)
    $midY    = [single]($r * 0.40)
    $midNegY = [single](-1 * $r * 0.40)
    $innerX  = [single]($r * 0.30)
    $innerNX = [single](-1 * $r * 0.30)
    $stemHX  = [single]($r * 0.04)
    $stemW   = [single]($r * 0.08)
    $stemH   = [single]($r * 1.90)
    $stemX   = [single](-1 * $r * 0.04)
    $stemY   = $tipNegY

    $state = $graphics.Save()
    $graphics.TranslateTransform([single]$centerX, [single]$centerY)

    # Left teardrop
    $leftPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p1 = New-Object System.Drawing.PointF([single]0, $tipY)
    $p2 = New-Object System.Drawing.PointF($outerNX, $midY)
    $p3 = New-Object System.Drawing.PointF($outerNX, $midNegY)
    $p4 = New-Object System.Drawing.PointF([single]0, $tipNegY)
    $p5 = New-Object System.Drawing.PointF($innerNX, $midNegY)
    $p6 = New-Object System.Drawing.PointF($innerNX, $midY)
    $leftPath.AddBezier($p1, $p2, $p3, $p4)
    $leftPath.AddBezier($p4, $p5, $p6, $p1)
    $graphics.FillPath($brush, $leftPath)

    # Right teardrop (mirrored)
    $rightPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $r1 = New-Object System.Drawing.PointF([single]0, $tipY)
    $r2 = New-Object System.Drawing.PointF($outerX, $midY)
    $r3 = New-Object System.Drawing.PointF($outerX, $midNegY)
    $r4 = New-Object System.Drawing.PointF([single]0, $tipNegY)
    $r5 = New-Object System.Drawing.PointF($innerX, $midNegY)
    $r6 = New-Object System.Drawing.PointF($innerX, $midY)
    $rightPath.AddBezier($r1, $r2, $r3, $r4)
    $rightPath.AddBezier($r4, $r5, $r6, $r1)
    $graphics.FillPath($brush, $rightPath)

    # Vertical stem
    $graphics.FillRectangle($brush, $stemX, $stemY, $stemW, $stemH)

    $graphics.Restore($state)
    $brush.Dispose()
    $leftPath.Dispose(); $rightPath.Dispose()
}

# --- 1. APP ICON - 512x512 -------------------------------------------------
Write-Host "Rendering app_icon_512.png"
$icon = New-Object System.Drawing.Bitmap(512, 512)
$g = [System.Drawing.Graphics]::FromImage($icon)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit
$g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

# Solid forest600 background. Play Store accepts square; their CDN applies
# the adaptive mask, so we do NOT round corners ourselves.
$bgBrush = New-Object System.Drawing.SolidBrush($forest600)
$g.FillRectangle($bgBrush, 0, 0, 512, 512)
$bgBrush.Dispose()

# Soft inner halo so the leaf has a subtle frame
$halo = New-Object System.Drawing.Drawing2D.GraphicsPath
$halo.AddEllipse(76, 76, 360, 360)
$haloBrush = New-Object System.Drawing.Drawing2D.PathGradientBrush($halo)
$haloBrush.CenterColor = [System.Drawing.Color]::FromArgb(40, 255, 255, 255)
$haloBrush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 255, 255))
$g.FillPath($haloBrush, $halo)
$haloBrush.Dispose(); $halo.Dispose()

# Subtle outer ring (1px stroke at low opacity for depth)
$ringPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(50, 255, 255, 255), 1)
$g.DrawEllipse($ringPen, 110, 110, 292, 292)
$ringPen.Dispose()

# Leaf glyph (white)
Draw-LeafGlyph $g 256 270 220 $white

# Subtle wordmark below the leaf
$markFont = Get-Font "Fraunces 9pt" 30 ([System.Drawing.FontStyle]::Bold)
$markBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(180, 255, 255, 255))
$sf = New-Object System.Drawing.StringFormat
$sf.Alignment = [System.Drawing.StringAlignment]::Center
$g.DrawString("JOURNEY", $markFont, $markBrush, 256, 405, $sf)
$markBrush.Dispose(); $markFont.Dispose(); $sf.Dispose()

$g.Dispose()
$iconPath = Join-Path $scriptDir "app_icon_512.png"
$icon.Save($iconPath, [System.Drawing.Imaging.ImageFormat]::Png)
$icon.Dispose()
$iconKb = [math]::Round((Get-Item $iconPath).Length / 1KB, 1)
Write-Host "  OK: $iconPath ($iconKb KB)"

# --- 2. FEATURE GRAPHIC - 1024x500 -----------------------------------------
Write-Host "Rendering feature_graphic_1024x500.png"
$feat = New-Object System.Drawing.Bitmap(1024, 500)
$g = [System.Drawing.Graphics]::FromImage($feat)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::ClearTypeGridFit

# Vertical gradient: forest800 (top) -> forest600 (bottom)
$rect = New-Object System.Drawing.Rectangle(0, 0, 1024, 500)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, $forest800, $forest600, 90.0)
$g.FillRectangle($grad, $rect)
$grad.Dispose()

# Faint horizontal flourish line
$linePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60, 255, 255, 255), 1)
$g.DrawLine($linePen, 60, 400, 964, 400)
$linePen.Dispose()

# Left circle medallion containing the leaf glyph
$circleRect = New-Object System.Drawing.Rectangle(80, 130, 240, 240)
$circleBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(40, 255, 255, 255))
$g.FillEllipse($circleBrush, $circleRect)
$circleBrush.Dispose()
$circlePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(120, 255, 255, 255), 2)
$g.DrawEllipse($circlePen, $circleRect)
$circlePen.Dispose()
Draw-LeafGlyph $g 200 250 160 $white

# Headline (Fraunces serif)
$h1Font = Get-Font "Fraunces 9pt" 70 ([System.Drawing.FontStyle]::Bold)
$h1Brush = New-Object System.Drawing.SolidBrush($white)
$g.DrawString("Journey Forward", $h1Font, $h1Brush, 360, 170)
$h1Brush.Dispose(); $h1Font.Dispose()

# Subline (Inter) - shortened so it doesn't clip the right edge at 1024 wide.
$h2Font = Get-Font "Inter" 28 ([System.Drawing.FontStyle]::Regular)
$h2Brush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(220, $forest300.R, $forest300.G, $forest300.B))
$g.DrawString("Sobriety support, kept on your device.", $h2Font, $h2Brush, 362, 268)
$h2Brush.Dispose(); $h2Font.Dispose()

# Tag chip
$chipRect = New-Object System.Drawing.RectangleF(362, 320, 320, 38)
$chipPath = New-Object System.Drawing.Drawing2D.GraphicsPath
$radius = 19
$chipPath.AddArc($chipRect.X, $chipRect.Y, $radius * 2, $radius * 2, 180, 90)
$chipPath.AddArc($chipRect.Right - $radius * 2, $chipRect.Y, $radius * 2, $radius * 2, 270, 90)
$chipPath.AddArc($chipRect.Right - $radius * 2, $chipRect.Bottom - $radius * 2, $radius * 2, $radius * 2, 0, 90)
$chipPath.AddArc($chipRect.X, $chipRect.Bottom - $radius * 2, $radius * 2, $radius * 2, 90, 90)
$chipPath.CloseFigure()
$chipBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(60, 255, 255, 255))
$g.FillPath($chipBrush, $chipPath)
$chipBrush.Dispose()
$chipFont = Get-Font "Inter" 18 ([System.Drawing.FontStyle]::Bold)
$chipTextBrush = New-Object System.Drawing.SolidBrush($white)
$chipSf = New-Object System.Drawing.StringFormat
$chipSf.Alignment = [System.Drawing.StringAlignment]::Center
$chipSf.LineAlignment = [System.Drawing.StringAlignment]::Center
$g.DrawString("OFFLINE  .  PRIVATE  .  FREE", $chipFont, $chipTextBrush, $chipRect, $chipSf)
$chipFont.Dispose(); $chipTextBrush.Dispose(); $chipSf.Dispose(); $chipPath.Dispose()

# Footer
$footFont = Get-Font "Inter" 16 ([System.Drawing.FontStyle]::Regular)
$footBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(140, 255, 255, 255))
$g.DrawString("Stillwater Studios  .  v5.8", $footFont, $footBrush, 60, 425)
$footFont.Dispose(); $footBrush.Dispose()

$g.Dispose()
$featPath = Join-Path $scriptDir "feature_graphic_1024x500.png"
$feat.Save($featPath, [System.Drawing.Imaging.ImageFormat]::Png)
$feat.Dispose()
$featKb = [math]::Round((Get-Item $featPath).Length / 1KB, 1)
Write-Host "  OK: $featPath ($featKb KB)"

# --- 3. NOTIFICATION ICON PREVIEW ------------------------------------------
Write-Host "Rendering notification_icon_preview.png"
$notif = New-Object System.Drawing.Bitmap(192, 192)
$g = [System.Drawing.Graphics]::FromImage($notif)
$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$g.Clear([System.Drawing.Color]::FromArgb(0, 0, 0, 0))
$chevron = New-Object System.Drawing.Drawing2D.GraphicsPath
$chevron.AddPolygon(@(
    (New-Object System.Drawing.PointF(64,  40)),
    (New-Object System.Drawing.PointF(144, 96)),
    (New-Object System.Drawing.PointF(64,  152))
))
$g.FillPath((New-Object System.Drawing.SolidBrush($forest700)), $chevron)
$chevron.Dispose()
$g.Dispose()
$notifPath = Join-Path $scriptDir "notification_icon_preview.png"
$notif.Save($notifPath, [System.Drawing.Imaging.ImageFormat]::Png)
$notif.Dispose()
$notifKb = [math]::Round((Get-Item $notifPath).Length / 1KB, 1)
Write-Host "  OK: $notifPath ($notifKb KB)"

Write-Host ""
Write-Host "All assets generated under: $scriptDir"
