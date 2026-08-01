$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$brandLogo = Join-Path $root 'assets\branding\finanzas_app_logo.png'
$output = Join-Path $root 'store_assets\generated'

if (-not (Test-Path $brandLogo)) {
    throw 'No existe el logo oficial de Finanzas App.'
}

New-Item -ItemType Directory -Force -Path $output | Out-Null
Copy-Item -LiteralPath $brandLogo `
    -Destination (Join-Path $output 'app_icon_512.png') -Force

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

$feature = [System.Drawing.Bitmap]::new(1024, 500)
$graphics = [System.Drawing.Graphics]::FromImage($feature)
$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
$graphics.InterpolationMode = `
    [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
$featureRectangle = [System.Drawing.Rectangle]::new(0, 0, 1024, 500)
$featureGradient = [System.Drawing.Drawing2D.LinearGradientBrush]::new(
    $featureRectangle,
    [System.Drawing.Color]::FromArgb(4, 30, 28),
    [System.Drawing.Color]::FromArgb(10, 55, 48),
    20
)
$graphics.FillRectangle($featureGradient, $featureRectangle)

$logo = [System.Drawing.Image]::FromFile($brandLogo)
$logoClip = New-RoundedRectanglePath 62 94 310 310 72
$graphics.SetClip($logoClip)
$graphics.DrawImage($logo, 62, 94, 310, 310)
$graphics.ResetClip()
$logoClip.Dispose()
$logo.Dispose()

$titleFont = [System.Drawing.Font]::new(
    'Segoe UI',
    54,
    [System.Drawing.FontStyle]::Bold
)
$subtitleFont = [System.Drawing.Font]::new(
    'Segoe UI',
    24,
    [System.Drawing.FontStyle]::Regular
)
$labelFont = [System.Drawing.Font]::new(
    'Segoe UI',
    18,
    [System.Drawing.FontStyle]::Bold
)
$graphics.DrawString(
    'Finanzas App',
    $titleFont,
    [System.Drawing.Brushes]::White,
    420,
    125
)
$graphics.DrawString(
    'Tu dinero bajo control.',
    $subtitleFont,
    [System.Drawing.SolidBrush]::new(
        [System.Drawing.Color]::FromArgb(205, 225, 222)
    ),
    424,
    215
)

$chip = New-RoundedRectanglePath 424 292 188 54 27
$graphics.FillPath(
    [System.Drawing.SolidBrush]::new(
        [System.Drawing.Color]::FromArgb(28, 92, 78)
    ),
    $chip
)
$graphics.DrawString(
    'Simple',
    $labelFont,
    [System.Drawing.Brushes]::White,
    476,
    305
)
$chip.Dispose()
$chip = New-RoundedRectanglePath 632 292 226 54 27
$graphics.FillPath(
    [System.Drawing.SolidBrush]::new(
        [System.Drawing.Color]::FromArgb(28, 92, 78)
    ),
    $chip
)
$graphics.DrawString(
    'Organizada',
    $labelFont,
    [System.Drawing.Brushes]::White,
    675,
    305
)
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

Write-Output "Activos generados con el logo oficial en $output"
