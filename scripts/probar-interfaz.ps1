# Prueba de interfaz en Windows (sesión 6): arranca un producto de Netanbook,
# edita un libro en el detalle, cambia los Ajustes, reinicia la app y comprueba
# que los libros y los ajustes se conservan. Guarda las capturas en
# docs/sesion-6/capturas.
#
#   powershell -ExecutionPolicy Bypass -File scripts/probar-interfaz.ps1                       producto base
#   powershell -ExecutionPolicy Bypass -File scripts/probar-interfaz.ps1 -Variante Progreso    Netanbook Progreso
#
# AVISO: empieza borrando los libros y el progreso guardados (Documentos\netanbook-*.json).
param(
    [ValidateSet("base", "Progreso")][string]$Variante = "base",
    [string]$Carpeta = "docs/sesion-6/capturas"
)
$ErrorActionPreference = "Stop"
try { [Console]::OutputEncoding = [System.Text.Encoding]::UTF8 } catch { }
Set-Location (Join-Path $PSScriptRoot "..")
# En la CI de GitHub, el error aparece también como anotación del workflow.
trap { Write-Host "::error title=probar-interfaz.ps1 ($Variante)::$_"; break }
. "$PSScriptRoot/ui.ps1"

$opciones = if ($Variante -eq "Progreso") { @("--traits", "Progreso") } else { @() }
$ErrorActionPreference = "Continue"
swift build --product Netanbook @opciones 2>&1 | ForEach-Object { "$_" } | Select-Object -Last 3
$codigo = $LASTEXITCODE
$ErrorActionPreference = "Stop"
if ($codigo -ne 0) { throw "No compila el producto $Variante" }
$bin = (swift build --product Netanbook @opciones --show-bin-path | Select-Object -Last 1).Trim()
$exe = "$bin\Netanbook.exe"
$v = $Variante.ToLower()
$libro = "Lazarillo de Tormes"
$ajuste = "Mostrar el progreso de lectura"

# Empezar con los libros de ejemplo: sin datos guardados de otra ejecución.
$documentos = [Environment]::GetFolderPath("MyDocuments")
Remove-Item (Join-Path $documentos "netanbook-libros.json"), (Join-Path $documentos "netanbook-progreso.json") -ErrorAction SilentlyContinue

function Ver-Progreso { (Count-Like $w "P?gina *") -gt 0 }
function Ir-A([string]$opcion) { if (-not (Click-Sidebar $w $opcion)) { throw "No está «$opcion» en la barra lateral" } }

# 1. Listado y edición en el detalle: el cambio se guarda en el JSON.
$app = Start-App $exe "$v-1"
$w = Get-AppWindow $app.Id
Snap $w $Carpeta "$v-1-listado"
if ((Count-Text $w $libro) -ne 1) { throw "No se ve el listado de libros" }
if (-not (Click-Text $w $libro)) { throw "No está la fila de $libro" }
if (-not (Click-Class $w "Edit")) { throw "El detalle no tiene campo de título" }
Send-Text "{END} anotado"
Snap $w $Carpeta "$v-2-detalle-editado"
if (-not (Click-Back $w)) { throw "No hay botón para volver al listado" }
if ((Count-Text $w "$libro anotado") -ne 1) { throw "El listado no muestra el título editado" }

# 2. Ajustes: la misma configuración que usa el listado.
Ir-A "Ajustes"
if ($Variante -eq "base") {
    if ((Count-Text $w $ajuste) -ne 0) { throw "El producto base muestra el ajuste de Progreso" }
    Snap $w $Carpeta "$v-3-ajustes"
} else {
    if ((Count-Text $w $ajuste) -ne 1) { throw "No está el ajuste de Progreso" }
    Ir-A "Libros"
    if (-not (Ver-Progreso)) {
        Ir-A "Ajustes"
        Click-Text $w $ajuste | Out-Null
        Ir-A "Libros"
    }
    Snap $w $Carpeta "$v-3-listado-con-progreso"
    if (-not (Ver-Progreso)) { throw "Con el ajuste activado no se ve el progreso en el listado" }
}

# 3. Al volver a abrir se conservan los libros y los ajustes.
Stop-Process -Id $app.Id -Force; Start-Sleep -Seconds 2
$app = Start-App $exe "$v-2"
$w = Get-AppWindow $app.Id
Snap $w $Carpeta "$v-4-tras-reiniciar"
if ((Count-Text $w "$libro anotado") -ne 1) { throw "No se ha conservado el título editado" }

if ($Variante -eq "Progreso") {
    if (-not (Ver-Progreso)) { throw "No se ha conservado el ajuste de Progreso activado" }
    # 4. Apagar el flag en Ajustes y comprobarlo tras reiniciar.
    Ir-A "Ajustes"
    Click-Text $w $ajuste | Out-Null
    Snap $w $Carpeta "$v-5-ajustes-flag-apagado"
    Stop-Process -Id $app.Id -Force; Start-Sleep -Seconds 2
    $app = Start-App $exe "$v-3"
    $w = Get-AppWindow $app.Id
    Snap $w $Carpeta "$v-6-listado-tras-reiniciar"
    if (Ver-Progreso) { throw "Con el ajuste apagado no debería verse el progreso tras reiniciar" }
    if ((Count-Text $w "$libro anotado") -ne 1) { throw "No se ha conservado el título editado" }
}

Stop-Process -Id $app.Id -Force
Start-Sleep -Seconds 2
Write-Host "::notice title=Interfaz ($Variante)::Los libros y los ajustes se conservan al reiniciar"
Write-Host "Prueba de interfaz superada ($Variante)"
