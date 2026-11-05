# Captura la ventana de Netanbook que está en marcha y la guarda en
# docs/sesion-4/capturas/<Nombre>.png. Solo captura la ventana de la app.
#
#   powershell -ExecutionPolicy Bypass -File scripts/capturar-ventana.ps1 -Nombre netanbook-base
param(
    [Parameter(Mandatory = $true)][string]$Nombre,
    [int]$Ancho = 900,
    [int]$Alto = 720
)
$ErrorActionPreference = "Stop"
Add-Type -AssemblyName System.Drawing
Add-Type @"
using System;
using System.Collections.Generic;
using System.Runtime.InteropServices;
using System.Text;
public struct RECT { public int Left, Top, Right, Bottom; }
public static class VentanaNetanbook {
    public delegate bool EnumProc(IntPtr h, IntPtr p);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc f, IntPtr p);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr h, int attr, out RECT r, int size);
    public static List<IntPtr> Ventanas(uint pid) {
        var lista = new List<IntPtr>();
        EnumWindows((h, p) => {
            uint dueno; GetWindowThreadProcessId(h, out dueno);
            if (dueno == pid && IsWindowVisible(h)) lista.Add(h);
            return true;
        }, IntPtr.Zero);
        return lista;
    }
    public static string Clase(IntPtr h) { var s = new StringBuilder(256); GetClassName(h, s, 256); return s.ToString(); }
    // Marco visible de la ventana, sin el borde invisible que añade Windows.
    public static RECT Marco(IntPtr h) {
        RECT r;
        if (DwmGetWindowAttribute(h, 9, out r, Marshal.SizeOf(typeof(RECT))) != 0) GetWindowRect(h, out r);
        return r;
    }
}
"@
[VentanaNetanbook]::SetProcessDPIAware() | Out-Null

$proceso = Get-Process -Name Netanbook -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $proceso) { throw "Netanbook no está en marcha. Ejecútalo antes de capturar." }
$ventanas = [VentanaNetanbook]::Ventanas([uint32]$proceso.Id)
$h = $ventanas | Where-Object { [VentanaNetanbook]::Clase($_) -eq "SwiftOpenUIMainWindow" } | Select-Object -First 1
if (-not $h) { $h = $ventanas | Select-Object -First 1 }
if (-not $h) { throw "No se encuentra la ventana de Netanbook." }

# Delante de todo, con un tamaño fijo para que las capturas sean comparables.
[VentanaNetanbook]::ShowWindow($h, 9) | Out-Null                                            # SW_RESTORE
[VentanaNetanbook]::SetWindowPos($h, [IntPtr](-1), 80, 60, $Ancho, $Alto, 0x0040) | Out-Null # HWND_TOPMOST
[VentanaNetanbook]::SetForegroundWindow($h) | Out-Null
Start-Sleep -Milliseconds 1500

$r = [VentanaNetanbook]::Marco($h)
$imagen = New-Object System.Drawing.Bitmap ($r.Right - $r.Left), ($r.Bottom - $r.Top)
$grafico = [System.Drawing.Graphics]::FromImage($imagen)
$grafico.CopyFromScreen($r.Left, $r.Top, 0, 0, $imagen.Size)

$carpeta = Join-Path $PSScriptRoot "..\docs\sesion-4\capturas"
New-Item -ItemType Directory -Force -Path $carpeta | Out-Null
$ruta = Join-Path (Resolve-Path $carpeta) "$Nombre.png"
$imagen.Save($ruta, [System.Drawing.Imaging.ImageFormat]::Png)
$grafico.Dispose(); $imagen.Dispose()

[VentanaNetanbook]::SetWindowPos($h, [IntPtr](-2), 0, 0, 0, 0, 0x0003) | Out-Null           # HWND_NOTOPMOST
Write-Host "Captura guardada en $ruta"
