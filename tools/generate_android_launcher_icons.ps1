$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root 'assets\branding\finanzas_app_logo.png'
$resourceRoot = Join-Path $root 'android\app\src\main\res'

if (-not (Test-Path $source)) {
    throw 'No existe el logo oficial de Finanzas App.'
}

function New-RoundedRectanglePath(
    [float]$x,
    [float]$y,
    [float]$size,
    [float]$radius
) {
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $diameter = $radius * 2
    $path.AddArc($x, $y, $diameter, $diameter, 180, 90)
    $path.AddArc($x + $size - $diameter, $y, $diameter, $diameter, 270, 90)
    $path.AddArc(
        $x + $size - $diameter,
        $y + $size - $diameter,
        $diameter,
        $diameter,
        0,
        90
    )
    $path.AddArc($x, $y + $size - $diameter, $diameter, $diameter, 90, 90)
    $path.CloseFigure()
    return $path
}

function Save-PaddedIcon(
    [string]$path,
    [int]$canvasSize,
    [double]$logoScale
) {
    $directory = Split-Path -Parent $path
    New-Item -ItemType Directory -Force -Path $directory | Out-Null

    $inputImage = [System.Drawing.Image]::FromFile($source)
    $bitmap = [System.Drawing.Bitmap]::new(
        $canvasSize,
        $canvasSize,
        [System.Drawing.Imaging.PixelFormat]::Format32bppArgb
    )
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.Clear([System.Drawing.Color]::Transparent)
    $graphics.CompositingQuality = `
        [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = `
        [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias

    $logoSize = [int][Math]::Round($canvasSize * $logoScale)
    $offset = [int][Math]::Round(($canvasSize - $logoSize) / 2)
    $radius = [Math]::Max(2, $logoSize * 0.16)
    $clip = New-RoundedRectanglePath $offset $offset $logoSize $radius
    $graphics.SetClip($clip)
    $graphics.DrawImage($inputImage, $offset, $offset, $logoSize, $logoSize)
    $graphics.ResetClip()
    $clip.Dispose()

    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose()
    $bitmap.Dispose()
    $inputImage.Dispose()
}

$sizes = @{
    'mipmap-mdpi\ic_launcher.png' = 48
    'mipmap-hdpi\ic_launcher.png' = 72
    'mipmap-xhdpi\ic_launcher.png' = 96
    'mipmap-xxhdpi\ic_launcher.png' = 144
    'mipmap-xxxhdpi\ic_launcher.png' = 192
}

foreach ($entry in $sizes.GetEnumerator()) {
    Save-PaddedIcon (Join-Path $resourceRoot $entry.Key) $entry.Value 0.78
}

$drawableDirectory = Join-Path $resourceRoot 'drawable-nodpi'
New-Item -ItemType Directory -Force -Path $drawableDirectory | Out-Null
Copy-Item -LiteralPath $source `
    -Destination (Join-Path $drawableDirectory 'finanzas_app_logo.png') -Force
Save-PaddedIcon `
    (Join-Path $drawableDirectory 'finanzas_app_logo_legacy.png') 512 0.78
Save-PaddedIcon `
    (Join-Path $drawableDirectory 'finanzas_app_logo_foreground.png') 432 0.58

Write-Output 'Iconos Android compactos generados con el logo oficial.'
