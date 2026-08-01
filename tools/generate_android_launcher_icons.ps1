$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$source = Join-Path $root 'assets\branding\finanzas_app_logo.png'
$resourceRoot = Join-Path $root 'android\app\src\main\res'

if (-not (Test-Path $source)) {
    throw 'No existe el logo oficial de Finanzas App.'
}

function Save-Icon([string]$path, [int]$size) {
    $directory = Split-Path -Parent $path
    New-Item -ItemType Directory -Force -Path $directory | Out-Null

    $inputImage = [System.Drawing.Image]::FromFile($source)
    $bitmap = [System.Drawing.Bitmap]::new($size, $size)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CompositingQuality = `
        [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.InterpolationMode = `
        [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.DrawImage($inputImage, 0, 0, $size, $size)
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
    Save-Icon (Join-Path $resourceRoot $entry.Key) $entry.Value
}

$drawableDirectory = Join-Path $resourceRoot 'drawable-nodpi'
New-Item -ItemType Directory -Force -Path $drawableDirectory | Out-Null
Copy-Item -LiteralPath $source `
    -Destination (Join-Path $drawableDirectory 'finanzas_app_logo.png') -Force

Write-Output 'Iconos Android generados con el logo oficial.'
