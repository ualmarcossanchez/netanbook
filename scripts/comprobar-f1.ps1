# Comprueba que el código de F1 · Progreso solo existe en el producto que se
# compila con la variable Progreso.
#
# Compila los dos productos con Package.swift, guarda una copia de cada
# ejecutable y cuenta en ellos las apariciones del tipo ReadingProgressViewModel
# (el ViewModel de F1). No cuenta el nombre del fichero ReadingProgressViewModel.swift:
# ese fichero se compila en los dos productos (sin la variable queda vacío) y la
# información de depuración guarda su nombre.
#
#   powershell -ExecutionPolicy Bypass -File scripts/comprobar-f1.ps1
$ErrorActionPreference = "Stop"
# Salida en UTF-8 para que las tildes se vean bien en la consola y en la CI.
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
Set-Location (Join-Path $PSScriptRoot "..")
# En la CI de GitHub, el error aparece también como anotación del workflow.
trap { Write-Host "::error title=comprobar-f1.ps1::$_"; break }

function Contar([string]$ruta) {
    $contenido = [System.Text.Encoding]::ASCII.GetString([System.IO.File]::ReadAllBytes($ruta))
    return ([regex]::Matches($contenido, 'ReadingProgressViewModel(?!\.swift)')).Count
}

function Compilar([string[]]$opciones, [string]$copia) {
    # Con "Continue", lo que swift escribe en la salida de error no detiene el script.
    $ErrorActionPreference = "Continue"
    swift build --product Netanbook @opciones 2>&1 | ForEach-Object { "$_" } | Tee-Object -Variable salida
    $codigo = $LASTEXITCODE
    $ErrorActionPreference = "Stop"
    if ($codigo -ne 0) {
        $salida | Where-Object { "$_" -match "error:" } | Select-Object -First 5 |
            ForEach-Object { Write-Host "::error title=swift build $opciones::$_" }
        throw "Error al compilar: swift build --product Netanbook $opciones"
    }
    $bin = (swift build --product Netanbook @opciones --show-bin-path | Select-Object -Last 1).Trim()
    Copy-Item (Join-Path $bin "Netanbook.exe") $copia -Force
}

Compilar @() ".build\netanbook-base.exe"
Compilar @("--traits", "Progreso") ".build\netanbook-progreso.exe"

$base = Contar ".build\netanbook-base.exe"
$progreso = Contar ".build\netanbook-progreso.exe"
Write-Host ""
Write-Host "ReadingProgressViewModel en Netanbook (base):    $base"
Write-Host "ReadingProgressViewModel en Netanbook Progreso:  $progreso"
Write-Host "::notice title=F1 en Windows::ReadingProgressViewModel aparece $base veces en Netanbook (base) y $progreso en Netanbook Progreso"
if ($base -ne 0) { throw "El producto base contiene código de F1" }
if ($progreso -eq 0) { throw "Netanbook Progreso no contiene el código de F1" }
Write-Host "OK: el código de F1 solo se compila con la variable Progreso."
