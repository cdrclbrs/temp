$Message = "PAWNED!!!`n`n Script executed.`n Protect USB ports!."
$ImageName = "security-alert"
$ImgPath = "$env:temp\alert.jpg"

# METRICS
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class PInvoke {
    [DllImport("user32.dll")] public static extern IntPtr GetDC(IntPtr hwnd);
    [DllImport("gdi32.dll")] public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);
}
"@
$hdc = [PInvoke]::GetDC([IntPtr]::Zero)
$w = [PInvoke]::GetDeviceCaps($hdc, 118)
$h = [PInvoke]::GetDeviceCaps($hdc, 117)

# DRAW
Add-Type -AssemblyName System.Drawing
$bmp = new-object System.Drawing.Bitmap $w, $h
$graphics = [System.Drawing.Graphics]::FromImage($bmp)
$graphics.Clear([System.Drawing.Color]::Red)

$font = new-object System.Drawing.Font("Arial", 36, [System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::White

$size = $graphics.MeasureString($Message, $font)
$graphics.DrawString($Message, $font, $brush, (($w - $size.Width)/2), (($h - $size.Height)/2))

$graphics.Dispose()
$bmp.Save($ImgPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmp.Dispose()

# WALLPAPER_APPLY
$code = @"
using System;
using System.Runtime.InteropServices;
public class Wallpaper {
    [DllImport("User32.dll",CharSet=CharSet.Unicode)]
    public static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
if (-not ([System.Management.Automation.PSTypeName]'Wallpaper').Type) { Add-Type -TypeDefinition $code }

Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value "0"
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value "0"
[Wallpaper]::SystemParametersInfo(0x0014, 0, $ImgPath, 0x01 -bor 0x02)

# CLEAN
Remove-Item $ImgPath -Force -ErrorAction SilentlyContinue
