# powershell-automation-toolkit

Reusable PowerShell scripts for Windows automation.

## Scripts
- `Install-Silent.ps1`: runs an .exe or .msi installer silently, checks for admin rights, validates the installer path, logs every step to a timestamped file and exits with a clear error code on failure.
- `Check-DiskSpace.ps1`: checks free space on all local drives, logs each drive's result, warns when a drive falls below a set percentage (default 20%) and exits with an error code so automation tools can detect it.
- `Remove-OldLogs.ps1`: deletes `.log` files older than a set number of days (default 30) from a folder, with a `-DryRun` switch to preview what would be deleted, and logs every file it removes.
## Usage
    .\Install-Silent.ps1 -InstallerPath "C:\temp\setup.exe" -Arguments "/S"

## Requirements
Windows, PowerShell 5.1 or later, run as Administrator.
