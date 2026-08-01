param(
    [Parameter(Mandatory = $true)]
    [string]$ApiBaseUrl,
    [switch]$AllowUnsigned
)

$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$normalizedUrl = $ApiBaseUrl.Trim().TrimEnd('/')

if (-not $normalizedUrl.StartsWith('https://')) {
    throw 'La URL productiva debe utilizar HTTPS.'
}
if ($normalizedUrl.Contains('beta-api.')) {
    throw 'La compilación productiva no puede apuntar al subdominio Beta.'
}

$keyProperties = Join-Path $projectRoot 'android\key.properties'
if (-not $AllowUnsigned -and -not (Test-Path $keyProperties)) {
    throw 'Falta android\key.properties para firmar el release.'
}

$symbolDirectory = Join-Path $projectRoot 'build\symbols\android'
New-Item -ItemType Directory -Force -Path $symbolDirectory | Out-Null

$previousUnsigned = $env:ALLOW_UNSIGNED_RELEASE
try {
    if ($AllowUnsigned) {
        $env:ALLOW_UNSIGNED_RELEASE = 'true'
    } else {
        Remove-Item Env:ALLOW_UNSIGNED_RELEASE -ErrorAction SilentlyContinue
    }

    Push-Location $projectRoot
    try {
        & flutter build appbundle `
            --release `
            --dart-define=APP_ENV=production `
            --dart-define="API_BASE_URL=$normalizedUrl" `
            --obfuscate `
            --split-debug-info="$symbolDirectory"
        if ($LASTEXITCODE -ne 0) {
            throw 'Falló la generación del Android App Bundle.'
        }
    } finally {
        Pop-Location
    }
} finally {
    if ($null -eq $previousUnsigned) {
        Remove-Item Env:ALLOW_UNSIGNED_RELEASE -ErrorAction SilentlyContinue
    } else {
        $env:ALLOW_UNSIGNED_RELEASE = $previousUnsigned
    }
}

$bundle = Join-Path $projectRoot 'build\app\outputs\bundle\release\app-release.aab'
if (-not (Test-Path $bundle)) {
    throw 'No se encontró el AAB generado.'
}

$hash = (Get-FileHash -Algorithm SHA256 $bundle).Hash.ToLowerInvariant()
Write-Output "AAB: $bundle"
Write-Output "SHA-256: $hash"
Write-Output "Símbolos: $symbolDirectory"
if ($AllowUnsigned) {
    Write-Warning 'Artefacto estructural sin firma: no debe publicarse.'
}
