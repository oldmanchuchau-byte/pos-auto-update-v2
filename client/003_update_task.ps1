# client/003_update_task.ps1
Write-Host "[CLIENT][003] Update Task Scheduler..."

$taskVersion = "1"   # tăng số này nếu muốn ép tất cả máy update lại task
$taskName = "POS-Auto-Update"

$clientData = Join-Path $installPath "client_data"
if (-not (Test-Path $clientData)) { New-Item -Path $clientData -ItemType Directory -Force | Out-Null }

$versionFile = Join-Path $clientData "task_version.txt"
$currentVersion = if (Test-Path $versionFile) { (Get-Content $versionFile -ErrorAction SilentlyContinue) } else { "0" }

Write-Host "[CLIENT][003] Current=$currentVersion Target=$taskVersion"

if ($currentVersion -ne $taskVersion) {
    # Remove existing task
    try { Unregister-ScheduledTask -TaskName $taskName -Confirm:$false -ErrorAction SilentlyContinue | Out-Null } catch {}

    $scriptPath = Join-Path $installPath "update-pos.ps1"

    $action = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-ExecutionPolicy Bypass -NoProfile -File `"$scriptPath`""
    $t1 = New-ScheduledTaskTrigger -AtStartup
    $t1.Delay = "PT2M"
    $t2 = New-ScheduledTaskTrigger -Daily -At "00:00"

    $principal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
    $settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RestartCount 3 -RestartInterval (New-TimeSpan -Minutes 10)

    Register-ScheduledTask -TaskName $taskName -Action $action -Trigger @($t1,$t2) -Principal $principal -Settings $settings `
        -Description "POS Auto Update Client v$taskVersion (D:\ChuChau\POS-Auto-Update)" -Force | Out-Null

    Set-Content -Path $versionFile -Value $taskVersion -Encoding UTF8
    Write-Host "[CLIENT][003] Task updated to v$taskVersion" -ForegroundColor Green
} else {
    Write-Host "[CLIENT][003] Task already up-to-date, skip." -ForegroundColor Yellow
}

Write-Host "[CLIENT][003] DONE" -ForegroundColor Green
