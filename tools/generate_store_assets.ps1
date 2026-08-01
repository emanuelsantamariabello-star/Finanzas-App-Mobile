$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$output = Join-Path $root 'store_assets\generated'
New-Item -ItemType Directory -Force -Path $output | Out-Null

function New-RoundedRectanglePath(
    [float]$x,
    [float]$y,
    [float]$width,
    [float]$height,
    [float]$radius
) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = $radius * 2
    $path.AddArc($x, $y, $diameter, $diameter, 180, 90)
    $path.AddArc($x + $width - $diameter, $y, $diameter, $diameter, 270, 90)
    $path.AddArc(
        $x + $width - $diameter,
        $y + $height - $diameter,
        $diameter,
        $diameter,
        0,
        90
    )
    $path.AddArc($x, $y + $height - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Draw-AppMark(
    [System.Drawing.Graphics]$graphics,
    [float]$x,
    [float]$y,
    [float]$size
) {
    $scale = $size / 100
    $wallet = New-RoundedRectanglePath `
        ($x + 18 * $scale) ($y + 23 * $scale) `
        (64 * $scale) (58 * $scale) (12 * $scale)
    $graphics.FillPath(
        [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(7, 28, 26)),
        $wallet
    )
    $wallet.Dispose()

    $pocket = New-RoundedRectanglePath `
        ($x + 58 * $scale) ($y + 40 * $scale) `
        (28 * $scale) (22 * $scale) (7 * $scale)
    $graphics.FillPath([System.Drawing.Brushes]::White, $pocket)
    $pocket.Dispose()
    $graphics.FillEllipse(
        [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(0, 200, 83)),
        ($x + 67 * $scale),
        ($y + 47 * $scale),
        (7 * $scale),
        (7 * $scale)
    )

    $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 6 * $scale)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    $graphics.DrawLines($pen, [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new($x + 28 * $scale, $y + 68 * $scale),
        [System.Drawing.PointF]::new($x + 41 * $scale, $y + 55 * $scale),
        [System.Drawing.PointF]::new($x + 50 * $scale, $y + 64 * $scale),
        [System.Drawing.PointF]::new($x + 66 * $scale, $y + 47 * $scale)
    ))
    $pen.Dispose()
}

$icon = [System.Drawing.Bitmap]::new(512, 512)
$graphics = [System.Drawing.Graphics]::FromImage($icon)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$iconRectangle = [System.Drawing.Rectangle]::new(0, 0, 512, 512)
$iconGradient = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $iconRectangle,
    [System.Drawing.Color]::FromArgb(0, 230, 118),
    [System.Drawing.Color]::FromArgb(0, 168, 74),
    45
)
$graphics.FillRectangle($iconGradient, $iconRectangle)
Draw-AppMark $graphics 56 56 400
$icon.Save(
    (Join-Path $output 'app_icon_512.png'),
    [System.Drawing.Imaging.ImageFormat]::Png
)
$iconGradient.Dispose()
$graphics.Dispose()
$icon.Dispose()

$feature = [System.Drawing.Bitmap]::new(1024, 500)
$graphics = [System.Drawing.Graphics]::FromImage($feature)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$featureRectangle = [System.Drawing.Rectangle]::new(0, 0, 1024, 500)
$featureGradient = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $featureRectangle,
    [System.Drawing.Color]::FromArgb(4, 30, 28),
    [System.Drawing.Color]::FromArgb(10, 55, 48),
    20
)
$graphics.FillRectangle($featureGradient, $featureRectangle)

$markBackground = New-RoundedRectanglePath 62 94 310 310 72
$graphics.FillPath(
    [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(0, 200, 83)),
    $markBackground
)
$markBackground.Dispose()
Draw-AppMark $graphics 87 119 260

$titleFont = [System.Drawing.Font]::new('Segoe UI', 54, [System.Drawing.FontStyle]::Bold)
$subtitleFont = [System.Drawing.Font]::new('Segoe UI', 24, [System.Drawing.FontStyle]::Regular)
$labelFont = [System.Drawing.Font]::new('Segoe UI', 18, [System.Drawing.FontStyle]::Bold)
$graphics.DrawString('Finanzas App', $titleFont, [System.Drawing.Brushes]::White, 420, 125)
$graphics.DrawString(
    'Tu dinero bajo control.',
    $subtitleFont,
    [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(205, 225, 222)),
    424,
    215
)

$chip = New-RoundedRectanglePath 424 292 188 54 27
$graphics.FillPath(
    [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(28, 92, 78)),
    $chip
)
$graphics.DrawString('Simple', $labelFont, [System.Drawing.Brushes]::White, 476, 305)
$chip.Dispose()
$chip = New-RoundedRectanglePath 632 292 226 54 27
$graphics.FillPath(
    [System.Drawing.SolidBrush]::new([System.Drawing.Color]::FromArgb(28, 92, 78)),
    $chip
)
$graphics.DrawString('Organizada', $labelFont, [System.Drawing.Brushes]::White, 675, 305)
$chip.Dispose()

$feature.Save(
    (Join-Path $output 'feature_graphic_1024x500.png'),
    [System.Drawing.Imaging.ImageFormat]::Png
)
$titleFont.Dispose()
$subtitleFont.Dispose()
$labelFont.Dispose()
$featureGradient.Dispose()
$graphics.Dispose()
$feature.Dispose()

Write-Output "Activos generados en $output"
