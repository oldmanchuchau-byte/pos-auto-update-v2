# ============================================
# UPDATE-POS.PS1 - Main Orchestration Script
# Repo: oldmanchuchau-byte/pos-auto-update-v2 (public)
# Install path: D:\ChuChau\POS-Auto-Update
# ============================================

$ErrorActionPreference = "Stop"

$repoOwner  = "oldmanchuchau-byte"
$repoName   = "pos-auto-update-v2"
$repoBranch = "main"
$baseUrl    = "https://raw.githubusercontent.com/$repoOwner/$repoName/$repoBranch"

$installPath = "D:\ChuChau\POS-Auto-Update"
$manifestPath = Join-Path $installPath "manifest.json"

Write-Host "=================================="
Write-Host "POS Auto-Update - Running..."
Write-Host "Install: $installPath"
Write-Host "Repo: $repoOwner/$repoName ($repoBranch)"
Write-Host "=================================="

# Ensure folders exist
@($installPath, (Join-Path $installPath "logs"), (Join-Path $installPath "backups"), (Join-Path $installPath "utils")) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -Path $_ -ItemType Directory -Force | Out-Null }
}

# --- Detect POS type ---
$hostname = $env:COMPUTERNAME
$type = "unknown"
$store = $hostname

if ($hostname -match '^(.+)-POS(\d+)$') {
    $store = $Matches[1]
    $posNo = [int]$Matches[2]
    $type = if ($posNo -eq 1) { "master" } else { "client" }
}

Write-Host "Hostname: $hostname"
Write-Host "Store: $store"
Write-Host "Type: $type"

if ($type -eq "unknown") {
    Write-Host "ERROR: Hostname must be STORE-POSN (e.g., MXD1019-POS1)" -ForegroundColor Red
    exit 1
}

# --- Download manifest.json to local ---
$manifestUrl = "$baseUrl/manifest.json"
Write-Host "Downloading manifest: $manifestUrl"
$manifestContent = (Invoke-WebRequest -Uri $manifestUrl -UseBasicParsing -TimeoutSec 30).Content
Set-Content -Path $manifestPath -Value $manifestContent -Encoding UTF8

$manifest = Get-Content $manifestPath -Raw | ConvertFrom-Json
$scriptsToRun = $manifest.$type.scripts

if (-not $scriptsToRun -or $scriptsToRun.Count -eq 0) {
    Write-Host "ERROR: No scripts found in manifest for type: $type" -ForegroundColor Red
    exit 1
}

# --- Execute scripts from GitHub ---
foreach ($scriptName in $scriptsToRun) {
    $url = "$baseUrl/$type/$scriptName"
    Write-Host ""
    Write-Host "Running: $url"
    try {
        $content = (Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 30).Content
        Invoke-Expression $content
        Write-Host "SUCCESS: $scriptName" -ForegroundColor Green
    } catch {
        Write-Host "FAILED: $scriptName - $_" -ForegroundColor Red
        exit 1
    }
}

Write-Host ""
Write-Host "DONE. All scripts executed." -ForegroundColor Green
exit 0

