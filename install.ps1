# Admin Check
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell.exe "-File", ('"{0}"' -f $MyInvocation.MyCommand.Path) -Verb RunAs
    exit
}

# Azure CLI Check & Install
if (-not (Get-Command az -ErrorAction SilentlyContinue)) {
    Write-Host "Azure CLI not found. Installing..."
    winget install -e --id Microsoft.AzureCLI --accept-package-agreements --accept-source-agreements
}
else {
    Write-Host "Azure CLI is already installed."
}

# OpenTofu Check & Install
if (-not (Get-Command tofu -ErrorAction SilentlyContinue)) {
    Write-Host "OpenTofu not found. Installing..."
    winget install -e --id OpenTofu.OpenTofu --accept-package-agreements --accept-source-agreements
}
else {
    Write-Host "OpenTofu is already installed."
}

$WarpDir = "C:\Program Files\Cloudflare\Cloudflare WARP"
if (-not (Test-Path "$WarpDir\warp-cli.exe")) {
    Write-Host "Installing WARP..."
    winget install -e --id Cloudflare.Warp --accept-package-agreements --accept-source-agreements
}

# Path
$MachinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($MachinePath -notlike "*$WarpDir*") {
    Write-Host "Adding to PATH..."
    [Environment]::SetEnvironmentVariable("Path", "$MachinePath;$WarpDir", "Machine")
    $env:Path += ";$WarpDir"
}

# Connect
Write-Host "WARP Connecting..."
& "$WarpDir\warp-cli.exe" registration new *>$null
& "$WarpDir\warp-cli.exe" connect
Write-Host "WARP Enabled"