# Подключаем виндовые формы для вызова всплывающих окон
[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms')

# Очищаем консоль и ставим красивый заголовок окна
Clear-Host
$host.UI.RawUI.WindowTitle = "MelodyGX Installer v0.1-Alpha"

# Правильный, четкий ASCII-арт MelodyGX на английском
Write-Host '====================================================' -ForegroundColor Magenta
Write-Host '  __  __      _           _       _______  __  __   ' -ForegroundColor Cyan
Write-Host ' |  \/  | ___| | ___   __| |_   _/  _____| \ \/ /   ' -ForegroundColor Cyan
Write-Host ' | |\/| |/ _ \ |/ _ \ / _` | | | |  |  __   \  /    ' -ForegroundColor Cyan
Write-Host ' | |  | |  __/ | (_) | (_| | |_| |  |___| |  /  \   ' -ForegroundColor Cyan
Write-Host ' |_|  |_|\___|_|\___/ \__,_|\__, | \______| /_/\_\  ' -ForegroundColor Cyan
Write-Host '                           |___/                    ' -ForegroundColor Cyan
Write-Host '====================================================' -ForegroundColor Magenta
Write-Host '             OFFICIAL PORTABLE INSTALLER            ' -ForegroundColor DarkMagenta
Write-Host '====================================================' -ForegroundColor Magenta
Write-Host ""

# Включаем режим, при котором любая мелкая ошибка считается критической (стопорит скрипт)
$ErrorActionPreference = "Stop"

try {
    # Авто-определение путей
    $ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    $TargetDir = "C:\MelodyGX"
    $TempInstaller = "$env:TEMP\opera_setup.exe"

    # Step 1: Проверка локальных конфигов перед стартом
    Write-Host "[ PREPARE  ] Verifying local build configuration..." -ForegroundColor Gray
    Start-Sleep -Milliseconds 300
    if (!(Test-Path "$ScriptDir\profile\Default\Preferences")) {
        throw "Required profile file not found: \profile\Default\Preferences. Check your repository structure!"
    }

    # Step 2: Загрузка ядра
    Write-Host "[ DOWNLOAD ] Connecting to distribution servers..." -ForegroundColor Gray
    $DownloadUrl = "https://net.geo.opera.com/ftp/pub/opera_gx/131.0.5877.84/win/Opera_GX_131.0.5877.84_Setup_x64.exe"
    Write-Host "[ DOWNLOAD ] Downloading clean Chromium core..." -ForegroundColor Yellow
    Invoke-WebRequest -Uri $DownloadUrl -OutFile $TempInstaller
    Write-Host "[ SUCCESS  ] Core package saved to temporary cache." -ForegroundColor Green

    # Step 3: Распаковка
    Write-Host "[ DEPLOY   ] Creating target directory at $TargetDir..." -ForegroundColor Gray
    if (!(Test-Path $TargetDir)) { New-Item -ItemType Directory -Path $TargetDir | Out-Null }
    
    Write-Host "[ DEPLOY   ] Extracting core files (this may take 10-15 seconds)..." -ForegroundColor Yellow
    $InstallProcess = Start-Process -FilePath $TempInstaller -ArgumentList "/silent", "/allusers=0", "/launchbrowser=0", "/installfolder=""$TargetDir""" -Wait -PassThru
    
    if ($InstallProcess.ExitCode -ne 0) {
        throw "Official engine installer failed with exit code: $($InstallProcess.ExitCode)"
    }
    Write-Host "[ SUCCESS  ] Core engine successfully deployed." -ForegroundColor Green

    # Step 4: Выпил телеметрии
    Write-Host "[ CLEANING ] Scanning for stock telemetry and tracking modules..." -ForegroundColor Gray
    $FilesToRemove = @("opera_autoupdate.exe", "opera_crashreporter.exe", "opera_autoupdate.gup")
    foreach ($file in $FilesToRemove) {
        $filePath = Join-Path $TargetDir $file
        if (Test-Path $filePath) {
            Write-Host "[ REMOVING ] Stripping telemetry node: $file" -ForegroundColor DarkYellow
            Remove-Item $filePath -Force
        }
    }

    # Step 5: Переименование
    Write-Host "[ REBRAND  ] Rebuilding main executable block..." -ForegroundColor Gray
    $OldExe = Join-Path $TargetDir "opera.exe"
    $NewExe = Join-Path $TargetDir "melody.exe"
    if (!(Test-Path $OldExe)) { throw "Critical error: opera.exe not found in target folder after extraction!" }
    
    Rename-Item -Path $OldExe -NewName "melody.exe" -Force
    Write-Host "[ SUCCESS  ] Core binary rebranded to melody.exe" -ForegroundColor Green

    # Step 6: Конфиг портатива
    Write-Host "[ CONFIG   ] Writing sidekick.config for isolated Portable Mode..." -ForegroundColor Gray
    $ConfigPath = Join-Path $TargetDir "sidekick.config"
    $ConfigContent = '{"type": "portable", "profile_dir": "profile"}'
    Set-Content -Path $ConfigPath -Value $ConfigContent

    # Step 7: Накат твоего кастомного профиля
    Write-Host "[ CONFIG   ] Importing pre-configured user profile layout..." -ForegroundColor Gray
    $ProfileDir = "$TargetDir\profile\Default"
    if (!(Test-Path $ProfileDir)) { New-Item -ItemType Directory -Path $ProfileDir | Out-Null }
    
    Copy-Item -Path "$ScriptDir\profile\Default\Preferences" -Destination $ProfileDir -Force
    Copy-Item -Path "$ScriptDir\profile\Default\Secure Preferences" -Destination $ProfileDir -Force
    Write-Host "[ SUCCESS  ] Custom ad-free preferences injected successfully." -ForegroundColor Green

    # Финал
    if (Test-Path $TempInstaller) { Remove-Item $TempInstaller -Force }
    
    Write-Host ""
    Write-Host '====================================================' -ForegroundColor Magenta
    Write-Host "[ COMPLETE ] MelodyGX Core has been fully deployed! " -ForegroundColor Green
    Write-Host '====================================================' -ForegroundColor Magenta
    
    [System.Windows.Forms.MessageBox]::Show("MelodyGX installation completed successfully!`n`nYour browser is deployed at C:\MelodyGX", "MelodyGX Installer", 'OK', 'Information')

} catch {
    # Если ловим эксепшн:
    Write-Host ""
    Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
    Write-Host "[ CRITICAL ERROR ] Installation aborted!" -ForegroundColor Red
    Write-Host "Exception details: $_" -ForegroundColor DarkRed
    Write-Host "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" -ForegroundColor Red
    
    # Английское окно с ошибкой
    [System.Windows.Forms.MessageBox]::Show("An error occurred during MelodyGX deployment!`n`nError details:`n$_", "MelodyGX Deployment Failure", 'OK', 'Error')
    Exit 1
}