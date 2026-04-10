# Backup Total Commander configuration files into a timestamped zip archive.
# Output is saved to ./backup/ relative to the script location.

$packageId = "Ghisler.TotalCommander"
$backupDir = Join-Path $PSScriptRoot "backup"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$zipPath   = Join-Path $backupDir "tc_backup_$timestamp.zip"

# --- Verify Total Commander is installed ---
$installed = winget list --id $packageId --exact 2>$null | Select-String $packageId
if (-not $installed) {
    Write-Error "Total Commander is not installed. Nothing to back up."
    exit 1
}

# --- Resolve config directory from registry ---
$regKey = "HKCU:\Software\Ghisler\Total Commander"
if (-not (Test-Path $regKey)) {
    Write-Error "Total Commander registry key not found. Cannot locate config files."
    exit 1
}

$iniFile = (Get-ItemProperty $regKey).IniFileName
if (-not $iniFile) {
    Write-Error "IniFileName registry value is missing."
    exit 1
}

$configDir = Split-Path $iniFile -Parent
Write-Host "Config directory: $configDir"

# --- Collect config files to back up ---
# Patterns based on the official TC backup guide:
# wincmd.ini, wcx_ftp.ini, usercmd.ini, tcignore.txt,
# *.bar (button bars), *.tab (folder tabs),
# pkplugin.ini, lsplugin.ini, fsplugin.ini, contplug.ini
$patterns = @(
    "wincmd.ini",
    "wcx_ftp.ini",
    "usercmd.ini",
    "tcignore.txt",
    "*.bar",
    "*.tab",
    "pkplugin.ini",
    "lsplugin.ini",
    "fsplugin.ini",
    "contplug.ini"
)

$filesToBackup = @()
foreach ($pattern in $patterns) {
    $matches = Get-ChildItem -Path $configDir -Filter $pattern -ErrorAction SilentlyContinue
    $filesToBackup += $matches
}

# Exclude the auto-generated empty button bar
$filesToBackup = $filesToBackup | Where-Object { $_.Name -ne "No.bar" }

if ($filesToBackup.Count -eq 0) {
    Write-Error "No config files found in '$configDir'."
    exit 1
}

Write-Host "Files to back up:"
$filesToBackup | ForEach-Object { Write-Host "  $($_.FullName)" }

# --- Create backup directory if needed ---
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir | Out-Null
    Write-Host "Created backup directory: $backupDir"
}

# --- Create the zip archive ---
Compress-Archive -Path $filesToBackup.FullName -DestinationPath $zipPath -Force
Write-Host "Backup saved to: $zipPath"
