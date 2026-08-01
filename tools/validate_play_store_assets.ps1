$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent $PSScriptRoot
$listing = Join-Path $root 'store_listing\es-CO'
$assets = Join-Path $root 'store_assets\generated'

$title = (Get-Content -Raw -Encoding utf8 (Join-Path $listing 'title.txt')).Trim()
$short = (
    Get-Content -Raw -Encoding utf8 (Join-Path $listing 'short_description.txt')
).Trim()
$full = (
    Get-Content -Raw -Encoding utf8 (Join-Path $listing 'full_description.txt')
).Trim()

if ($title.Length -gt 30) { throw 'El titulo supera 30 caracteres.' }
if ($short.Length -gt 80) { throw 'La descripcion corta supera 80 caracteres.' }
if ($full.Length -gt 4000) { throw 'La descripcion completa supera 4000 caracteres.' }

$icon = [System.Drawing.Image]::FromFile((Join-Path $assets 'app_icon_512.png'))
try {
    if ($icon.Width -ne 512 -or $icon.Height -ne 512) {
        throw 'El icono de Play debe medir 512x512.'
    }
} finally {
    $icon.Dispose()
}

$feature = [System.Drawing.Image]::FromFile(
    (Join-Path $assets 'feature_graphic_1024x500.png')
)
try {
    if ($feature.Width -ne 1024 -or $feature.Height -ne 500) {
        throw 'El feature graphic debe medir 1024x500.'
    }
} finally {
    $feature.Dispose()
}

Write-Output 'Ficha y activos base de Google Play validos.'
