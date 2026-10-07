# powershell-automation-toolkit

Reusable PowerShell scripts for Windows automation.

## Scripts
- `Install-Silent.ps1`: runs an .exe or .msi installer silently, checks for admin rights, validates the installer path, logs every step to a timestamped file and exits with a clear error code on failure.

## Usage
    .\Install-Silent.ps1 -InstallerPath "C:\temp\setup.exe" -Arguments "/S"

## Requirements
Windows, PowerShell 5.1 or later, run as Administrator.
