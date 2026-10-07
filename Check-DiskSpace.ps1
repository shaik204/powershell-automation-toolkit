<#
.SYNOPSIS
    Checks free space on all local drives and warns when it is low.
.EXAMPLE
    .\Check-DiskSpace.ps1
    .\Check-DiskSpace.ps1 -ThresholdPercent 30
#>
param(
    [int]$ThresholdPercent = 20,
    [string]$LogFolder = "C:\Logs\powershell-toolkit"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
$logFile = Join-Path $LogFolder ("diskcheck-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date))

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $line = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Add-Content -Path $logFile -Value $line
    Write-Host $line
}

try {
    Write-Log "Disk space check started (threshold: $ThresholdPercent% free)"
    $lowDisks = 0

    $drives = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType=3"
    foreach ($drive in $drives) {
        $freePercent = [math]::Round(($drive.FreeSpace / $drive.Size) * 100, 1)
        $freeGB = [math]::Round($drive.FreeSpace / 1GB, 1)
        $message = "Drive $($drive.DeviceID) has $freeGB GB free ($freePercent%)"

        if ($freePercent -lt $ThresholdPercent) {
            Write-Log "$message - LOW" "WARNING"
            $lowDisks++
        } else {
            Write-Log $message
        }
    }

    if ($lowDisks -gt 0) { throw "$lowDisks drive(s) below $ThresholdPercent% free space" }
    Write-Log "All drives are above the threshold"
}
catch {
    Write-Log $_.Exception.Message "ERROR"
    exit 1
}
