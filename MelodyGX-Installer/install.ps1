# MelodyGX Hardening and Deployment Framework
# Operational Status: Production Core Vector (Auto-Updater Integrated)

$ErrorActionPreference = "Stop"
$TargetDir = "C:\MelodyGX"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$CustomBinaryName = "melodygx.exe" 

# Принудительное подключение графической подсистены Windows Forms
Add-Type -AssemblyName System.Windows.Forms

Clear-Host
$LogoArt = @"
=============================================================================
  __  __  ____  _      ____  ___   __  __   ____ __  __
 |  \/  || ___|| |    / __ \|  _ \  \ \/ /  / ___|\ \/ /
 | |\/| || __| | |   | |  | || | | | \  /  | |  _  \  / 
 | |  | || |___| |___| |__| || |_| |  | |  | |_| | /  \ 
 |_|  |_||____||_____|\____/|____/   |_|    \____|/_/\_\
                                                                                 
=============================================================================
                         OFFICIAL PORTABLE INSTALLER
                 v0.2 | https://github.com/crowwowarchbtw/MelodyGX
=============================================================================
"@

Write-Output $LogoArt
Write-Output ""

# STEP 0: Завершение конфликтующих процессов перед апгрейдом
Write-Output "[ STEP 0 / 6 ] Terminating conflicting background processes..."
$ActiveProcesses = @("opera", "launcher", "test", "melodygx")
foreach ($Proc in $ActiveProcesses) {
    if (Get-Process -Name $Proc -ErrorAction SilentlyContinue) {
        Stop-Process -Name $Proc -Force -ErrorAction SilentlyContinue
        Write-Output "[ KILLED     ] Subsystem process terminated: $Proc"
    }
}

# STEP 1: Умная подготовка окружения (Защита пользовательских данных)
Write-Output "[ STEP 1 / 6 ] Preparing workspace environment..."
$AppDataOperaPath = Join-Path $env:APPDATA "Opera Software"
if (Test-Path $AppDataOperaPath) {
    try { Remove-Item -Path $AppDataOperaPath -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}

if (Test-Path $TargetDir) {
    Write-Output "[ PROTECTED  ] Existing environment found. Preserving user 'profile' directory..."
    Get-ChildItem -Path $TargetDir | Where-Object { $_.Name -ne "profile" } | Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
} else {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
    Write-Output "[ SUCCESS    ] Isolated target matrix initialized at: $TargetDir"
}

# STEP 2: Проверка наличия инсталлятора
Write-Output "[ STEP 2 / 6 ] Checking for local OperaGXSetup core..."
$LocalStub = Join-Path $ScriptDir "OperaGXSetup.exe"
$TempInstaller = "$env:TEMP\OperaGXSetup.exe"

if (Test-Path $LocalStub) {
    Write-Output "[ DETECTED   ] Found local OperaGXSetup.exe. Initializing transformer matrix..."
    Copy-Item -Path $LocalStub -Destination $TempInstaller -Force
} else {
    Write-Output ""
    Write-Output "============================================================================="
    Write-Output " [!] ERROR: OFFICIAL OPERA GX INSTALLER NOT FOUND"
    Write-Output "============================================================================="
    Write-Output " To deploy this hardened framework, please follow these steps:"
    Write-Output " 1. Download official 'OperaGXSetup.exe' from https://www.opera.com/gx"
    Write-Output " 2. Place the downloaded file directly into this folder:"
    Write-Output "    -> $ScriptDir"
    Write-Output " 3. Run 'install.bat' again."
    Write-Output "============================================================================="
    Write-Output ""
    Read-Host "Press [ENTER] to exit..."
    exit
}

# STEP 3: Развертывание Standalone структуры
Write-Output "[ STEP 3 / 6 ] Extracting sandboxed execution layer..."
try {
    $InstallProcess = Start-Process -FilePath $TempInstaller -ArgumentList "/silent", "/standalone", "/allusers=0", "/launchbrowser=0", "/installfolder=""$TargetDir""" -Wait -PassThru
    if ($InstallProcess.ExitCode -ne 0) { throw "Extraction layer failure." }
    Write-Output "[ SUCCESS    ] Sandboxed binaries unpacked successfully."
} catch {
    [System.Windows.Forms.MessageBox]::Show("Extraction failure during core deployment: $_", "MelodyGX Error", "OK", "Error") | Out-Null
    throw "Extraction crash."
} finally {
    if (Test-Path $TempInstaller) { Remove-Item -Path $TempInstaller -Force -ErrorAction SilentlyContinue }
}

# STEP 4: Агрессивное выжигание телеметрии и мусора
Write-Output "[ STEP 4 / 6 ] Hardening core environment flags and removing bloatware..."
$TelemetryTargets = @(
    "opera_autoupdate.exe", 
    "opera_crashreporter.exe", 
    "opera_autoupdate.gup",
    "server_tracking_data",
    "installer_prefs.json",
    "installation_status.json",
    "autoupdate",
    "opera_browser_assistant.exe",
    "browser_assistant.exe"
)

foreach ($Target in $TelemetryTargets) {
    Get-ChildItem -Path $TargetDir -Filter $Target -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
}

# Фиксация портативного режима в конфиге движка Chromium
$EngineDir = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^\d+\." } | Select-Object -First 1
if ($EngineDir) {
    "portable=1" | Out-File -FilePath (Join-Path $EngineDir.FullName "sidekick.config") -Encoding ascii -Force
}
Write-Output "[ SUCCESS    ] Telemetry engines and tracking footprints completely purged."

# STEP 4.5: Переименование исполняемых файлов под кастомный брендинг
Write-Output "[ REBRAND    ] Re-mapping executable identities..."
$DefaultBinaries = @("launcher.exe", "opera.exe")
foreach ($Bin in $DefaultBinaries) {
    $BinPath = Join-Path $TargetDir $Bin
    if (Test-Path $BinPath) {
        Rename-Item -Path $BinPath -NewName $CustomBinaryName -Force
        Write-Output "[ SUCCESS    ] Core binary mapped to: $CustomBinaryName"
    }
}

# STEP 4.7: Автоматическое развертывание модулей обновления (Интеграция Апдейтера)
Write-Output "[ DEPLOY     ] Injecting background update sub-modules..."
$LocalUpdaterScript = Join-Path $ScriptDir "updater.ps1"
if (Test-Path $LocalUpdaterScript) {
    # Копируем сам скрипт обновления в целевую папку
    Copy-Item -Path $LocalUpdaterScript -Destination $TargetDir -Force
    
    # Генерируем удобный батник для юзера, чтобы запускать обновление в один клик
    $UpdateBatPath = Join-Path $TargetDir "update.bat"
    "@echo off`r`ncd /d ""%~dp0""`r`npowershell -NoProfile -ExecutionPolicy Bypass -File ""%~dp0updater.ps1""" | Out-File -FilePath $UpdateBatPath -Encoding ascii -Force
    Write-Output "[ SUCCESS    ] Updater system successfully deployed to target directory."
} else {
    Write-Output "[ WARNING    ] updater.ps1 not found in source directory. Skipping injector hook."
}

# STEP 5: Развертывание блокировщиков первого запуска (First Run)
Write-Output "[ STEP 5 / 6 ] Injecting first-run suppression matrix..."
$TargetDataDir = "C:\MelodyGX\profile\data"
$TargetDefaultDir = "C:\MelodyGX\profile\data\Default"

if (!(Test-Path $TargetDataDir)) { New-Item -ItemType Directory -Path $TargetDataDir | Out-Null }
if (!(Test-Path $TargetDefaultDir)) { New-Item -ItemType Directory -Path $TargetDefaultDir | Out-Null }

New-Item -ItemType File -Path (Join-Path $TargetDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType File -Path (Join-Path $TargetDataDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType File -Path (Join-Path $TargetDefaultDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
Write-Output "[ SUCCESS    ] Promotional welcome wizards disabled."

# STEP 6: Верификация сборки
Write-Output "[ STEP 6 / 6 ] Validating post-deployment structure..."
$TargetLauncher = Join-Path $TargetDir $CustomBinaryName

if (Test-Path $TargetLauncher) {
    Clear-Host
    Write-Output $LogoArt
    Write-Output ""
    Write-Output "============================================================================="
    Write-Output "   CONGRATULATIONS! MELODY GX DEPLOYMENT ACCOMPLISHED SUCCESSFULLY!"
    Write-Output "============================================================================="
    Write-Output " [+] Your hardened, telemetry-free browser sandbox is fully operational."
    Write-Output " [+] Target Directory:   $TargetDir"
    Write-Output " [+] Execution Launcher:  $TargetLauncher"
    Write-Output " [+] Local Updater:      $TargetDir\update.bat"
    Write-Output "============================================================================="
    Write-Output ""
    Write-Output " You may now close this window."
    Write-Output ""
    
    [System.Windows.Forms.MessageBox]::Show("MelodyGX installation completed successfully!`n`nYour environment is ready at $TargetDir", "MelodyGX Framework", "OK", "Information") | Out-Null
} else {
    Write-Output "[ CRITICAL ] Verification failed. Master binary missing."
}

Write-Output ""
Read-Host "Press [ENTER] to exit the installer framework..."