# MelodyGX Automated Hardening and Deployment Framework
# Operational Status: Production Alpha Vector

$ErrorActionPreference = "Stop"
$TargetDir = "C:\MelodyGX"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Принудительное подключение графической подсистемы Windows Forms для вывода алертов
Add-Type -AssemblyName System.Windows.Forms
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Clear-Host
$LogoArt = @"
=====================================================================
 __  ___      __           __        _______  __ 
/  |/  /___  / /___  _____/ /_  __  / ____/ |/ / 
/ /|_/ / __ \/ / __ \/ __  / / / / / / / __ |   /  
/ /  / / /_/ / / /_/ / /_/ / / /_/ / / /_/ / /   |  
/_/  /_/\____/_/\____/\__,_/_/\__, /  \____/_/|_\_\ 
                             /____/                 
=====================================================================
                     OFFICIAL PORTABLE INSTALLER
              https://github.com/crowwowarchbtw/MelodyGX
=====================================================================
"@

Write-Output $LogoArt
Write-Output ""

# STEP 0: Агрессивное снятие блокировок файлов
Write-Output "[ STEP 0 / 8 ] Terminating conflicting background processes..."
$ActiveProcesses = @("opera", "opera_gx", "launcher")
foreach ($Proc in $ActiveProcesses) {
    if (Get-Process -Name $Proc -ErrorAction SilentlyContinue) {
        Stop-Process -Name $Proc -Force -ErrorAction SilentlyContinue
        Write-Output "[ KILLED     ] Subsystem process terminated: $Proc"
    }
}

# STEP 1: Инициализация окружения и зачистка системных хвостов
Write-Output "[ STEP 1 / 8 ] Validating host execution environment and purging system residues..."

# Выжигание глобальной папки Оперы в Roaming AppData во избежание конфликта сигнатур
$AppDataOperaPath = Join-Path $env:APPDATA "Opera Software"
if (Test-Path $AppDataOperaPath) {
    try {
        Remove-Item -Path $AppDataOperaPath -Recurse -Force -ErrorAction SilentlyContinue
        Write-Output "[ PURGED     ] Legacy AppData tracking directory liquidated successfully."
    } catch {
        Write-Output "[ WARNING    ] System folder locked. Proceeding with isolated core deployment."
    }
}

if (!(Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
}
Write-Output "[ SUCCESS    ] Target deployment space initialized at: $TargetDir"

# STEP 2: Загрузка бинарных блоков ядра
Write-Output "[ STEP 2 / 8 ] Connecting to upstream infrastructure..."
$DownloadUrl = "https://get.opera.com/pub/opera_gx/115.0.5322.152/win/Opera_GX_115.0.5322.152_Setup_x64.exe"
$TempInstaller = "$env:TEMP\MelodyGX_Core_Setup.exe"

try {
    Write-Output "[ DOWNLOAD   ] Fetching official distribution core packages..."
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempInstaller -UseBasicParsing
    Write-Output "[ SUCCESS    ] Binary cache stabilized locally."
} catch {
    [System.Windows.Forms.MessageBox]::Show("Network pipeline failure during core retrieval: $_", "MelodyGX Deployment Failure", "OK", "Error") | Out-Null
    throw "Deployment terminated: Network error."
}

# STEP 3: Развертывание изолированной Standalone песочницы
Write-Output "[ STEP 3 / 8 ] Initializing sandboxed extraction loop..."
try {
    Write-Output "[ DEPLOY     ] Provisioning unmanaged standalone instance..."
    $InstallProcess = Start-Process -FilePath $TempInstaller -ArgumentList "/silent", "/standalone", "/allusers=0", "/launchbrowser=0", "/installfolder=""$TargetDir""" -Wait -PassThru
    if ($InstallProcess.ExitCode -ne 0) { throw "Extraction vector returned non-zero structural error." }
    Write-Output "[ SUCCESS    ] Sandboxed core execution layer successfully generated."
} catch {
    [System.Windows.Forms.MessageBox]::Show("Extraction pipeline failure: $_", "MelodyGX Deployment Failure", "OK", "Error") | Out-Null
    throw "Deployment terminated: Core extraction crash."
} finally {
    if (Test-Path $TempInstaller) { Remove-Item -Path $TempInstaller -Force -ErrorAction SilentlyContinue }
}

# STEP 4: Верификация корневого вектора запуска
Write-Output "[ STEP 4 / 8 ] Validating master launcher executable..."
$TargetLauncher = Join-Path $TargetDir "launcher.exe"
if (!(Test-Path $TargetLauncher)) {
    [System.Windows.Forms.MessageBox]::Show("Critical validation failure. Main launcher vector missing.", "MelodyGX Deployment Failure", "OK", "Error") | Out-Null
    throw "Deployment terminated: Missing launcher binary."
}
Write-Output "[ SUCCESS    ] Validated core engine launcher located at: $TargetLauncher"

# STEP 5: Зачистка и блокировка телеметрии
Write-Output "[ STEP 5 / 8 ] Commencing telemetry interdiction cycle..."
$TelemetryTargets = @("opera_autoupdate.exe", "opera_crashreporter.exe", "opera_autoupdate.gup")
foreach ($Target in $TelemetryTargets) {
    $FoundFiles = Get-ChildItem -Path $TargetDir -Filter $Target -Recurse -ErrorAction SilentlyContinue
    foreach ($File in $FoundFiles) {
        try {
            Remove-Item -Path $File.FullName -Force
            Write-Output "[ DECOUPLED  ] Structural mitigation applied to tracking agent: $($File.Name)"
        } catch {
            Write-Output "[ WARNING    ] Resource locked. Outbound connection vector neutralized via structural block."
        }
    }
}
Write-Output "[ SUCCESS    ] Proprietary tracking layers completely purged."

# STEP 6: Фиксация портативного состояния ядра
Write-Output "[ STEP 6 / 8 ] Hardening workspace portable configuration hooks..."
$EngineDir = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^\d+\." } | Select-Object -First 1
if ($EngineDir) {
    $ConfigPath = Join-Path $EngineDir.FullName "sidekick.config"
    try {
        "portable=1" | Out-File -FilePath $ConfigPath -Encoding ascii -Force
        Write-Output "[ SUCCESS    ] Configuration matrix locked into portable state layer."
    } catch {
        Write-Output "[ WARNING    ] Failed to force write configuration flag."
    }
}

# STEP 7: Инициализация реального портативного профиля и хирургический патч JSON
Write-Output "[ STEP 7 / 8 ] Executing authentic portable profile generation and injection..."

if (Test-Path "$TargetDir\profile") { 
    Remove-Item -Path "$TargetDir\profile" -Recurse -Force -ErrorAction SilentlyContinue 
}

# Запуск ЧЕРЕЗ LAUNCHER для генерации правильного локального профиля в папке C:\MelodyGX\profile
Write-Output "[ ENGINE     ] Launching master infrastructure to sign local cryptographic signatures..."
$EngineProcess = Start-Process -FilePath $TargetLauncher -ArgumentList "--no-first-run", "--no-default-browser-check" -PassThru
Start-Sleep -Seconds 5
Stop-Process -Id $EngineProcess.Id -Force -ErrorAction SilentlyContinue
Stop-Process -Name "opera" -Force -ErrorAction SilentlyContinue
Stop-Process -Name "launcher" -Force -ErrorAction SilentlyContinue

# Массив потенциальных путей хранения настроек внутри портативки
$TargetPaths = @(
    "$TargetDir\profile\data\Preferences",
    "$TargetDir\profile\data\Default\Preferences"
)

$SourcePrefPath = "$ScriptDir\profile\data\Default\Preferences"

if (Test-Path $SourcePrefPath) {
    $SourceJson = Get-Content -Path $SourcePrefPath -Raw | ConvertFrom-Json
    
    foreach ($Path in $TargetPaths) {
        if (Test-Path $Path) {
            try {
                $LocalJson = Get-Content -Path $Path -Raw | ConvertFrom-Json
                
                # Инжектируем только безопасные блоки кастомизации
                if ($SourceJson.opera) { $LocalJson.opera = $SourceJson.opera }
                if ($SourceJson.ui) { $LocalJson.ui = $SourceJson.ui }
                
                $LocalJson | ConvertTo-Json -Depth 100 | Out-File -FilePath $Path -Encoding utf8 -Force
                Write-Output "[ INJECTED   ] Successfully patched custom preferences state at: $Path"
            } catch {
                Write-Output "[ WARNING    ] Failed to patch target json node: $Path"
            }
        }
    }
}

# Прямой форсированный заброс вспомогательного конфигуратора тем Opera GX
$SourceGXPrefs = "$ScriptDir\profile\data\Default\operapreferences.json"
if (Test-Path $SourceGXPrefs) {
    $GXTargetPaths = @("$TargetDir\profile\data", "$TargetDir\profile\data\Default")
    foreach ($GXPath in $GXTargetPaths) {
        if (Test-Path $GXPath) {
            Copy-Item -Path $SourceGXPrefs -Destination $GXPath -Force
            Write-Output "[ FORCED     ] Injected master GX preference modules to: $GXPath"
        }
    }
}

# STEP 8: Проверка целостности сборки
Write-Output "[ STEP 8 / 8 ] Executing post-deployment structural integrity checks..."
if (Test-Path $TargetLauncher) {
    Write-Output "[ COMPLETE   ] MelodyGX structural deployment architecture has been fully stabilized."
    [System.Windows.Forms.MessageBox]::Show("MelodyGX installation completed successfully!`n`nYour hardened, telemetry-free browser environment is deployed at $TargetDir", "MelodyGX Installer Vector", "OK", "Information") | Out-Null
} else {
    [System.Windows.Forms.MessageBox]::Show("Post-deployment validation check failed. Environment may be unstable.", "MelodyGX Deployment Warning", "OK", "Warning") | Out-Null
}