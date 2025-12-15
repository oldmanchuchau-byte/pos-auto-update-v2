# client/001_initial_setup.ps1
Write-Host "[CLIENT][001] Initial setup..."

# Create client data folder
$clientData = Join-Path $installPath "client_data"
if (-not (Test-Path $clientData)) {
    New-Item -Path $clientData -ItemType Directory -Force | Out-Null
}

# Save basic client config
$configPath = Join-Path $clientData "config.json"
$config = @{
    type = "client"
    hostname = $env:COMPUTERNAME
    store = ($env:COMPUTERNAME -replace '-POS\\d+$','')
    createdAt = (Get-Date).ToString("o")
} | ConvertTo-Json

Set-Content -Path $configPath -Value $config -Encoding UTF8

Write-Host "[CLIENT][001] DONE" -ForegroundColor Green
