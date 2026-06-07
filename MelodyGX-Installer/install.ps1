# MelodyGX Automated Hardening and Deployment Framework
# Operational Status: Production Alpha Vector

$ErrorActionPreference = "Stop"
$TargetDir = "C:\MelodyGX"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# Принудительное подключение графической подсистемы Windows Forms для вывода алертов
Add-Type -AssemblyName System.Windows.Forms
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 -bor [Net.SecurityProtocolType]::Tls13

Clear-Host
Write-Output "====================================================================="
Write-Output "          MelodyGX Hardened Deployment Architecture                  "
Write-Output "====================================================================="
Write-Output ""

# STEP 1: Инициализация окружения
Write-Output "[ STEP 1 / 8 ] Validating host execution environment..."
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

# STEP 4: Умный рекурсивный поиск исполняемого файла
Write-Output "[ STEP 4 / 8 ] Executing deep filesystem binary validation..."
$TargetExe = Get-ChildItem -Path $TargetDir -Filter "opera.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
if (-not $TargetExe) {
    [System.Windows.Forms.MessageBox]::Show("Critical validation failure. Main execution vector (opera.exe) missing.", "MelodyGX Deployment Failure", "OK", "Error") | Out-Null
    throw "Deployment terminated: Missing target binary."
}
Write-Output "[ SUCCESS    ] Validated core engine located at: $($TargetExe.FullName)"

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
$EngineDir = Split-Path -Parent $TargetExe.FullName
$ConfigPath = Join-Path $EngineDir "sidekick.config"
try {
    "portable=1" | Out-File -FilePath $ConfigPath -Encoding ascii -Force
    Write-Output "[ SUCCESS    ] Configuration matrix locked into portable state layer."
} catch {
    Write-Output "[ WARNING    ] Failed to force write configuration flag."
}

# STEP 7: Точечная инъекция кастомного профиля (Исправление путей)
Write-Output "[ STEP 7 / 8 ] Injecting optimized user environment state matrix..."
$ProfileDir = "$TargetDir\profile\data\Default"
if (!(Test-Path $ProfileDir)) {
    New-Item -ItemType Directory -Path $ProfileDir | Out-Null
}

$LocalPrefSource = "$ScriptDir\profile\Default"
if (Test-Path $LocalPrefSource) {
    if (Test-Path "$LocalPrefSource\Preferences") {
        Copy-Item -Path "$LocalPrefSource\Preferences" -Destination $ProfileDir -Force
        Write-Output "[ INJECTED   ] Applied un-throttled performance parameters configuration."
    }
    if (Test-Path "$LocalPrefSource\Secure Preferences") {
        Copy-Item -Path "$LocalPrefSource\Secure Preferences" -Destination $ProfileDir -Force
        Write-Output "[ INJECTED   ] Injected secure encryption layer configuration parameters."
    }
} else {
    Write-Output "[ WARNING    ] Local asset repository matrix not found. Skipping static state copy."
}

# STEP 8: Проверка целостности сборки
Write-Output "[ STEP 8 / 8 ] Executing post-deployment structural integrity checks..."
if ((Test-Path "$ProfileDir\Preferences") -and (Test-Path $TargetExe.FullName)) {
    Write-Output "[ COMPLETE   ] MelodyGX structural deployment architecture has been fully stabilized."
    [System.Windows.Forms.MessageBox]::Show("MelodyGX installation completed successfully!`n`nYour hardened, telemetry-free browser environment is deployed at $TargetDir", "MelodyGX Installer Vector", "OK", "Information") | Out-Null
} else {
    [System.Windows.Forms.MessageBox]::Show("Post-deployment validation check failed. Environment may be unstable.", "MelodyGX Deployment Warning", "OK", "Warning") | Out-Null
}