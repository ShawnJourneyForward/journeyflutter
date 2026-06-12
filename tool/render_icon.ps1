# Renders the Journey Forward launcher icon set from parametric geometry.
# Design: solid warm-white leaf (vesica silhouette, 3 lobes via thin slit
# lenses) + stem on a forest-green radial-glow background.
# Run:  powershell -File tool/render_icon.ps1
Add-Type -AssemblyName System.Drawing

# ── Geometry (1024 master canvas, centre 512,512) ───────────────────────────
# All edges are circular arcs through three points: two tips on a vertical
# chord and an apex bulging sideways — same construction as the original
# brand mark. Sampled densely; at 1024px with AA this is exact to the eye.

function Get-ArcEdge {
    # Arc through (x0, ym-a) → apex (x0+b, ym) → (x0, ym+a), b > 0.
    param([double]$x0, [double]$ym, [double]$a, [double]$b, [int]$n = 72)
    $xc = $x0 + (($b * $b - $a * $a) / (2.0 * $b))
    $R = [math]::Abs(($b * $b + $a * $a) / (2.0 * $b))
    $phi1 = [math]::Atan2(-$a, $x0 - $xc)
    $phi3 = [math]::Atan2($a, $x0 - $xc)
    $pts = @()
    for ($i = 0; $i -le $n; $i++) {
        $phi = $phi1 + ($phi3 - $phi1) * ($i / [double]$n)
        $pts += New-Object System.Drawing.PointF(
            [float]($xc + $R * [math]::Cos($phi)), [float]($ym + $R * [math]::Sin($phi)))
    }
    return $pts
}

function Mirror-X { param($pts, [double]$cx)
    $out = @(); foreach ($p in $pts) { $out += New-Object System.Drawing.PointF([float](2.0*$cx - $p.X), $p.Y) }; return $out
}
function Scale-Pts { param($pts, [double]$s, [double]$cx = 512.0, [double]$cy = 512.0)
    $out = @(); foreach ($p in $pts) { $out += New-Object System.Drawing.PointF([float]($cx + ($p.X-$cx)*$s), [float]($cy + ($p.Y-$cy)*$s)) }; return $out
}

function New-IconPath {
    param([double]$scale = 1.0)
    $cx = 512.0; $cy = 512.0
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.FillMode = [System.Drawing.Drawing2D.FillMode]::Alternate

    # Leaf body: tips (512, 270)/(512, 754), half-width 140
    $right = Get-ArcEdge -x0 512.0 -ym 512.0 -a 242.0 -b 140.0
    $left  = Mirror-X $right 512.0
    [array]::Reverse($left)
    $leafPts = @($right) + @($left)
    $p.AddPolygon((Scale-Pts $leafPts $scale))

    # Slits: thin lenses near each side, tips at (±24, 322/702),
    # outer apex |x|=72, inner apex |x|=56 (relative bows 48 / 32).
    foreach ($side in @(1.0, -1.0)) {
        $x0 = 512.0 + $side * 24.0
        $outer = Get-ArcEdge -x0 $x0 -ym 512.0 -a 190.0 -b 48.0
        $inner = Get-ArcEdge -x0 $x0 -ym 512.0 -a 190.0 -b 32.0
        if ($side -lt 0) { $outer = Mirror-X $outer $x0; $inner = Mirror-X $inner $x0 }
        [array]::Reverse($inner)
        $slitPts = @($outer) + @($inner)
        $p.AddPolygon((Scale-Pts $slitPts $scale))
    }
    return $p
}

function Render-Master {
    param([string]$outPath, [bool]$roundMask, [double]$contentScale, [int]$cornerRadius)

    $bmp = New-Object System.Drawing.Bitmap(1024, 1024)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    $clip = New-Object System.Drawing.Drawing2D.GraphicsPath
    if ($roundMask) {
        $clip.AddEllipse(0, 0, 1023, 1023)
    } elseif ($cornerRadius -gt 0) {
        $r = $cornerRadius * 2
        $clip.AddArc(0, 0, $r, $r, 180, 90)
        $clip.AddArc(1023 - $r, 0, $r, $r, 270, 90)
        $clip.AddArc(1023 - $r, 1023 - $r, $r, $r, 0, 90)
        $clip.AddArc(0, 1023 - $r, $r, $r, 90, 90)
        $clip.CloseFigure()
    } else {
        $clip.AddRectangle((New-Object System.Drawing.Rectangle(0, 0, 1024, 1024)))
    }
    $g.SetClip($clip)

    # Background: forest green + soft lighter glow behind the mark
    $g.Clear([System.Drawing.Color]::FromArgb(255, 0x3E, 0x74, 0x5A))
    $glowPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $glowPath.AddEllipse(112, 92, 800, 800)
    $glow = New-Object System.Drawing.Drawing2D.PathGradientBrush($glowPath)
    $glow.CenterColor = [System.Drawing.Color]::FromArgb(255, 0x4C, 0x86, 0x68)
    $glow.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 0x3E, 0x74, 0x5A))
    $g.FillPath($glow, $glowPath)

    $white = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 0xFF, 0xFD, 0xF8))

    # Stem: thin capsule poking past both tips (y 220..804, w 16)
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

function Resample {
    param([string]$srcPath, [string]$outPath, [int]$size)
    $src = [System.Drawing.Image]::FromFile($srcPath)
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.DrawImage($src, 0, 0, $size, $size)
    $g.Dispose()
    $src.Dispose()
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

$root = Split-Path -Parent $PSScriptRoot
$preview = Join-Path $root "build_icon_preview"
New-Item -ItemType Directory -Force $preview | Out-Null

Render-Master -outPath (Join-Path $preview "master_square.png") -roundMask $false -contentScale 1.0 -cornerRadius 174
Render-Master -outPath (Join-Path $preview "master_round.png")  -roundMask $true  -contentScale 0.92 -cornerRadius 0
Render-Master -outPath (Join-Path $preview "master_play.png")   -roundMask $false -contentScale 1.0 -cornerRadius 0

Resample (Join-Path $preview "master_square.png") (Join-Path $preview "preview_96.png") 96
Write-Output "Masters rendered to $preview"
