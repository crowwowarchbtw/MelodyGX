# MelodyGX Seamless Smart Updater & Sanitation Engine
# Operational Status: Hidden System Layer

$ErrorActionPreference = "Stop"
$TargetDir = "C:\MelodyGX"
$SetupFile = "$env:TEMP\OperaGXSetup.exe"
$CustomBinaryName = "melodygx.exe"

Clear-Host
Write-Host "====================================================" -ForegroundColor Cyan
Write-Host "          MELODY GX AUTOMATED UPDATE SYSTEM         " -ForegroundColor Cyan
Write-Host "====================================================" -ForegroundColor Cyan

# 1. Тушим запущенную Оперу, чтобы не поймать lock файлов
Write-Host "[*] Suspending active browser instances..." -ForegroundColor White
$ActiveProcesses = @("opera", "launcher", "test", "melodygx")
foreach ($Proc in $ActiveProcesses) {
    if (Get-Process -Name $Proc -ErrorAction SilentlyContinue) {
        Stop-Process -Name $Proc -Force -ErrorAction SilentlyContinue
    }
}

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

# 3. Накатываем обновление поверх (Профиль не трогается)
Write-Host "[*] Deploying update matrix..." -ForegroundColor White
try {
    $UpdateArgs = "/silent /standalone /allusers=0 /launchbrowser=0 /installfolder=""$TargetDir"""
    $UpdateProcess = Start-Process -FilePath $SetupFile -ArgumentList $UpdateArgs -Wait -PassThru -ErrorAction Stop
    if ($UpdateProcess.ExitCode -ne 0) { throw "Setup error engine logic." }
    Write-Host "[+] Installation overwrite sequence successful." -ForegroundColor Green
} catch {
    Write-Host "[-] CRITICAL: Update installation crashed." -ForegroundColor Red
    if (Test-Path $SetupFile) { Remove-Item -Path $SetupFile -Force }
    Read-Host "Press [ENTER] to abort..."
    exit
}

# 4. Вычищаем шпионский шлак, который прилетел с новой версией
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

# 5. Возвращаем брендинг на место
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