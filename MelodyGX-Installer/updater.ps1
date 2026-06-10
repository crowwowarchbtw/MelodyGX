# MelodyGX Seamless Smart Updater & Sanitation Engine
# Operational Status: Hidden System Layer (Fix Code 103)

$ErrorActionPreference = "Stop"
$TargetDir = "C:\MelodyGX"
$SetupFile = "$env:TEMP\OperaGXSetup.exe"
$CustomBinaryName = "melodygx.exe"

Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "          MELODY GX AUTOMATED UPDATE SYSTEM         " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# 1. Тушим запущенную Оперу
Write-Host "[*] Suspending active browser instances..." -ForegroundColor White
$ActiveProcesses = @("opera", "launcher", "test", "melodygx")
foreach ($Proc in $ActiveProcesses) {
    if (Get-Process -Name $Proc -ErrorAction SilentlyContinue) {
        Stop-Process -Name $Proc -Force -ErrorAction SilentlyContinue
    }
}
# Даем винде 2 секунды, чтобы полностью освободить файлы от логов
Start-Sleep -Seconds 2

# 2. Качаем свежий сетап
Write-Host "[*] Fetching latest production binary setup from upstream..." -ForegroundColor White
$DownloadUrl = "https://net.geo.opera.com/opera_gx/stable/windows"
try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $SetupFile -ErrorAction Stop
    Write-Host "[+] Download complete." -ForegroundColor Green
} catch {
    Write-Host "[-] CRITICAL: Server connection dropout. Check network configuration." -ForegroundColor Red
    Read-Host "Press [ENTER] to abort..."
    exit
}

# 3. УМНАЯ ПРЕДВАРИТЕЛЬНАЯ ЗАЧИСТКА (Решение ошибки 103)
# Сносим старый движок и лаунчеры, оставляя ТУПО профиль, скрытый апдейтер и батник.
Write-Host "[*] Purging legacy binary layers to avoid setup conflicts..." -ForegroundColor White
if (Test-Path $TargetDir) {
    try {
        Get-ChildItem -Path $TargetDir | Where-Object { $_.Name -ne "profile" -and $_.Name -ne ".system" -and $_.Name -ne "update.bat" } | Remove-Item -Recurse -Force -ErrorAction Stop
        Write-Host "[+] Legacy binary layers cleared. Profile intact." -ForegroundColor Green
    } catch {
        Write-Host "[-] WARNING: Could not clear some files. Trying to proceed anyway..." -ForegroundColor Yellow
    }
}

# 4. Накатываем обновление через массив аргументов
Write-Host "[*] Deploying update matrix..." -ForegroundColor White
try {
    $UpdateArgs = @(
        "/silent",
        "/standalone",
        "/allusers=0",
        "/launchbrowser=0",
        "/installfolder=$TargetDir"
    )
    
    $UpdateProcess = Start-Process -FilePath $SetupFile -ArgumentList $UpdateArgs -Wait -PassThru -ErrorAction Stop
    
    if ($UpdateProcess.ExitCode -ne 0) { throw "Setup engine returned non-zero exit code: $($UpdateProcess.ExitCode)" }
    Write-Host "[+] Installation overwrite sequence successful." -ForegroundColor Green
} catch {
    Write-Host "[-] CRITICAL: Update installation crashed. Details: $_" -ForegroundColor Red
    if (Test-Path $SetupFile) { Remove-Item -Path $SetupFile -Force }
    Read-Host "Press [ENTER] to abort..."
    exit
}

# 5. Вычищаем шпионский шлак из новой версии
Write-Host "[*] Purging newly introduced telemetry and assistant footprints..." -ForegroundColor White
$TelemetryTargets = @(
    "opera_autoupdate.exe", "opera_crashreporter.exe", "opera_autoupdate.gup",
    "server_tracking_data", "installer_prefs.json", "installation_status.json",
    "autoupdate", "opera_browser_assistant.exe", "browser_assistant.exe"
)

foreach ($Target in $TelemetryTargets) {
    Get-ChildItem -Path $TargetDir -Filter $Target -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

# Прописываем портативность под новый номер движка
$EngineDir = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^\d+\." } | Select-Object -First 1
if ($EngineDir) {
    "portable=1" | Out-File -FilePath (Join-Path $EngineDir.FullName "sidekick.config") -Encoding ascii -Force
}

# 6. Возвращаем брендинг на место
Write-Host "[*] Re-mapping binary identity execution links..." -ForegroundColor White
$DefaultBinaries = @("launcher.exe", "opera.exe")
foreach ($Bin in $DefaultBinaries) {
    $BinPath = Join-Path $TargetDir $Bin
    if (Test-Path $BinPath) {
        Rename-Item -Path $BinPath -NewName $CustomBinaryName -Force -ErrorAction SilentlyContinue
    }
}

if (Test-Path $SetupFile) { Remove-Item -Path $SetupFile -Force }

Write-Host ""
Write-Host "====================================================" -ForegroundColor Green
Write-Host " SUCCESS: Update accomplished. User profile preserved." -ForegroundColor Green
Write-Host "====================================================" -ForegroundColor Green
Write-Host ""
Write-Host "You may now close this window." -ForegroundColor Yellow
Write-Host ""
Read-Host "Press [ENTER] to exit..."