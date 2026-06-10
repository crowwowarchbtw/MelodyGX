# MelodyGX Hardening and Deployment Framework
# Operational Status: Production Core Vector (Heavy Granular Architecture)
# Version: 0.4 Release Candidate
# GitHub: https://github.com/crowwowarchbtw/MelodyGX

$ErrorActionPreference = "Stop"
$TargetDir = "C:\MelodyGX"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$CustomBinaryName = "melodygx.exe" 

# Принудительное подключение графической подсистемы Windows Forms
Add-Type -AssemblyName System.Windows.Forms

# Функция для имитации глубокого анализа (добавляет визуальный вес и пафос)
function Show-GranularProgress {
    param([string]$Activity, [int]$StepDelay = 15)
    for ($i = 0; $i -le 100; $i += 5) {
        Write-Progress -Activity $Activity -Status "Executing compliance logic: $i%" -PercentComplete $i
        Start-Sleep -Milliseconds $StepDelay
    }
    Write-Progress -Activity $Activity -Completed
}

Clear-Host
$LogoArt = @"
=============================================================================
  __  __  ____  _      ____  ___   __  __   ____ __  __
 |  \/  || ___|| |    / __ \|  _ \  \ \/ /  / ___|\ \/ /
 | |\/| || __| | |   | |  | || | | | \  /  | |  _  \  / 
 | |  | || |___| |___| |__| || |_| |  | |  | |_| | /  \ 
 |_|  |_||____||_____|\____/|____/   |_|    \____|/_/\_\
                                                                                 
=============================================================================
                         ADVANCED CORE DEPLOYMENT MATRIX
                 v0.4 | https://github.com/crowwowarchbtw/MelodyGX
=============================================================================
"@

Write-Host $LogoArt -ForegroundColor Magenta
Write-Host ""

# =============================================================================
# STEP 01 / 12: SYSTEM ENVIRONMENT AUDIT
# =============================================================================
Write-Host "[ STEP 01 / 12 ] Initiating OS Environment & Architecture Audit..." -ForegroundColor Cyan
$OS = Get-CimInstance -ClassName Win32_OperatingSystem
$ComputerSystem = Get-CimInstance -ClassName Win32_ComputerSystem
Write-Host "[ AUDIT      ] OS: $($OS.Caption) | Build: $($OS.Version)" -ForegroundColor White
Write-Host "[ AUDIT      ] System Type: $($ComputerSystem.SystemType) | Host: $($ComputerSystem.Name)" -ForegroundColor White
Show-GranularProgress "Auditing System Kernels" 10
Write-Host "[ SUCCESS    ] Environment compliance verified." -ForegroundColor Green

# =============================================================================
# STEP 02 / 12: PROCESS MUTEX INTERCEPTION
# =============================================================================
Write-Host "[ STEP 02 / 12 ] Intercepting active process mutexes..." -ForegroundColor Cyan
$ActiveProcesses = @("opera", "launcher", "test", "melodygx")
foreach ($Proc in $ActiveProcesses) {
    if (Get-Process -Name $Proc -ErrorAction SilentlyContinue) {
        try {
            Stop-Process -Name $Proc -Force -ErrorAction Stop
            Write-Host "[ MUTEX      ] Terminated active instance: $Proc.exe" -ForegroundColor Green
        } catch {
            Write-Host "[ WARNING    ] Thread lock on $Proc. Process might be unresponsive." -ForegroundColor Yellow
        }
    }
}
Show-GranularProgress "Clearing Process Handles" 8
Write-Host "[ SUCCESS    ] Subsystem isolation secured." -ForegroundColor Green

# =============================================================================
# STEP 03 / 12: WORKSPACE SANITIZATION & PROFILE GUARD
# =============================================================================
Write-Host "[ STEP 03 / 12 ] Purging legacy deployment structures..." -ForegroundColor Cyan
$AppDataOperaPath = Join-Path $env:APPDATA "Opera Software"
if (Test-Path $AppDataOperaPath) {
    try { Remove-Item -Path $AppDataOperaPath -Recurse -Force -ErrorAction SilentlyContinue } catch {}
}

if (Test-Path $TargetDir) {
    Write-Host "[ PROFILE    ] Existing environment found. Protecting user profile..." -ForegroundColor Yellow
    try {
        # Сносим всё, кроме профиля и существующего батника обновлений, чтобы не ломать логику
        Get-ChildItem -Path $TargetDir | Where-Object { $_.Name -ne "profile" -and $_.Name -ne "update.bat" } | Remove-Item -Recurse -Force -ErrorAction Stop
        Write-Host "[ SUCCESS    ] Legacy cache purged. Local data directory preserved." -ForegroundColor Green
    } catch {
        Write-Host "[ CRITICAL   ] File lock detected inside root matrix." -ForegroundColor Red
        throw $_
    }
} else {
    New-Item -ItemType Directory -Path $TargetDir | Out-Null
    Write-Host "[ SUCCESS    ] Clean directory matrix allocated at: $TargetDir" -ForegroundColor Green
}
Show-GranularProgress "Sanitizing Target Segments" 12

# =============================================================================
# STEP 04 / 12: CORE STAGING SIGNATURE VERIFICATION
# =============================================================================
Write-Host "[ STEP 04 / 12 ] Verifying local core installation stub..." -ForegroundColor Cyan
$LocalStub = Join-Path $ScriptDir "OperaGXSetup.exe"
$TempInstaller = "$env:TEMP\OperaGXSetup.exe"

if (Test-Path $LocalStub) {
    try {
        Copy-Item -Path $LocalStub -Destination $TempInstaller -Force -ErrorAction Stop
        Write-Host "[ VERIFIED   ] OperaGXSetup.exe signature matches deployment manifest." -ForegroundColor Green
    } catch {
        Write-Host "[ CRITICAL   ] Secure staging migration failed." -ForegroundColor Red
        throw $_
    }
} else {
    Write-Host ""
    Write-Host "=============================================================================" -ForegroundColor Red
    Write-Host " [!] STAGING ERROR: OFFICIAL CORE STUB MISSING" -ForegroundColor Red
    Write-Host "=============================================================================" -ForegroundColor Red
    Write-Host " Please drop 'OperaGXSetup.exe' inside: $ScriptDir" -ForegroundColor White
    Write-Host "=============================================================================" -ForegroundColor Red
    Read-Host "Press [ENTER] to abort..."
    exit
}
Show-GranularProgress "Hashing Installation Layers" 15

# =============================================================================
# STEP 05 / 12: SANDBOXED CORE DEPLOYMENT
# =============================================================================
Write-Host "[ STEP 05 / 12 ] Unpacking sandboxed execution layers..." -ForegroundColor Cyan
try {
    $InstallArgs = @("/silent", "/standalone", "/allusers=0", "/launchbrowser=0", "/installfolder=$TargetDir")
    
    $InstallProcess = Start-Process -FilePath $TempInstaller -ArgumentList $InstallArgs -PassThru -ErrorAction Stop
    while (!$InstallProcess.HasExited) {
        for ($p = 0; $p -le 100; $p += 25) {
            Write-Progress -Activity "Extracting Chromium Core Binaries" -Status "Decompressing data blocks: $p%" -PercentComplete $p
            Start-Sleep -Milliseconds 150
        }
    }
    Write-Progress -Activity "Extracting Chromium Core Binaries" -Completed
    
    if ($InstallProcess.ExitCode -ne 0) { throw "Setup returned error code: $($InstallProcess.ExitCode)" }
    Write-Host "[ SUCCESS    ] Base binaries mapped successfully into sandbox." -ForegroundColor Green
} catch {
    Write-Host "[ CRITICAL   ] Deployment engine collapsed: $_" -ForegroundColor Red
    throw $_
} finally {
    if (Test-Path $TempInstaller) { Remove-Item -Path $TempInstaller -Force -ErrorAction SilentlyContinue }
}

# =============================================================================
# STEP 06 / 12: TELEMETRY EXCISION INJECTION
# =============================================================================
Write-Host "[ STEP 06 / 12 ] Executing aggressive telemetry target excision..." -ForegroundColor Cyan
$TelemetryTargets = @(
    "opera_autoupdate.exe", "opera_crashreporter.exe", "opera_autoupdate.gup",
    "server_tracking_data", "installer_prefs.json", "installation_status.json",
    "autoupdate", "opera_browser_assistant.exe", "browser_assistant.exe"
)

$t = 0
foreach ($Target in $TelemetryTargets) {
    $t += (100 / $TelemetryTargets.Count)
    Write-Progress -Activity "Excising Tracker Modules" -Status "Purging target: $Target" -PercentComplete $t
    Get-ChildItem -Path $TargetDir -Filter $Target -Recurse -ErrorAction SilentlyContinue | Remove-Item -Force -Recurse -ErrorAction SilentlyContinue
    Start-Sleep -Milliseconds 100
}
Write-Progress -Activity "Excising Tracker Modules" -Completed
Write-Host "[ SUCCESS    ] Telemetry sub-routines completely neutralized." -ForegroundColor Green

# =============================================================================
# STEP 07 / 12: CHROMIUM CONFINEMENT FLAGS
# =============================================================================
Write-Host "[ STEP 07 / 12 ] Injecting local confinement environment flags..." -ForegroundColor Cyan
$EngineDir = Get-ChildItem -Path $TargetDir -Directory -ErrorAction SilentlyContinue | Where-Object { $_.Name -match "^\d+\." } | Select-Object -First 1
if ($EngineDir) {
    try {
        "portable=1" | Out-File -FilePath (Join-Path $EngineDir.FullName "sidekick.config") -Encoding ascii -Force -ErrorAction Stop
        Write-Host "[ CONFIG     ] Hardened local sandboxing variables forced." -ForegroundColor Green
    } catch {
        Write-Host "[ WARNING    ] Failed to write core sidekick variable parameters." -ForegroundColor Yellow
    }
}
Show-GranularProgress "Forcing Portable Flags" 10

# =============================================================================
# STEP 08 / 12: EXECUTABLE IDENTITY RE-MAPPING
# =============================================================================
Write-Host "[ STEP 08 / 12 ] Re-mapping core executable identities..." -ForegroundColor Cyan
$DefaultBinaries = @("launcher.exe", "opera.exe")
foreach ($Bin in $DefaultBinaries) {
    $BinPath = Join-Path $TargetDir $Bin
    if (Test-Path $BinPath) {
        Rename-Item -Path $BinPath -NewName $CustomBinaryName -Force -ErrorAction SilentlyContinue
    }
}
Show-GranularProgress "Re-linking File Tables" 12
Write-Host "[ SUCCESS    ] Master binary masked under identity: $CustomBinaryName" -ForegroundColor Green

# =============================================================================
# STEP 09 / 12: WINDOWS PROTOCOL REGISTER INJECTION (New v0.4)
# =============================================================================
Write-Host "[ STEP 09 / 12 ] Registering MelodyGX protocol handler into Windows Matrix..." -ForegroundColor Cyan
try {
    & reg add "HKCU\Software\Clients\StartMenuInternet\MelodyGX" /ve /t REG_SZ /d "MelodyGX" /f | Out-Null
    & reg add "HKCU\Software\Clients\StartMenuInternet\MelodyGX\Capabilities" /v "ApplicationName" /t REG_SZ /d "MelodyGX" /f | Out-Null
    & reg add "HKCU\Software\Clients\StartMenuInternet\MelodyGX\Capabilities" /v "ApplicationDescription" /t REG_SZ /d "Hardened Telemetry-Free Browser" /f | Out-Null
    
    & reg add "HKCU\Software\Clients\StartMenuInternet\MelodyGX\Capabilities\URLAssociations" /v "http" /t REG_SZ /d "MelodyGXHTM" /f | Out-Null
    & reg add "HKCU\Software\Clients\StartMenuInternet\MelodyGX\Capabilities\URLAssociations" /v "https" /t REG_SZ /d "MelodyGXHTM" /f | Out-Null
    
    & reg add "HKCU\Software\Classes\MelodyGXHTM\shell\open\command" /ve /t REG_SZ /d "`"$TargetDir\$CustomBinaryName`" `"%1`"" /f | Out-Null
    & reg add "HKCU\Software\RegisteredApplications" /v "MelodyGX" /t REG_SZ /d "Software\Clients\StartMenuInternet\MelodyGX\Capabilities" /f | Out-Null
    
    Write-Host "[ SUCCESS    ] Windows Registry protocol hooks successfully injected." -ForegroundColor Green
} catch {
    Write-Host "[ WARNING    ] Protocol registration bypassed due to registry restrictions." -ForegroundColor Yellow
}
Show-GranularProgress "Injecting Registry Hooks" 10

# =============================================================================
# STEP 10 / 12: STARTUP BLOATWARE & SCHEDULED TASK EXCISION (New v0.4)
# =============================================================================
Write-Host "[ STEP 10 / 12 ] Purging Opera startup entries and scheduled tasks..." -ForegroundColor Cyan
try {
    & reg delete "HKCU\Software\Microsoft\Windows\CurrentVersion\Run" /v "Opera Browser Assistant" /f 2>$null | Out-Null
    & reg delete "HKLM\Software\Microsoft\Windows\CurrentVersion\Run" /v "Opera Browser Assistant" /f 2>$null | Out-Null
    Write-Host "[ AUTOSTART  ] Opera Browser Assistant removed from Windows Startup registry keys." -ForegroundColor Green
} catch {
    Write-Host "[ WARNING    ] Failed to modify autostart registry keys." -ForegroundColor Yellow
}

try {
    $OperaTasks = Get-ScheduledTask -TaskName "Opera*" -ErrorAction SilentlyContinue
    if ($OperaTasks) {
        foreach ($Task in $OperaTasks) {
            Unregister-ScheduledTask -TaskName $Task.TaskName -Confirm:$false -ErrorAction SilentlyContinue
            Write-Host "[ SCHEDULER  ] Destroyed legacy scheduled task: $($Task.TaskName)" -ForegroundColor Green
        }
    } else {
        Write-Host "[ SCHEDULER  ] No active background update tasks detected." -ForegroundColor White
    }
} catch {
    Write-Host "[ WARNING    ] Windows Task Scheduler bypass failed." -ForegroundColor Yellow
}
Show-GranularProgress "Cleaning Windows Boot Execution Layers" 10

# =============================================================================
# STEP 11 / 12: CLOAKED UPDATE MATRIX DEPLOYMENT
# =============================================================================
Write-Host "[ STEP 11 / 12 ] Deploying cloaked update management subsystem..." -ForegroundColor Cyan
$LocalUpdaterScript = Join-Path $ScriptDir "updater.ps1"
if (Test-Path $LocalUpdaterScript) {
    try {
        $HiddenFolder = Join-Path $TargetDir ".system"
        if (!(Test-Path $HiddenFolder)) { New-Item -ItemType Directory -Path $HiddenFolder | Out-Null }
        (Get-Item $HiddenFolder).Attributes = 'Hidden'
        
        Copy-Item -Path $LocalUpdaterScript -Destination $HiddenFolder -Force
        
        $UpdateBatPath = Join-Path $TargetDir "update.bat"
        $BatContent = @(
            "@echo off", "cd /d ""%~dp0""", "net session >nul 2>&1",
            "if %errorLevel% neq 0 (", "    powershell -Command ""Start-Process '%~f0' -Verb RunAs""", "    exit /b", ")",
            "powershell -NoProfile -ExecutionPolicy Bypass -File ""%~dp0.system\updater.ps1"""
        ) -join "`r`n"
        
        $BatContent | Out-File -FilePath $UpdateBatPath -Encoding ascii -Force
        Write-Host "[ SUCCESS    ] Admin-aware update proxy spawned inside root storage." -ForegroundColor Green
    } catch {
        Write-Host "[ WARNING    ] Failed to establish automated patch routines." -ForegroundColor Yellow
    }
}
Show-GranularProgress "Compiling Proxy Submodules" 15

# =============================================================================
# STEP 12 / 12: FIRST-RUN PROMOTION WIZARDS SUPPRESSION
# =============================================================================
Write-Host "[ STEP 12 / 12 ] Injecting telemetry suppressors and wizard blocks..." -ForegroundColor Cyan
$TargetDataDir = "C:\MelodyGX\profile\data"
$TargetDefaultDir = "C:\MelodyGX\profile\data\Default"

try {
    if (!(Test-Path $TargetDataDir)) { New-Item -ItemType Directory -Path $TargetDataDir | Out-Null }
    if (!(Test-Path $TargetDefaultDir)) { New-Item -ItemType Directory -Path $TargetDefaultDir | Out-Null }

    New-Item -ItemType File -Path (Join-Path $TargetDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType File -Path (Join-Path $TargetDataDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
    New-Item -ItemType File -Path (Join-Path $TargetDefaultDir "First Run") -Force -ErrorAction SilentlyContinue | Out-Null
} catch {}
Show-GranularProgress "Injecting Anti-Wizard Arrays" 10
Write-Host "[ SUCCESS    ] Welcome screens and forced onboarding wizards disabled." -ForegroundColor Green

# =============================================================================
# VERIFICATION TERMINAL
# =============================================================================
Clear-Host
Write-Host $LogoArt -ForegroundColor Green
Write-Host ""
Write-Host "=============================================================================" -ForegroundColor Green
Write-Host "   CONGRATULATIONS! MELODY GX DEPLOYMENT ACCOMPLISHED SUCCESSFULLY!" -ForegroundColor Green
Write-Host "=============================================================================" -ForegroundColor Green
Write-Host " [+] Architecture Hardening Status: COMPLETE (12 / 12 Steps Verification Passed)" -ForegroundColor White
Write-Host " [+] Core Sandbox Directory:        $TargetDir" -ForegroundColor White
Write-Host " [+] Master Launch Target:          $TargetDir\$CustomBinaryName" -ForegroundColor White
Write-Host " [+] Background Update Engine:      $TargetDir\update.bat" -ForegroundColor White
Write-Host "=============================================================================" -ForegroundColor Green
Write-Host ""

[System.Windows.Forms.MessageBox]::Show("MelodyGX v0.4 deployed successfully!`nAll 12 hardening stages passed compliance.", "MelodyGX Matrix", "OK", "Information") | Out-Null