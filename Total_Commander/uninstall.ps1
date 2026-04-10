# Winget package ID for Total Commander
$packageId = "Ghisler.TotalCommander"

# Check if Total Commander is installed
$installed = winget list --id $packageId --exact 2>$null | Select-String $packageId

if ($installed) {
    # Package found - proceed with uninstall
    Write-Host "Uninstalling Total Commander..."
    winget uninstall --id $packageId --exact
} else {
    # Package not found - nothing to do
    Write-Host "Total Commander is not installed. Nothing to uninstall."
}
