# Renders a PREVIEW of the metallic Journey Forward icon:
# brushed-silver squircle + debossed forest-green ring + debossed green leaf.
# Keeps the existing leaf geometry (vesica + slits + stem) from render_icon.ps1.
# Preview only — does NOT touch shipped assets. Run: powershell -File tool/render_icon_metal.ps1
Add-Type -AssemblyName System.Drawing

# ── Leaf geometry (shared with render_icon.ps1) ─────────────────────────────
function Get-ArcEdge {
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
    $out = @(); foreach ($p in $pts) { $out += New-Object System.Drawing.PointF([float](2.0*$cx - $p.X), $p.Y) }; return $out }
function Scale-Pts { param($pts, [double]$s, [double]$cx = 512.0, [double]$cy = 512.0)
    $out = @(); foreach ($p in $pts) { $out += New-Object System.Drawing.PointF([float]($cx + ($p.X-$cx)*$s), [float]($cy + ($p.Y-$cy)*$s)) }; return $out }

function New-LeafPath {
    param([double]$scale = 1.0, [double]$cx = 512.0, [double]$cy = 512.0)
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $p.FillMode = [System.Drawing.Drawing2D.FillMode]::Alternate
    $right = Get-ArcEdge -x0 512.0 -ym 512.0 -a 242.0 -b 140.0
    $left  = Mirror-X $right 512.0
    [array]::Reverse($left)
    $leafPts = @($right) + @($left)
    $p.AddPolygon((Scale-Pts $leafPts $scale $cx $cy))
    foreach ($side in @(1.0, -1.0)) {
        $x0 = 512.0 + $side * 24.0
        $outer = Get-ArcEdge -x0 $x0 -ym 512.0 -a 190.0 -b 48.0
        $inner = Get-ArcEdge -x0 $x0 -ym 512.0 -a 190.0 -b 32.0
        if ($side -lt 0) { $outer = Mirror-X $outer $x0; $inner = Mirror-X $inner $x0 }
        [array]::Reverse($inner)
        $p.AddPolygon((Scale-Pts (@($outer) + @($inner)) $scale $cx $cy))
    }
    return $p
}
function New-StemPath {
    param([double]$scale = 1.0, [double]$cx = 512.0, [double]$cy = 512.0)
    $sw = 16.0 * $scale
    $sTop = $cy - (292.0 * $scale)
    $sBot = $cy + (292.0 * $scale)
    $stem = New-Object System.Drawing.Drawing2D.GraphicsPath
    $stem.AddArc([float]($cx - $sw/2), [float]$sTop, [float]$sw, [float]$sw, 180, 180)
    $stem.AddArc([float]($cx - $sw/2), [float]($sBot - $sw), [float]$sw, [float]$sw, 0, 180)
    $stem.CloseFigure()
    return $stem
}

# ── Helpers ─────────────────────────────────────────────────────────────────
function C { param([int]$r,[int]$g,[int]$b,[int]$a=255) return [System.Drawing.Color]::FromArgb($a,$r,$g,$b) }
function PF { param([double]$x,[double]$y) return New-Object System.Drawing.PointF([float]$x,[float]$y) }

# ── Lotus mark (teardrop + cupped two-leaf bowl), stroked line-art ───────────
function New-TeardropPath {
    param([double]$cx = 512.0, [double]$cy = 512.0, [double]$k = 1.0)
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $T = PF $cx ($cy - 190*$k)                  # apex (top)
    $R = PF ($cx + 62*$k) ($cy - 100*$k)        # widest right
    $L = PF ($cx - 62*$k) ($cy - 100*$k)        # widest left
    $p.AddBezier($T, (PF ($cx + 44*$k) ($cy - 180*$k)), (PF ($cx + 62*$k) ($cy - 145*$k)), $R)
    $p.AddArc([float]($cx - 62*$k), [float]($cy - 162*$k), [float](124*$k), [float](124*$k), 0, 180)
    $p.AddBezier($L, (PF ($cx - 62*$k) ($cy - 145*$k)), (PF ($cx - 44*$k) ($cy - 180*$k)), $T)
    $p.CloseFigure()
    return $p
}
function New-BowlPath {
    param([double]$cx = 512.0, [double]$cy = 512.0, [double]$k = 1.0)
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $Nt = PF $cx ($cy + 28*$k)                  # centre notch (downward cusp)
    $Rt = PF ($cx + 172*$k) ($cy - 34*$k)       # right petal tip (up & out)
    $B  = PF $cx ($cy + 155*$k)                 # bottom of cup
    $Lt = PF ($cx - 172*$k) ($cy - 34*$k)       # left petal tip
    $p.AddBezier($Nt, (PF ($cx + 34*$k) ($cy - 28*$k)),  (PF ($cx + 142*$k) ($cy - 30*$k)), $Rt)
    $p.AddBezier($Rt, (PF ($cx + 188*$k) ($cy + 62*$k)), (PF ($cx + 92*$k) ($cy + 155*$k)), $B)
    $p.AddBezier($B,  (PF ($cx - 92*$k) ($cy + 155*$k)), (PF ($cx - 188*$k) ($cy + 62*$k)), $Lt)
    $p.AddBezier($Lt, (PF ($cx - 142*$k) ($cy - 30*$k)), (PF ($cx - 34*$k) ($cy - 28*$k)),  $Nt)
    $p.CloseFigure()
    return $p
}
function Draw-DebossedStroke {
    param($g, $path, [double]$w, $color, [double]$off = 3.0, $shadow = $null, $highlight = $null)
    if ($null -eq $shadow)    { $shadow    = (C 16 42 30 120) }
    if ($null -eq $highlight) { $highlight = (C 255 255 255 160) }
    $mkPen = {
        param($c, $wd)
        $pen = New-Object System.Drawing.Pen($c, [float]$wd)
        $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
        $pen.EndCap   = [System.Drawing.Drawing2D.LineCap]::Round
        $pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
        return $pen
    }
    $hp = $path.Clone(); $m1 = New-Object System.Drawing.Drawing2D.Matrix
    $m1.Translate([float]$off, [float]$off); $hp.Transform($m1)
    $g.DrawPath((& $mkPen $highlight $w), $hp)
    $sp = $path.Clone(); $m2 = New-Object System.Drawing.Drawing2D.Matrix
    $m2.Translate([float](-$off), [float](-$off)); $sp.Transform($m2)
    $g.DrawPath((& $mkPen $shadow $w), $sp)
    $g.DrawPath((& $mkPen $color $w), $path)
}

function RoundRectPath {
    param([double]$x,[double]$y,[double]$w,[double]$h,[double]$rad)
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $rad * 2
    $p.AddArc([float]$x, [float]$y, [float]$d, [float]$d, 180, 90)
    $p.AddArc([float]($x+$w-$d), [float]$y, [float]$d, [float]$d, 270, 90)
    $p.AddArc([float]($x+$w-$d), [float]($y+$h-$d), [float]$d, [float]$d, 0, 90)
    $p.AddArc([float]$x, [float]($y+$h-$d), [float]$d, [float]$d, 90, 90)
    $p.CloseFigure()
    return $p
}

# Draw a path with an engraved/debossed look: dark shadow up-left, light
# highlight down-right, then the body fill on top.
function Draw-Debossed {
    param($g, $bodyPath, $fillBrush, [double]$off = 4.0,
          $shadow = $null, $highlight = $null)
    if ($null -eq $shadow)    { $shadow    = (C 20 40 30 120) }
    if ($null -eq $highlight) { $highlight = (C 255 255 255 150) }
    $st = New-Object System.Drawing.Drawing2D.Matrix
    # highlight (down-right)
    $hp = $bodyPath.Clone(); $m1 = New-Object System.Drawing.Drawing2D.Matrix
    $m1.Translate([float]$off, [float]$off); $hp.Transform($m1)
    $g.FillPath((New-Object System.Drawing.SolidBrush($highlight)), $hp)
    # shadow (up-left)
    $sp = $bodyPath.Clone(); $m2 = New-Object System.Drawing.Drawing2D.Matrix
    $m2.Translate([float](-$off), [float](-$off)); $sp.Transform($m2)
    $g.FillPath((New-Object System.Drawing.SolidBrush($shadow)), $sp)
    # body
    $g.FillPath($fillBrush, $bodyPath)
}

# ── Compose master ──────────────────────────────────────────────────────────
function Render-Metal {
    param([string]$outPath, [int]$corner = 200, [bool]$fullBleed = $false)
    $S = 1024
    $bmp = New-Object System.Drawing.Bitmap($S, $S)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    # Clip to squircle (unless full-bleed for adaptive)
    if (-not $fullBleed) {
        $clip = RoundRectPath 0 0 ($S-1) ($S-1) $corner
        $g.SetClip($clip)
    }

    # 1) Vertical silver gradient base
    $rect = New-Object System.Drawing.Rectangle(0, 0, $S, $S)
    $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect, (C 238 239 241), (C 198 201 205), 90.0)
    $g.FillRectangle($grad, $rect)

    # 2) Brushed texture — fine vertical streaks, deterministic
    $seed = 1979
    for ($x = 0; $x -lt $S; $x++) {
        $seed = ($seed * 1103515245 + 12345) -band 0x7fffffff
        $d = (($seed % 23) - 11)            # -11..11
        $a = [math]::Abs($d) * 2            # 0..22 alpha
        if ($d -ge 0) { $col = (C 255 255 255 $a) } else { $col = (C 90 95 105 $a) }
        $pen = New-Object System.Drawing.Pen($col, 1.0)
        $g.DrawLine($pen, [float]$x, 0.0, [float]$x, [float]$S)
        $pen.Dispose()
    }

    # 3) Soft top sheen
    $sheen = New-Object System.Drawing.Drawing2D.GraphicsPath
    $sheen.AddEllipse(-200, -560, 1424, 900)
    $sb = New-Object System.Drawing.Drawing2D.PathGradientBrush($sheen)
    $sb.CenterColor = (C 255 255 255 70)
    $sb.SurroundColors = @((C 255 255 255 0))
    $g.FillPath($sb, $sheen)

    # 4) Inner bevel ring on the squircle edge (light top, dark bottom)
    if (-not $fullBleed) {
        $bevel = RoundRectPath 6 6 ($S-13) ($S-13) ($corner-4)
        $pTop = New-Object System.Drawing.Pen((C 255 255 255 160), 6.0)
        $g.DrawPath($pTop, $bevel)
        $bevel2 = RoundRectPath 10 12 ($S-21) ($S-22) ($corner-8)
        $pBot = New-Object System.Drawing.Pen((C 70 75 85 70), 4.0)
        $g.DrawPath($pBot, $bevel2)
    }

    # 5) Debossed forest-green ring
    $cx = 512.0; $cy = 512.0
    $ringR = 408.0; $ringW = 30.0
    $ringPath = New-Object System.Drawing.Drawing2D.GraphicsPath
    $ringPath.AddEllipse([float]($cx-$ringR), [float]($cy-$ringR), [float]($ringR*2), [float]($ringR*2))
    # highlight (down-right) + shadow (up-left) strokes, then green stroke
    $hp = $ringPath.Clone(); $m1 = New-Object System.Drawing.Drawing2D.Matrix; $m1.Translate(3.5,3.5); $hp.Transform($m1)
    $g.DrawPath((New-Object System.Drawing.Pen((C 255 255 255 150), [float]$ringW)), $hp)
    $sp = $ringPath.Clone(); $m2 = New-Object System.Drawing.Drawing2D.Matrix; $m2.Translate(-3.5,-3.5); $sp.Transform($m2)
    $g.DrawPath((New-Object System.Drawing.Pen((C 18 45 32 110), [float]$ringW)), $sp)
    $g.DrawPath((New-Object System.Drawing.Pen((C 46 88 68), [float]$ringW)), $ringPath)

    # 6) Debossed green lotus mark — teardrop + cupped two-leaf bowl, line-art
    $greenPen = (C 42 84 64)
    $k = 1.08
    Draw-DebossedStroke $g (New-TeardropPath $cx $cy $k) 26.0 $greenPen 3.0
    Draw-DebossedStroke $g (New-BowlPath $cx $cy $k) 26.0 $greenPen 3.0

    $g.Dispose()
    $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    $bmp.Dispose()
}

function Resample {
    param([string]$src, [string]$out, [int]$size)
    $img = [System.Drawing.Image]::FromFile($src)
    $bmp = New-Object System.Drawing.Bitmap($size, $size)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.DrawImage($img, 0, 0, $size, $size)
    $g.Dispose(); $img.Dispose()
    $bmp.Save($out, [System.Drawing.Imaging.ImageFormat]::Png); $bmp.Dispose()
}

$root = Split-Path -Parent $PSScriptRoot
$preview = Join-Path $root "build_icon_preview"
New-Item -ItemType Directory -Force $preview | Out-Null
Render-Metal -outPath (Join-Path $preview "metal_square.png") -corner 200 -fullBleed $false
Resample (Join-Path $preview "metal_square.png") (Join-Path $preview "metal_192.png") 192
Resample (Join-Path $preview "metal_square.png") (Join-Path $preview "metal_96.png") 96
Resample (Join-Path $preview "metal_square.png") (Join-Path $preview "metal_48.png") 48
Write-Output "Metal preview rendered to $preview"
