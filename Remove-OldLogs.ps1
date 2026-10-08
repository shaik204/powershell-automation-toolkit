<#
.SYNOPSIS
    Deletes old .log files from a folder. Use -DryRun to preview without deleting.
.EXAMPLE
    .\Remove-OldLogs.ps1 -DryRun
    .\Remove-OldLogs.ps1 -TargetFolder "C:\Logs\powershell-toolkit" -DaysToKeep 14
#>
param(
    [string]$TargetFolder = "C:\Logs\powershell-toolkit",
    [int]$DaysToKeep = 30,
    [switch]$DryRun,
    [string]$LogFolder = "C:\Logs\powershell-toolkit"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
$logFile = Join-Path $LogFolder ("cleanup-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date))

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $line = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Add-Content -Path $logFile -Value $line
    Write-Host $line
}

try {
    Write-Log "Cleanup started (folder: $TargetFolder, keep: $DaysToKeep days, dry run: $DryRun)"

    if (-not (Test-Path $TargetFolder)) { throw "Folder not found: $TargetFolder" }

    $cutoff = (Get-Date).AddDays(-$DaysToKeep)
    $oldFiles = Get-ChildItem -Path $TargetFolder -Filter *.log -File | Where-Object { $_.LastWriteTime -lt $cutoff }

    foreach ($file in $oldFiles) {
        if ($DryRun) {
            Write-Log "Would delete: $($file.Name)"
        } else {
            Remove-Item -Path $file.FullName -Force
            Write-Log "Deleted: $($file.Name)"
        }
    }

    Write-Log "Cleanup finished. Files found: $($oldFiles.Count)"
}
catch {
    Write-Log $_.Exception.Message "ERROR"
    exit 1
}
