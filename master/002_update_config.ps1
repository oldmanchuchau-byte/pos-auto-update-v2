# master/002_update_config.ps1
Write-Host "[MASTER][002] Update config..."

$masterData = Join-Path $installPath "master_data"
$configPath = Join-Path $masterData "config.json"

if (-not (Test-Path $configPath)) {
    Write-Host "[MASTER][002] config.json not found, run 001 first." -ForegroundColor Yellow
    return
}

$configObj = Get-Content $configPath -Raw | ConvertFrom-Json

# Update fields
$configObj | Add-Member -NotePropertyName "lastUpdateAt" -NotePropertyValue (Get-Date).ToString("o") -Force
$configObj | Add-Member -NotePropertyName "updateCount" -NotePropertyValue (($configObj.updateCount ?? 0) + 1) -Force

$configObj | ConvertTo-Json | Set-Content -Path $configPath -Encoding UTF8

Write-Host "[MASTER][002] DONE" -ForegroundColor Green
