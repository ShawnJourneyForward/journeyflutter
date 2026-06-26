# Writes the FINAL metallic-lotus launcher asset set straight into android res/.
# Three layers: legacy square/round mipmaps (metal squircle + debossed green
# lotus), an adaptive BACKGROUND (full-bleed brushed metal, no mark) and an
# adaptive FOREGROUND (debossed green ring + lotus on transparency, scaled to
# the adaptive safe zone). Also refreshes the Play 512 and the pubspec source
# foreground. Run:  powershell -File tool/finalize_icons_metal.ps1
Add-Type -AssemblyName System.Drawing

function C  { param([int]$r,[int]$g,[int]$b,[int]$a=255) return [System.Drawing.Color]::FromArgb($a,$r,$g,$b) }
function PF { param([double]$x,[double]$y) return New-Object System.Drawing.PointF([float]$x,[float]$y) }

# ── Lotus mark: teardrop bud above a cupped two-leaf bowl (line-art) ──────────
function New-TeardropPath {
    param([double]$cx = 512.0, [double]$cy = 512.0, [double]$k = 1.0)
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $T = PF $cx ($cy - 190*$k)
    $R = PF ($cx + 62*$k) ($cy - 100*$k)
    $L = PF ($cx - 62*$k) ($cy - 100*$k)
    $p.AddBezier($T, (PF ($cx + 44*$k) ($cy - 180*$k)), (PF ($cx + 62*$k) ($cy - 145*$k)), $R)
    $p.AddArc([float]($cx - 62*$k), [float]($cy - 162*$k), [float](124*$k), [float](124*$k), 0, 180)
    $p.AddBezier($L, (PF ($cx - 62*$k) ($cy - 145*$k)), (PF ($cx - 44*$k) ($cy - 180*$k)), $T)
    $p.CloseFigure()
    return $p
}
function New-BowlPath {
    param([double]$cx = 512.0, [double]$cy = 512.0, [double]$k = 1.0)
    $p = New-Object System.Drawing.Drawing2D.GraphicsPath
    $Nt = PF $cx ($cy + 28*$k)
    $Rt = PF ($cx + 172*$k) ($cy - 34*$k)
    $B  = PF $cx ($cy + 155*$k)
    $Lt = PF ($cx - 172*$k) ($cy - 34*$k)
    $p.AddBezier($Nt, (PF ($cx + 34*$k) ($cy - 28*$k)),  (PF ($cx + 142*$k) ($cy - 30*$k)), $Rt)
    $p.AddBezier($Rt, (PF ($cx + 188*$k) ($cy + 62*$k)), (PF ($cx + 92*$k) ($cy + 155*$k)), $B)
    $p.AddBezier($B,  (PF ($cx - 92*$k) ($cy + 155*$k)), (PF ($cx - 188*$k) ($cy + 62*$k)), $Lt)
    $p.AddBezier($Lt, (PF ($cx - 142*$k) ($cy - 30*$k)), (PF ($cx - 34*$k) ($cy - 28*$k)),  $Nt)
    $p.CloseFigure()
    return $p
}
function Draw-DebossedStroke {
    param($g, $path, [double]$w, $color, [double]$off = 3.0)
    $shadow    = (C 16 42 30 120)
    $highlight = (C 255 255 255 160)
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

# ── Flexible compositor ──────────────────────────────────────────────────────
#   clip   : 'square' | 'round' | 'none'
#   metal  : draw the brushed-metal substrate
#   marks  : draw the green ring + lotus
#   markScale : scale the ring+lotus about centre (for the adaptive safe zone)
function Render-Layer {
    param([string]$outPath, [string]$clip = 'square', [bool]$metal = $true,
          [bool]$marks = $true, [double]$markScale = 1.0, [int]$corner = 174)
    $S = 1024
    $bmp = New-Object System.Drawing.Bitmap($S, $S)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

    if ($clip -eq 'square') {
        $g.SetClip((RoundRectPath 0 0 ($S-1) ($S-1) $corner))
    } elseif ($clip -eq 'round') {
        $rp = New-Object System.Drawing.Drawing2D.GraphicsPath
        $rp.AddEllipse(0, 0, ($S-1), ($S-1)); $g.SetClip($rp)
    }

    if ($metal) {
        $rect = New-Object System.Drawing.Rectangle(0, 0, $S, $S)
        $grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
            $rect, (C 238 239 241), (C 198 201 205), 90.0)
        $g.FillRectangle($grad, $rect)
        # brushed vertical streaks (deterministic)
        $seed = 1979
        for ($x = 0; $x -lt $S; $x++) {
            $seed = ($seed * 1103515245 + 12345) -band 0x7fffffff
            $d = (($seed % 23) - 11)
            $a = [math]::Abs($d) * 2
            if ($d -ge 0) { $col = (C 255 255 255 $a) } else { $col = (C 90 95 105 $a) }
            $pen = New-Object System.Drawing.Pen($col, 1.0)
            $g.DrawLine($pen, [float]$x, 0.0, [float]$x, [float]$S)
            $pen.Dispose()
        }
        # top sheen
        $sheen = New-Object System.Drawing.Drawing2D.GraphicsPath
        $sheen.AddEllipse(-200, -560, 1424, 900)
        $sb = New-Object System.Drawing.Drawing2D.PathGradientBrush($sheen)
        $sb.CenterColor = (C 255 255 255 70); $sb.SurroundColors = @((C 255 255 255 0))
        $g.FillPath($sb, $sheen)
        # squircle inner bevel
        if ($clip -eq 'square') {
            $g.DrawPath((New-Object System.Drawing.Pen((C 255 255 255 160), 6.0)),
                        (RoundRectPath 6 6 ($S-13) ($S-13) ($corner-4)))
            $g.DrawPath((New-Object System.Drawing.Pen((C 70 75 85 70), 4.0)),
                        (RoundRectPath 10 12 ($S-21) ($S-22) ($corner-8)))
        }
    }

    if ($marks) {
        if ($markScale -ne 1.0) {
            $g.TranslateTransform(512, 512)
            $g.ScaleTransform([float]$markScale, [float]$markScale)
            $g.TranslateTransform(-512, -512)
        }
        $cx = 512.0; $cy = 512.0
        # debossed forest-green ring
        $ringR = 408.0; $ringW = 30.0
        $ring = New-Object System.Drawing.Drawing2D.GraphicsPath
        $ring.AddEllipse([float]($cx-$ringR), [float]($cy-$ringR), [float]($ringR*2), [float]($ringR*2))
        $hp = $ring.Clone(); $m1 = New-Object System.Drawing.Drawing2D.Matrix; $m1.Translate(3.5,3.5); $hp.Transform($m1)
        $g.DrawPath((New-Object System.Drawing.Pen((C 255 255 255 150), [float]$ringW)), $hp)
        $sp = $ring.Clone(); $m2 = New-Object System.Drawing.Drawing2D.Matrix; $m2.Translate(-3.5,-3.5); $sp.Transform($m2)
        $g.DrawPath((New-Object System.Drawing.Pen((C 18 45 32 110), [float]$ringW)), $sp)
        $g.DrawPath((New-Object System.Drawing.Pen((C 46 88 68), [float]$ringW)), $ring)
        # debossed green lotus
        $greenPen = (C 42 84 64); $k = 1.08
        Draw-DebossedStroke $g (New-TeardropPath $cx $cy $k) 26.0 $greenPen 3.0
        Draw-DebossedStroke $g (New-BowlPath $cx $cy $k) 26.0 $greenPen 3.0
        $g.ResetTransform()
    }

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
$res  = Join-Path $root "android\app\src\main\res"
$prev = Join-Path $root "build_icon_preview"
New-Item -ItemType Directory -Force $prev | Out-Null

# ── Render masters (1024) ────────────────────────────────────────────────────
$mSquare = Join-Path $prev "metal_master_square.png"
$mRound  = Join-Path $prev "metal_master_round.png"
$mBg     = Join-Path $prev "metal_master_bg.png"
$mFg     = Join-Path $prev "metal_master_fg.png"
$mPlay   = Join-Path $prev "metal_master_play.png"
Render-Layer -outPath $mSquare -clip 'square' -metal $true  -marks $true  -markScale 1.0  -corner 174
Render-Layer -outPath $mRound  -clip 'round'  -metal $true  -marks $true  -markScale 1.0
Render-Layer -outPath $mBg     -clip 'none'   -metal $true  -marks $false
Render-Layer -outPath $mFg     -clip 'none'   -metal $false -marks $true  -markScale 0.78
Render-Layer -outPath $mPlay   -clip 'none'   -metal $true  -marks $true  -markScale 1.0

# ── Legacy mipmaps (square + round) ──────────────────────────────────────────
$den = @{ 'mdpi'=48; 'hdpi'=72; 'xhdpi'=96; 'xxhdpi'=144; 'xxxhdpi'=192 }
foreach ($d in $den.Keys) {
    Resample $mSquare (Join-Path $res "mipmap-$d\ic_launcher.png")       $den[$d]
    Resample $mRound  (Join-Path $res "mipmap-$d\ic_launcher_round.png") $den[$d]
}

# ── Adaptive foreground (108dp canvas) + background (brushed metal) ───────────
$fgden = @{ 'mdpi'=108; 'hdpi'=162; 'xhdpi'=216; 'xxhdpi'=324; 'xxxhdpi'=432 }
foreach ($d in $fgden.Keys) {
    Resample $mFg (Join-Path $res "drawable-$d\ic_launcher_foreground.png") $fgden[$d]
    Resample $mBg (Join-Path $res "drawable-$d\ic_launcher_bg.png")         $fgden[$d]
}
# Retire the flat cream background shape so @drawable/ic_launcher_bg resolves to
# the brushed-metal PNGs above (a .xml + .png of the same name would collide).
$bgXml = Join-Path $res "drawable\ic_launcher_bg.xml"
if (Test-Path $bgXml) { Remove-Item -Force $bgXml }

# ── Play Store 512 + pubspec source foreground ───────────────────────────────
$playOut = Join-Path $root "play_store_assets\app_icon_512_v2.png"
if (Test-Path (Split-Path -Parent $playOut)) { Resample $mPlay $playOut 512 }
Copy-Item $mFg (Join-Path $root "assets\icons\launcher_foreground.png") -Force

Write-Output "Metallic-lotus launcher assets written to $res"
