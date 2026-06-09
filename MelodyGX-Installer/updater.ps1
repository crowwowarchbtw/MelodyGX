# MelodyGX Seamless Smart Updater & Sanitation Engine
$ErrorActionPreference = "Stop"
$TargetDir = "C:\MelodyGX"
$SetupFile = "$env:TEMP\OperaGXSetup.exe"
$CustomBinaryName = "melodygx.exe"

Write-Host "===================================================="
Write-Host "          MELODY GX AUTOMATED UPDATE SYSTEM         "
Write-Host "===================================================="

# 1. Жестко тушим процессы, чтобы файлы не залочились при обновлении
Write-Host "[*] Suspending active browser instances..."
$ActiveProcesses = @("opera", "launcher", "test", "melodygx")
foreach ($Proc in $ActiveProcesses) {
    if (Get-Process -Name $Proc -ErrorAction SilentlyContinue) {
        Stop-Process -Name $Proc -Force -ErrorAction SilentlyContinue
    }
}

# 2. Скачивание актуального веб-инсталлятора напрямую
Write-Host "[*] Fetching latest production binary setup from upstream..."
$DownloadUrl = "https://net.geo.opera.com/opera_gx/stable/windows"
Invoke-WebRequest -Uri $DownloadUrl -OutFile $SetupFile

# 3. Запуск обновления поверх старых бинарников (Профиль защищен)
Write-Host "[*] Deploying update matrix..."
$UpdateArgs = "/silent /standalone /allusers=0 /launchbrowser=0 /installfolder=""$TargetDir"""
$UpdateProcess = Start-Process -FilePath $SetupFile -ArgumentList $UpdateArgs -Wait -PassThru

if ($UpdateProcess.ExitCode -ne 0) {
    Write-Error "Update engine reported an execution error."
    exit
}

# 4. Повторное тотальное уничтожение воскресшей телеметрии
Write-Host "[*] Purging newly introduced telemetry and assistant footprints..."
$TelemetryTargets = @(
    "opera_autoupdate.exe", "opera_crashreporter.exe", "opera_autoupdate.gup",
    "server_tracking_data", "installer_prefs.json", "installation_status.json",
    "autoupdate", "opera_browser_assistant.exe", "browser_assistant.exe"
)

foreach ($Target in $TelemetryTargets) {
    Get-ChildItem -Path $TargetDir -Filter $Target -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

# Фиксируем портативность для нового движка
$EngineDir = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^\d+\." } | Select-Object -First 1
if ($EngineDir) {
    "portable=1" | Out-File -FilePath (Join-Path $EngineDir.FullName "sidekick.config") -Encoding ascii -Force
}

# 5. Восстановление кастомного исполняемого имени
Write-Host "[*] Re-mapping binary identity execution links..."
$DefaultBinaries = @("launcher.exe", "opera.exe")
foreach ($Bin in $DefaultBinaries) {
    $BinPath = Join-Path $TargetDir $Bin
    if (Test-Path $BinPath) {
        Rename-Item -Path $BinPath -NewName $CustomBinaryName -Force -ErrorAction SilentlyContinue
    }
}

# Чистим временный инсталлятор
if (Test-Path $SetupFile) { Remove-Item -Path $SetupFile -Force }

Write-Host ""
Write-Host "===================================================="
Write-Host " SUCCESS: Update accomplished. User profile preserved."
Write-Host "===================================================="
Write-Host ""
Read-Host "You may now close this window. Press [ENTER]..."