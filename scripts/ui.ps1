# Utilidades para probar la interfaz de Netanbook en Windows: ventana de la app,
# controles, clics, teclado y capturas. Adaptadas de las del ejemplo del curso
# (uallps/TaskApp-2026, .github/scripts/ui.ps1).
#
# En SwiftOpenUI (Win32) los textos son controles con texto, así que se buscan
# por lo que dicen y no por coordenadas fijas.
Add-Type -AssemblyName System.Drawing, System.Windows.Forms
Add-Type @"
using System;
using System.Text;
using System.Collections.Generic;
using System.Runtime.InteropServices;
public struct RECT { public int Left, Top, Right, Bottom; }
public static class Win {
    public delegate bool EnumProc(IntPtr h, IntPtr p);
    [DllImport("user32.dll")] public static extern bool SetProcessDPIAware();
    [DllImport("user32.dll")] public static extern bool SetWindowPos(IntPtr h, IntPtr after, int x, int y, int cx, int cy, uint flags);
    [DllImport("user32.dll")] public static extern bool ShowWindow(IntPtr h, int cmd);
    [DllImport("user32.dll")] public static extern bool SetForegroundWindow(IntPtr h);
    [DllImport("user32.dll")] public static extern bool GetWindowRect(IntPtr h, out RECT r);
    [DllImport("user32.dll")] public static extern bool IsWindowVisible(IntPtr h);
    [DllImport("user32.dll")] public static extern bool EnumChildWindows(IntPtr h, EnumProc f, IntPtr p);
    [DllImport("user32.dll")] public static extern bool EnumWindows(EnumProc f, IntPtr p);
    [DllImport("user32.dll")] public static extern uint GetWindowThreadProcessId(IntPtr h, out uint pid);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern int GetClassName(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern int GetWindowText(IntPtr h, StringBuilder s, int n);
    [DllImport("user32.dll")] public static extern bool SetCursorPos(int x, int y);
    [DllImport("user32.dll")] public static extern void mouse_event(uint f, uint x, uint y, uint d, IntPtr e);
    [DllImport("dwmapi.dll")] public static extern int DwmGetWindowAttribute(IntPtr h, int attr, out RECT r, int size);
    public static List<IntPtr> Children(IntPtr parent) {
        var list = new List<IntPtr>();
        EnumChildWindows(parent, (h, p) => { list.Add(h); return true; }, IntPtr.Zero);
        return list;
    }
    public static List<IntPtr> TopLevel(uint pid) {
        var list = new List<IntPtr>();
        EnumWindows((h, p) => { uint owner; GetWindowThreadProcessId(h, out owner); if (owner == pid) list.Add(h); return true; }, IntPtr.Zero);
        return list;
    }
    public static string Cls(IntPtr h) { var s = new StringBuilder(256); GetClassName(h, s, 256); return s.ToString(); }
    public static string Text(IntPtr h) { var s = new StringBuilder(512); GetWindowText(h, s, 512); return s.ToString(); }
    // Marco visible de la ventana, sin el borde invisible que añade Windows.
    public static RECT Frame(IntPtr h) {
        RECT r;
        if (DwmGetWindowAttribute(h, 9, out r, Marshal.SizeOf(typeof(RECT))) != 0) GetWindowRect(h, out r);
        return r;
    }
    public static void Click(int x, int y, bool right) {
        SetCursorPos(x, y);
        mouse_event(right ? 0x0008u : 0x0002u, 0, 0, 0, IntPtr.Zero);
        mouse_event(right ? 0x0010u : 0x0004u, 0, 0, 0, IntPtr.Zero);
    }
}
"@
[Win]::SetProcessDPIAware() | Out-Null

# Ventana principal de SwiftOpenUI del proceso: restaurada, delante de todo y
# en una posición y un tamaño fijos, para que las capturas sean comparables.
function Get-AppWindow([int]$processId) {
    $h = [Win]::TopLevel([uint32]$processId) | Where-Object { [Win]::Cls($_) -eq "SwiftOpenUIMainWindow" } | Select-Object -First 1
    if (-not $h) { throw "El proceso $processId no tiene ventana SwiftOpenUIMainWindow" }
    [Win]::ShowWindow($h, 9) | Out-Null                                         # SW_RESTORE
    [Win]::SetWindowPos($h, [IntPtr](-1), 0, 0, 900, 700, 0x0040) | Out-Null    # HWND_TOPMOST, SWP_SHOWWINDOW
    [Win]::SetForegroundWindow($h) | Out-Null
    Start-Sleep -Milliseconds 1000
    return $h
}

# Controles visibles de la ventana: clase, texto y rectángulo en pantalla.
function Get-Controls([IntPtr]$h) {
    foreach ($c in [Win]::Children($h)) {
        if (-not [Win]::IsWindowVisible($c)) { continue }
        $r = New-Object RECT; [Win]::GetWindowRect($c, [ref]$r) | Out-Null
        [pscustomobject]@{ Class = [Win]::Cls($c); Text = [Win]::Text($c);
            X = $r.Left; Y = $r.Top; W = $r.Right - $r.Left; H = $r.Bottom - $r.Top }
    }
}

function Count-Text([IntPtr]$h, [string]$text) { @(Get-Controls $h | Where-Object { $_.Text -eq $text }).Count }
function Count-Like([IntPtr]$h, [string]$pattern) { @(Get-Controls $h | Where-Object { $_.Text -like $pattern }).Count }

function Click-At([int]$x, [int]$y, [switch]$Right) { [Win]::Click($x, $y, $Right.IsPresent); Start-Sleep -Milliseconds 1500 }

# Clic en el centro del primer control visible cuyo texto cumple el patrón
# (admite comodines: "Progreso:*"). Devuelve si lo ha encontrado.
function Click-Text([IntPtr]$h, [string]$pattern, [switch]$Right) {
    $c = Get-Controls $h | Where-Object { $_.Text -like $pattern } | Select-Object -First 1
    if (-not $c) { Write-Host "no hay control con texto '$pattern'"; return $false }
    Click-At ($c.X + [int]($c.W / 2)) ($c.Y + [int]($c.H / 2)) -Right:$Right
    return $true
}

# Clic en una opción de la barra lateral: el texto más a la izquierda con ese
# nombre (el título de la pantalla puede llamarse igual).
function Click-Sidebar([IntPtr]$h, [string]$text) {
    $c = Get-Controls $h | Where-Object { $_.Text -eq $text -or $_.Text -like "* $text" } | Sort-Object X | Select-Object -First 1
    if (-not $c) { Write-Host "no hay opción '$text' en la barra lateral"; return $false }
    Click-At ($c.X + [int]($c.W / 2)) ($c.Y + [int]($c.H / 2))
    return $true
}

# Clic en el centro del primer control visible de una clase (p. ej. "Edit").
function Click-Class([IntPtr]$h, [string]$class) {
    $c = Get-Controls $h | Where-Object { $_.Class -eq $class } | Select-Object -First 1
    if (-not $c) { Write-Host "no hay control de clase '$class'"; return $false }
    Click-At ($c.X + [int]($c.W / 2)) ($c.Y + [int]($c.H / 2))
    return $true
}

# Vuelve atrás en la navegación con el botón que pone SwiftOpenUI.
function Click-Back([IntPtr]$h) {
    if (Click-Text $h "*Back") { return $true }
    return (Click-Text $h "*Atrás")
}

# Escribe con el teclado en el control que tenga el foco (formato de SendKeys).
function Send-Text([string]$text) { [System.Windows.Forms.SendKeys]::SendWait($text); Start-Sleep -Milliseconds 1500 }

# Guarda la captura de la ventana en $folder\$name.png y la lista de controles
# en shots\$name.txt (para depurar la prueba).
function Snap([IntPtr]$h, [string]$folder, [string]$name) {
    New-Item -ItemType Directory -Force -Path $folder, "shots" | Out-Null
    $r = [Win]::Frame($h)
    $bitmap = New-Object System.Drawing.Bitmap ($r.Right - $r.Left), ($r.Bottom - $r.Top)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.CopyFromScreen($r.Left, $r.Top, 0, 0, $bitmap.Size)
    $path = Join-Path (Resolve-Path $folder) "$name.png"
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $graphics.Dispose(); $bitmap.Dispose()
    Get-Controls $h | Format-Table -AutoSize | Out-String -Width 300 | Out-File "shots/$name.txt"
    Write-Host "captura: $path"
}

# Arranca la app y espera a que tenga ventana. Devuelve el proceso.
function Start-App([string]$exe, [string]$label) {
    New-Item -ItemType Directory -Force -Path "shots" | Out-Null
    $p = Start-Process -FilePath $exe -WorkingDirectory (Split-Path $exe) -PassThru `
        -RedirectStandardOutput "shots/$label-out.txt" -RedirectStandardError "shots/$label-err.txt"
    Start-Sleep -Seconds 10
    if ($p.HasExited) { throw ("La app se ha cerrado al arrancar (código 0x{0:X})" -f $p.ExitCode) }
    return $p
}
