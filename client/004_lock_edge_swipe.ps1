Write-Host "[CLIENT][004] Lock Edge Swipe (AllowEdgeSwipe=0)..."

$regPath   = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\EdgeUI"
$valueName = "AllowEdgeSwipe"
$lockValue = 0   # 0 = Disabled (locked), 1 = Enabled

if (-not (Test-Path -Path $regPath)) {
    New-Item -Path $regPath -Force | Out-Null
}

$current = (Get-ItemProperty -Path $regPath -Name $valueName -ErrorAction SilentlyContinue).$valueName

if ($current -eq $lockValue) {
    Write-Host "Edge Swipe is already LOCKED (AllowEdgeSwipe=0). Skip."
} else {
    New-ItemProperty -Path $regPath -Name $valueName -PropertyType DWord -Value $lockValue -Force | Out-Null
    Write-Host "Edge Swipe has been LOCKED (AllowEdgeSwipe=0)."
    Write-Host "Note: Restart/sign out may be required for the change to take effect."
}

Write-Host "[CLIENT][004] DONE" -ForegroundColor Green
