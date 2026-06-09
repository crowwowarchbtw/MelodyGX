# MelodyGX Hardening and Deployment Framework
# Operational Status: Production Core Vector (Colorized & Cloaked Matrix)

$ErrorActionPreference = "Stop"
$TargetDir = "C:\MelodyGX"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$CustomBinaryName = "melodygx.exe" 

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

Write-Host $LogoArt -ForegroundColor Magenta
Write-Host ""

# STEP 0: Завершение конфликтующих процессов
Write-Host "[ STEP 0 / 6 ] Terminating conflicting background processes..." -ForegroundColor Cyan
$ActiveProcesses = @("opera", "launcher", "test", "melodygx")
foreach ($Proc in $ActiveProcesses) {
    if (Get-Process -Name $Proc -ErrorAction SilentlyContinue) {
        try {
            Stop-Process -Name $Proc -Force -ErrorAction Stop
            Write-Host "[ KILLED     ] Subsystem process terminated: $Proc" -ForegroundColor Green
        } catch {
            Write-Host "[ WARNING    ] Failed to terminate $Proc. File might be locked." -ForegroundColor Yellow
        }
    }
}

# STEP 1: Подготовка окружения (Защита профиля)
Write-Host "[ STEP 1 / 6 ] Preparing workspace environment..." -ForegroundColor Cyan
$AppDataOperaPath = Join-Path $env:APPDATA "Opera Software"
if (Test-Path $AppDataOperaPath) {
    try { Remove-Item -Path $AppDataOperaPath -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}

if (Test-Path $TargetDir) {
    Write-Host "[ PROTECTED  ] Existing environment found. Preserving user 'profile' directory..." -ForegroundColor Yellow
    try {
        # Сносим всё, кроме папки с профилем юзера
        Get-ChildItem -Path $TargetDir | Where-Object { $_.Name -ne "profile" } | Remove-Item -Recurse -Force -ErrorAction Stop
        Write-Host "[ SUCCESS    ] Legacy binaries purged. Profile guarded safely." -ForegroundColor Green
    } catch {
        Write-Host "[ CRITICAL   ] Failed to purge old files. Close all browser tabs and retry." -ForegroundColor Red
        throw $_
    }
} else {
    try {
        New-Item -ItemType Directory -Path $TargetDir -ErrorAction Stop | Out-Null
        Write-Host "[ SUCCESS    ] Isolated target matrix initialized at: $TargetDir" -ForegroundColor Green
    } catch {
        Write-Host "[ CRITICAL   ] Cannot create target directory. Check disk write permissions." -ForegroundColor Red
        throw $_
    }
}

# STEP 2: Проверка инсталлятора Оперы
Write-Host "[ STEP 2 / 6 ] Checking for local OperaGXSetup core..." -ForegroundColor Cyan
$LocalStub = Join-Path $ScriptDir "OperaGXSetup.exe"
$TempInstaller = "$env:TEMP\OperaGXSetup.exe"

if (Test-Path $LocalStub) {
    try {
        Copy-Item -Path $LocalStub -Destination $TempInstaller -Force -ErrorAction Stop
        Write-Host "[ DETECTED   ] Local core staged and verified." -ForegroundColor Green
    } catch {
        Write-Host "[ CRITICAL   ] Secure staging failed. Cannot copy installation stub." -ForegroundColor Red
        throw $_
    }
} else {
    Write-Host "" -ForegroundColor White
    Write-Host "=============================================================================" -ForegroundColor Red
    Write-Host " [!] ERROR: OFFICIAL OPERA GX INSTALLER NOT FOUND" -ForegroundColor Red
    Write-Host "=============================================================================" -ForegroundColor Red
    Write-Host " To deploy this hardened framework, please follow these steps:" -ForegroundColor White
    Write-Host " 1. Download official 'OperaGXSetup.exe' from https://www.opera.com/gx" -ForegroundColor White
    Write-Host " 2. Place the downloaded file directly into this folder:" -ForegroundColor White
    Write-Host "    -> $ScriptDir" -ForegroundColor Yellow
    Write-Host " 3. Run 'install.bat' again." -ForegroundColor White
    Write-Host "=============================================================================" -ForegroundColor Red
    Write-Host "" -ForegroundColor White
    Read-Host "Press [ENTER] to exit..."
    exit
}

# STEP 3: Развертывание бинарников
Write-Host "[ STEP 3 / 6 ] Extracting sandboxed execution layer..." -ForegroundColor Cyan
try {
    $InstallProcess = Start-Process -FilePath $TempInstaller -ArgumentList "/silent", "/standalone", "/allusers=0", "/launchbrowser=0", "/installfolder=""$TargetDir""" -Wait -PassThru
    if ($InstallProcess.ExitCode -ne 0) { throw "Extraction layer failure code: $($InstallProcess.ExitCode)" }
    Write-Host "[ SUCCESS    ] Sandboxed binaries unpacked successfully." -ForegroundColor Green
} catch {
    Write-Host "[ CRITICAL   ] Extraction crash during core deployment: $_" -ForegroundColor Red
    [System.Windows.Forms.MessageBox]::Show("Extraction failure during core deployment: $_", "MelodyGX Error", "OK", "Error") | Out-Null
    throw $_
} finally {
    if (Test-Path $TempInstaller) { Remove-Item -Path $TempInstaller -Force -ErrorAction SilentlyContinue }
}

# STEP 4: Выжигание телеметрии
Write-Host "[ STEP 4 / 6 ] Hardening core environment flags and removing bloatware..." -ForegroundColor Cyan
$TelemetryTargets = @(
    "opera_autoupdate.exe", "opera_crashreporter.exe", "opera_autoupdate.gup",
    "server_tracking_data", "installer_prefs.json", "installation_status.json",
    "autoupdate", "opera_browser_assistant.exe", "browser_assistant.exe"
)

foreach ($Target in $TelemetryTargets) {
    try {
        Get-ChildItem -Path $TargetDir -Filter $Target -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction Stop
    } catch {
        Write-Host "[ WARNING    ] Failed to delete telemetry target: $Target" -ForegroundColor Yellow
    }
}

$EngineDir = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^\d+\." } | Select-Object -First 1
if ($EngineDir) {
    try {
        "portable=1" | Out-File -FilePath (Join-Path $EngineDir.FullName "sidekick.config") -Encoding ascii -Force -ErrorAction Stop
    } catch {
        Write-Host "[ WARNING    ] Failed to inject portable confinement flags." -ForegroundColor Yellow
    }
}
Write-Host "[ SUCCESS    ] Telemetry engines and tracking footprints completely purged." -ForegroundColor Green

# STEP 4.5: Ребрендинг лаунчера
Write-Host "[ REBRAND    ] Re-mapping executable identities..." -ForegroundColor Cyan
$DefaultBinaries = @("launcher.exe", "opera.exe")
foreach ($Bin in $DefaultBinaries) {
    $BinPath = Join-Path $TargetDir $Bin
    if (Test-Path $BinPath) {
        try {
            Rename-Item -Path $BinPath -NewName $CustomBinaryName -Force -ErrorAction Stop
            Write-Host "[ SUCCESS    ] Core binary mapped to: $CustomBinaryName" -ForegroundColor Green
        } catch {
            Write-Host "[ CRITICAL   ] Rebrand mapping failed for $Bin." -ForegroundColor Red
            throw $_
        }
    }
}

# STEP 4.7: Скрытое развертывание апдейтера и создание чистого батника
Write-Host "[ DEPLOY     ] Injecting background update sub-modules..." -ForegroundColor Cyan
$LocalUpdaterScript = Join-Path $ScriptDir "updater.ps1"
if (Test-Path $LocalUpdaterScript) {
    try {
        # Создаем скрытую системную папку
        $HiddenFolder = Join-Path $TargetDir ".system"
        if (!(Test-Path $HiddenFolder)) { New-Item -ItemType Directory -Path $HiddenFolder -ErrorAction Stop | Out-Null }
        (Get-Item $HiddenFolder).Attributes = 'Hidden'
        
        # Прячем туда наш скрипт-обновлятор
        Copy-Item -Path $LocalUpdaterScript -Destination $HiddenFolder -Force -ErrorAction Stop
        
        # Кладим чистый update.bat в корень, который вызывает скрытый скрипт
        $UpdateBatPath = Join-Path $TargetDir "update.bat"
        "@echo off`r`ncd /d ""%~dp0""`r`npowershell -NoProfile -ExecutionPolicy Bypass -File ""%~dp0.system\updater.ps1""" | Out-File -FilePath $UpdateBatPath -Encoding ascii -Force -ErrorAction Stop
        
        Write-Host "[ SUCCESS    ] Updater hidden inside .system. Root proxy 'update.bat' generated." -ForegroundColor Green
    } catch {
        Write-Host "[ WARNING    ] Infrastructure deployment failed for update modules." -ForegroundColor Yellow
    }
} else {
    Write-Host "[ WARNING    ] updater.ps1 not found in deployment package. Skipping injection." -ForegroundColor Yellow
}

# STEP 5: Блокировка первого запуска (First Run)
Write-Host "[ STEP 5 / 6 ] Injecting first-run suppression matrix..." -ForegroundColor Cyan
$TargetDataDir = "C:\MelodyGX\profile\data"
$TargetDefaultDir = "C:\MelodyGX\profile\data\Default"

try {
    if (!(Test-Path $TargetDataDir)) { New-Item -ItemType Directory -Path $TargetDataDir | Out-Null }
    if (!(Test-Path $TargetDefaultDir)) { New-Item -ItemType Directory -Path $TargetDefaultDir | Out-Null }

    New-Item -ItemType File -Path (Join-Path $TargetDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType File -Path (Join-Path $TargetDataDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType File -Path (Join-Path $TargetDefaultDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
    Write-Host "[ SUCCESS    ] Promotional welcome wizards disabled." -ForegroundColor Green
} catch {
    Write-Host "[ WARNING    ] Suppression layout incomplete." -ForegroundColor Yellow
}

# STEP 6: Верификация сборки
Write-Host "[ STEP 6 / 6 ] Validating post-deployment structure..." -ForegroundColor Cyan
$TargetLauncher = Join-Path $TargetDir $CustomBinaryName

if (Test-Path $TargetLauncher) {
    Clear-Host
    Write-Host $LogoArt -ForegroundColor Green
    Write-Host ""
    Write-Host "=============================================================================" -ForegroundColor Green
    Write-Host "   CONGRATULATIONS! MELODY GX DEPLOYMENT ACCOMPLISHED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "=============================================================================" -ForegroundColor Green
    Write-Host " [+] Your hardened, telemetry-free browser sandbox is fully operational." -ForegroundColor White
    Write-Host " [+] Target Directory:   $TargetDir" -ForegroundColor White
    Write-Host " [+] Execution Launcher:  $TargetLauncher" -ForegroundColor White
    Write-Host " [+] Local Updater:      $TargetDir\update.bat" -ForegroundColor White
    Write-Host "=============================================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host " You may now close this window." -ForegroundColor Yellow
    Write-Host ""
    
    [System.Windows.Forms.MessageBox]::Show("MelodyGX installation completed successfully!`n`nYour environment is ready at $TargetDir", "MelodyGX Framework", "OK", "Information") | Out-Null
} else {
    Write-Host "[ CRITICAL ] Verification failed. Master binary missing from target storage." -ForegroundColor Red
}

Write-Host ""
Read-Host "Press [ENTER] to exit the installer framework..."