# Comprueba que el código de F1 · Progreso solo existe en el producto que se
# compila con la variable Progreso.
#
# Compila los dos productos con Package.swift, guarda una copia de cada
# ejecutable y busca en ellos el tipo ReadingProgressViewModel (el ViewModel de F1).
#
#   powershell -ExecutionPolicy Bypass -File scripts/comprobar-f1.ps1
$ErrorActionPreference = "Stop"
Set-Location (Join-Path $PSScriptRoot "..")

function Contar([string]$ruta, [string]$texto) {
    $contenido = [System.Text.Encoding]::ASCII.GetString([System.IO.File]::ReadAllBytes($ruta))
    return ([regex]::Matches($contenido, [regex]::Escape($texto))).Count
}

function Compilar([string[]]$opciones, [string]$copia) {
    swift build --product Netanbook @opciones
    if ($LASTEXITCODE -ne 0) { throw "Error al compilar: swift build --product Netanbook $opciones" }
    $bin = (swift build --product Netanbook @opciones --show-bin-path | Select-Object -Last 1).Trim()
    Copy-Item (Join-Path $bin "Netanbook.exe") $copia -Force
}

Compilar @() ".build\netanbook-base.exe"
Compilar @("--traits", "Progreso") ".build\netanbook-progreso.exe"

$base = Contar ".build\netanbook-base.exe" "ReadingProgressViewModel"
$progreso = Contar ".build\netanbook-progreso.exe" "ReadingProgressViewModel"
Write-Host ""
Write-Host "ReadingProgressViewModel en Netanbook (base):    $base"
Write-Host "ReadingProgressViewModel en Netanbook Progreso:  $progreso"
if ($base -ne 0) { throw "El producto base contiene código de F1" }
if ($progreso -eq 0) { throw "Netanbook Progreso no contiene el código de F1" }
Write-Host "OK: el código de F1 solo se compila con la variable Progreso."
