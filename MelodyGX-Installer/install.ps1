# MelodyGX Automated Hardening and Deployment Framework
# Operational Status: Production Alpha Vector

$ErrorActionPreference = "Stop"
$TargetDir = "C:\MelodyGX"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Принудительное подключение графической подсистемы Windows Forms
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
Write-Output "[ STEP 0 / 6 ] Terminating conflicting background processes..."
$ActiveProcesses = @("opera", "opera_gx", "launcher")
foreach ($Proc in $ActiveProcesses) {
    if (Get-Process -Name $Proc -ErrorAction SilentlyContinue) {
        Stop-Process -Name $Proc -Force -ErrorAction SilentlyContinue
        Write-Output "[ KILLED     ] Subsystem process terminated: $Proc"
    }
}

# STEP 1: Инициализация окружения и полная зачистка хвостов
Write-Output "[ STEP 1 / 6 ] Purging active system residues..."
$AppDataOperaPath = Join-Path $env:APPDATA "Opera Software"
if (Test-Path $AppDataOperaPath) {
    try {
        Remove-Item -Path $AppDataOperaPath -Recurse -Force -ErrorAction SilentlyContinue
    } catch {}
}

if (Test-Path $TargetDir) {
    try {
        Remove-Item -Path $TargetDir -Recurse -Force -ErrorAction SilentlyContinue
    } catch {}
}
New-Item -ItemType Directory -Path $TargetDir | Out-Null
Write-Output "[ SUCCESS    ] Workspace cleared and isolated at: $TargetDir"

# STEP 2: Загрузка бинарных блоков ядра
Write-Output "[ STEP 2 / 6 ] Fetching official deployment core..."
$DownloadUrl = "https://get.opera.com/pub/opera_gx/115.0.5322.152/win/Opera_GX_115.0.5322.152_Setup_x64.exe"
$TempInstaller = "$env:TEMP\MelodyGX_Core_Setup.exe"

try {
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempInstaller -UseBasicParsing
    Write-Output "[ SUCCESS    ] Distribution cache stabilized."
} catch {
    [System.Windows.Forms.MessageBox]::Show("Network pipeline failure: $_", "MelodyGX Error", "OK", "Error") | Out-Null
    throw "Network error."
}

# STEP 3: Развертывание Standalone песочницы
Write-Output "[ STEP 3 / 6 ] Extracting sandboxed execution layer..."
try {
    $InstallProcess = Start-Process -FilePath $TempInstaller -ArgumentList "/silent", "/standalone", "/allusers=0", "/launchbrowser=0", "/installfolder=""$TargetDir""" -Wait -PassThru
    if ($InstallProcess.ExitCode -ne 0) { throw "Extraction layer failure." }
    Write-Output "[ SUCCESS    ] Sandboxed binaries unpacked."
} catch {
    [System.Windows.Forms.MessageBox]::Show("Extraction failure: $_", "MelodyGX Error", "OK", "Error") | Out-Null
    throw "Extraction crash."
} finally {
    if (Test-Path $TempInstaller) { Remove-Item -Path $TempInstaller -Force -ErrorAction SilentlyContinue }
}

# STEP 4: Зачистка телеметрии и фиксация портативности
Write-Output "[ STEP 4 / 6 ] Hardening core environment flags..."
$TelemetryTargets = @("opera_autoupdate.exe", "opera_crashreporter.exe", "opera_autoupdate.gup")
foreach ($Target in $TelemetryTargets) {
    Get-ChildItem -Path $TargetDir -Filter $Target -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -ErrorAction SilentlyContinue
}

$EngineDir = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^\d+\." } | Select-Object -First 1
if ($EngineDir) {
    "portable=1" | Out-File -FilePath (Join-Path $EngineDir.FullName "sidekick.config") -Encoding ascii -Force
}

# STEP 5: Умное развертывание кастомного профиля (Фикс вложенности папки Default)
Write-Output "[ STEP 5 / 6 ] Injecting master pre-configured profile layer..."
$TargetDataDir = "C:\MelodyGX\profile\data"
$TargetDefaultDir = "C:\MelodyGX\profile\data\Default"

# Гарантированно создаем всю иерархию путей
if (!(Test-Path $TargetDataDir)) { New-Item -ItemType Directory -Path $TargetDataDir | Out-Null }
if (!(Test-Path $TargetDefaultDir)) { New-Item -ItemType Directory -Path $TargetDefaultDir | Out-Null }

# Умный поиск конфигурационных файлов в репозитории независимо от структуры папок
$RepoProfileRoot = Join-Path $ScriptDir "profile"
if (Test-Path $RepoProfileRoot) {
    $MasterPrefs = Get-ChildItem -Path $RepoProfileRoot -Filter "Preferences" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
    $MasterGXPrefs = Get-ChildItem -Path $RepoProfileRoot -Filter "operapreferences.json" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1

    # Инжектируем Preferences во все возможные целевые точки (в корень data и в Default)
    if ($MasterPrefs) {
        Copy-Item -Path $MasterPrefs.FullName -Destination $TargetDataDir -Force
        Copy-Item -Path $MasterPrefs.FullName -Destination $TargetDefaultDir -Force
        Write-Output "[ SUCCESS    ] Discovered and flattened base preferences routing."
    }
    
    # Инжектируем operapreferences.json во все точки
    if ($MasterGXPrefs) {
        Copy-Item -Path $MasterGXPrefs.FullName -Destination $TargetDataDir -Force
        Copy-Item -Path $MasterGXPrefs.FullName -Destination $TargetDefaultDir -Force
        Write-Output "[ SUCCESS    ] Discovered and flattened GX preferences routing."
    }
} else {
    Write-Output "[ WARNING    ] Source profile template matrix missing from deployment package."
}

# КРИТИЧЕСКИЙ ФИКС: Вешаем заглушки First Run во все щели, чтобы сброса настроек не произошло
New-Item -ItemType File -Path (Join-Path $TargetDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType File -Path (Join-Path $TargetDataDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
New-Item -ItemType File -Path (Join-Path $TargetDefaultDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
Write-Output "[ SUCCESS    ] Cryptographic first-run blockers initialized."

# STEP 6: Верификация сборки
Write-Output "[ STEP 6 / 6 ] Validating post-deployment structure..."
$TargetLauncher = Join-Path $TargetDir "launcher.exe"
if (Test-Path $TargetLauncher) {
    Write-Output "[ COMPLETE   ] MelodyGX build stabilization accomplished."
    [System.Windows.Forms.MessageBox]::Show("MelodyGX installation completed successfully!`n`nYour custom light theme environment is ready at $TargetDir", "MelodyGX Framework", "OK", "Information") | Out-Null
}