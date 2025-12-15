# client/002_update_config.ps1
Write-Host "[CLIENT][002] Update config..."

$clientData = Join-Path $installPath "client_data"
$configPath = Join-Path $clientData "config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "[CLIENT][002] config.json not found, run 001 first." -ForegroundColor Yellow
    return
}

$configObj = Get-Content $configPath -Raw | ConvertFrom-Json

# Update fields
$configObj | Add-Member -NotePropertyName "lastUpdateAt" -NotePropertyValue (Get-Date).ToString("o") -Force
$configObj | Add-Member -NotePropertyName "updateCount" -NotePropertyValue (($configObj.updateCount ?? 0) + 1) -Force

$configObj | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8

Write-Host "[CLIENT][002] DONE" -ForegroundColor Green
