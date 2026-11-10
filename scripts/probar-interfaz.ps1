# Prueba de interfaz en Windows (sesión 5): arranca un producto de Netanbook,
# entra en el detalle de un libro, edita su título, vuelve al listado y comprueba
# que el cambio se ve. Guarda las capturas en docs/sesion-5/capturas.
#
#   powershell -ExecutionPolicy Bypass -File scripts/probar-interfaz.ps1                       producto base
#   powershell -ExecutionPolicy Bypass -File scripts/probar-interfaz.ps1 -Variante Progreso    Netanbook Progreso
param(
    [ValidateSet("base", "Progreso")][string]$Variante = "base",
    [string]$Carpeta = "docs/sesion-5/capturas"
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
$v = $Variante.ToLower()
$libro = "Lazarillo de Tormes"

$app = Start-App "$bin\Netanbook.exe" "$v"
$w = Get-AppWindow $app.Id
Snap $w $Carpeta "$v-1-listado"
if ((Count-Text $w $libro) -ne 1) { throw "No se ve el listado de libros" }

# F1: el botón del flag solo existe en Netanbook Progreso.
if ($Variante -eq "Progreso") {
    # Si el botón tiene texto, se busca por él. Si lo dibuja SwiftOpenUI (sin texto
    # de ventana), es uno de los botones de la barra, encima de la lista.
    if (-not (Click-Text $w "Progreso:*")) {
        $lista = Get-Controls $w | Where-Object { $_.Text -eq "Pendiente" } | Select-Object -First 1
        $botones = @(Get-Controls $w | Where-Object {
            $_.Class -in "SwiftUID2DSurface", "SwiftUICustomButton", "Button" -and $_.W -gt 60 -and $_.Text -notlike "*Back" -and $_.Y -lt $lista.Y
        } | Sort-Object X)
        Write-Host "Botones de la barra: $($botones.Count)"
        foreach ($b in $botones) {
            Click-At ($b.X + [int]($b.W / 2)) ($b.Y + [int]($b.H / 2))
            if ((Count-Like $w "P?gina *") -gt 0) { break }
        }
    }
    $paginas = Count-Like $w "P?gina *"
    Snap $w $Carpeta "$v-2-progreso-visible"
    Write-Host "::notice title=Interfaz ($Variante)::Con el flag activado se ven $paginas textos de progreso"
    if ($paginas -eq 0) { throw "Con el flag activado no se ve el progreso de ningún libro" }
}

# Detalle: se entra pulsando la fila y se edita el título.
if (-not (Click-Text $w $libro)) { throw "No está la fila de $libro" }
Snap $w $Carpeta "$v-3-detalle"
if (-not (Click-Class $w "Edit")) { throw "El detalle no tiene campo de título" }
Send-Text "{END} anotado"
Snap $w $Carpeta "$v-4-detalle-editado"
if (-not (Click-Class $w "Edit")) { throw "Al escribir se ha salido del detalle" }

# Al volver, el listado muestra el título editado.
if (-not (Click-Back $w)) { throw "No hay botón para volver al listado" }
Snap $w $Carpeta "$v-5-listado-tras-editar"
if ((Count-Text $w "$libro anotado") -ne 1) { throw "El listado no muestra el título editado" }

# Borrar con el menú contextual: clic derecho en la fila y primera opción del menú.
$otro = "Cien años de soledad"
if (Click-Text $w $otro -Right) {
    Send-Text "{DOWN}{ENTER}"
    Snap $w $Carpeta "$v-6-listado-tras-borrar"
    $quedan = Count-Text $w $otro
    Write-Host "::notice title=Interfaz ($Variante)::Tras «Eliminar libro», filas de «$otro»: $quedan"
    if ($quedan -ne 0) { Write-Host "::warning title=Interfaz ($Variante)::El menú contextual no ha borrado el libro en la prueba automática" }
}

Stop-Process -Id $app.Id -Force
Start-Sleep -Seconds 2
Write-Host "Prueba de interfaz superada ($Variante)"
