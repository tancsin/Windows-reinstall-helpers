# Winget package ID for Total Commander
$packageId = "Ghisler.TotalCommander"

# Check if Total Commander is already installed
$installed = winget list --id $packageId --exact 2>$null | Select-String $packageId

if ($installed) {
    # Package found - upgrade to the latest version
    Write-Host "Total Commander is already installed. Upgrading..."
    winget upgrade --id $packageId --exact
} else {
    # Package not found - perform a fresh install
    Write-Host "Installing Total Commander..."
    winget install --id $packageId --exact
}
