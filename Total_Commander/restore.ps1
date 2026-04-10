# Restore Total Commander configuration from a backup zip file.
# Usage: .\restore.ps1 -BackupZip <path-to-zip>
#
# The script overwrites the current Total Commander config with the contents
# of the provided zip, allowing easy migration between machines.

param(
    [Parameter(Mandatory = $true)]
    [string]$BackupZip
)

$packageId = "Ghisler.TotalCommander"

# --- Validate the backup zip parameter ---
if (-not (Test-Path $BackupZip)) {
    Write-Error "Backup file not found: $BackupZip"
    exit 1
}

if ([System.IO.Path]::GetExtension($BackupZip) -ne ".zip") {
    Write-Error "The provided file is not a .zip archive: $BackupZip"
    exit 1
}

# --- Verify Total Commander is installed ---
$installed = winget list --id $packageId --exact 2>$null | Select-String $packageId
if (-not $installed) {
    Write-Error "Total Commander is not installed. Please install it first using install.ps1."
    exit 1
}

# --- Resolve config directory from registry ---
$regKey = "HKCU:\Software\Ghisler\Total Commander"
if (-not (Test-Path $regKey)) {
    Write-Error "Total Commander registry key not found. Cannot locate config directory."
    exit 1
}

$iniFile = (Get-ItemProperty $regKey).IniFileName
if (-not $iniFile) {
    Write-Error "IniFileName registry value is missing."
    exit 1
}

$configDir = Split-Path $iniFile -Parent
Write-Host "Restoring config to: $configDir"

# --- Extract the zip, overwriting existing config files ---
Expand-Archive -Path $BackupZip -DestinationPath $configDir -Force
Write-Host "Restore complete. Config files extracted from: $BackupZip"
Write-Host "Restart Total Commander for the changes to take effect."
