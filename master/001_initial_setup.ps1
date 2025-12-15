# master/001_initial_setup.ps1
Write-Host "[MASTER][001] Initial setup..."

# Create master data folder
$masterData = Join-Path $installPath "master_data"
if (-not (Test-Path $masterData)) {
    New-Item -Path $masterData -ItemType Directory -Force | Out-Null
}

# Save basic master config
$configPath = Join-Path $masterData "config.json"
$config = @{
    type = "master"
    hostname = $env:COMPUTERNAME
    store = ($env:COMPUTERNAME -replace '-POS\\d+$','')
    createdAt = (Get-Date).ToString("o")
} | ConvertTo-Json

Set-Content -Path $configPath -Value $config -Encoding UTF8

Write-Host "[MASTER][001] DONE" -ForegroundColor Green
