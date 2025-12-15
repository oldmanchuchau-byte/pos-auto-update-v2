# ============================================
# SETUP-POS-CLIENT.PS1 - Initial Setup Script
# Repo: oldmanchuchau-byte/pos-auto-update-v2 (public)
# Install path: D:\ChuChau\POS-Auto-Update
# ============================================

$ErrorActionPreference = "Stop"

$repoOwner  = "oldmanchuchau-byte"
$repoName   = "pos-auto-update-v2"
$repoBranch = "main"
$baseUrl    = "https://raw.githubusercontent.com/$repoOwner/$repoName/$repoBranch"

$installPath = "D:\ChuChau\POS-Auto-Update"
$utilsPath   = Join-Path $installPath "utils"
$taskName    = "POS-Auto-Update"
$scriptPath  = Join-Path $installPath "update-pos.ps1"

Write-Host "==================================" 
Write-Host "POS Auto-Update - Setup"
Write-Host "Install: $installPath"
Write-Host "Repo: $repoOwner/$repoName ($repoBranch)"
Write-Host "=================================="
Write-Host ""

# --- Check Admin ---
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

if (-not $isAdmin) {
    Write-Host "ERROR: Please run PowerShell as Administrator." -ForegroundColor Red
    exit 1
}

# --- Create folders ---
@($installPath, $utilsPath, (Join-Path $installPath "logs"), (Join-Path $installPath "backups")) | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -Path $_ -ItemType Directory -Force | Out-Null }
}

# --- Download update-pos.ps1 ---
$updateUrl = "$baseUrl/update-pos.ps1"
Write-Host "Downloading: $updateUrl"
$updateContent = (Invoke-WebRequest -Uri $updateUrl -UseBasicParsing -TimeoutSec 30).Content
Set-Content -Path $scriptPath -Value $updateContent -Encoding UTF8

# --- Create/Replace Scheduled Task ---
try { Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null } catch {}

$action  = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`""
$trg1    = New-ScheduledTaskTrigger -AtStartup
$trg1.Delay = "PT2M"
$trg2    = New-ScheduledTaskTrigger -Daily -At "00:00"
$principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
$settings  = New-ScheduledTaskSettingsSet -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 10)

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger @($trg1,$trg2) -Principal $principal -Settings $settings `
    -Description "POS Auto Update (GitHub public) - D:\ChuChau\POS-Auto-Update" -Force | Out-Null

Write-Host ""
Write-Host "Setup done. Task created: $taskName" -ForegroundColor Green
Write-Host "Now running initial update..." -ForegroundColor Cyan

# --- Initial run ---
& $scriptPath
exit $LASTEXITCODE
