<#
.SYNOPSIS
    Runs a silent installer and logs the result.
.EXAMPLE
    .\Install-Silent.ps1 -InstallerPath "C:\temp\setup.exe" -Arguments "/S"
    .\Install-Silent.ps1 -InstallerPath "C:\temp\app.msi" -Arguments "/qn"
#>
param(
    [Parameter(Mandatory)][string]$InstallerPath,
    [string]$Arguments = "/S",
    [string]$LogFolder = "C:\Logs\powershell-toolkit"
)

$ErrorActionPreference = "Stop"
New-Item -ItemType Directory -Path $LogFolder -Force | Out-Null
$logFile = Join-Path $LogFolder ("install-{0:yyyyMMdd-HHmmss}.log" -f (Get-Date))

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $line = "{0} [{1}] {2}" -f (Get-Date -Format "yyyy-MM-dd HH:mm:ss"), $Level, $Message
    Add-Content -Path $logFile -Value $line
    Write-Host $line
}

try {
    Write-Log "Script started"

    $isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    if (-not $isAdmin) { throw "Run this script as Administrator" }

    if (-not (Test-Path $InstallerPath)) { throw "Installer not found: $InstallerPath" }
    Write-Log "Installer found: $InstallerPath"

    if ($InstallerPath -like "*.msi") {
        $process = Start-Process msiexec.exe -ArgumentList "/i `"$InstallerPath`" $Arguments" -Wait -PassThru
    } else {
        $process = Start-Process $InstallerPath -ArgumentList $Arguments -Wait -PassThru
    }

    if ($process.ExitCode -ne 0) { throw "Installer exited with code $($process.ExitCode)" }
    Write-Log "Install completed successfully"
}
catch {
    Write-Log $_.Exception.Message "ERROR"
    exit 1
}
