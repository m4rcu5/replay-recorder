#
# ZFM Replay recorder
#
# (c) 2018 Marcus van Dam <marcus _at_ marcusvandam.nl>
# This code is licensed under the MIT License (MIT)
#
param([switch]$list = $false)

# Variables
$fmediaDev  = 1
$fmediaExe  = 'fmedia.exe'
$recFormat  = 'mp3'
$recBitrate = 192
$recDir     = 'C:\Data\Opnames'
$database   = 'C:\Data\RecordDatabase.csv'
$programLength = 3550

# Window minimize routine
$minimizeWindow = {
    param($process)

    # Load window controls
    Add-Type -Name win -MemberDefinition '[DllImport("user32.dll")] public static extern bool ShowWindow(int handle, int state);' -Namespace native

    # Wait and minimize
    Start-Sleep -s 5
    [native.win]::ShowWindow($process.MainWindowHandle,7)
}

# Fetch all programs
$RecordHours = Import-CSV -Path $database -Delimiter ";"

# Print all programs if requested
if ($list) {
    Write-Host "The following programs are configured:"
    Write-Host ( $RecordHours | Format-Table | Out-String )

    Exit
}

# Check if we have a recording scheduled
$CurrentHour = $RecordHours | Where-Object {
    $_.DayOfWeek -eq (Get-Date).DayOfWeek.value__ -and
    $_.Hour -eq (Get-Date).Hour
}

# Act on the results
if ( $CurrentHour -ne $null ) {
    # A recording has been scheduled
    Write-Host -Foreground "Green" "Starting recording for program:"
    Write-Host ( $CurrentHour | Format-Table | Out-String )

    Write-Host "Do not close this window while recording..`n"

    # Minimize window after delay
    $null = Start-Job -ScriptBlock $minimizeWindow -ArgumentList ([System.Diagnostics.Process]::GetCurrentProcess() | Get-Process)

    # Define our temporary and final file names
    $recFile = -join($recDir,'\',$CurrentHour.Filename,'.','recording','.',$recFormat)
    $outFile = -join($recDir,'\',$CurrentHour.Filename,'.',$recFormat)

    # Arguments for fmedia
    $fmediaArgs = @(
        "--record",
        "--dev-capture=$($fmediaDev)",
        "--mpeg-quality=$($recBitrate)",
        "--overwrite",
        "--until=$($programLength)",
        "--out=$($recFile)",
        "--meta='title=$($CurrentHour.Description)'"
    )

    # Start the recording
    $p = Start-Process $fmediaExe -ArgumentList $fmediaArgs -wait -NoNewWindow -PassThru

    # Only save if the recording was successful
    if ($p.ExitCode -eq 0) {
        Write-Host -Foreground "Green" "`nRecording finished successfully!"

        Move-Item $recFile $outFile -Force
    } else {
        Write-Host -Foreground "Red" "`nRecording did not finish successfully!"

        Remove-Item $recFile -Force -ErrorAction Ignore
    }


} else {
    # No recording scheduled, but we have been triggered
    Write-Host -Foreground "Red" "Unable to find valid program entry.`nSystem is not recording!"
}

Start-Sleep -s 5
