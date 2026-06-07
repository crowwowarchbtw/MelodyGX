# MelodyGX: Automated Browser Hardening and Deployment Framework

MelodyGX is an automated deployment framework designed to provision a hardened, telemetry-free, and strictly isolated instance of a Chromium-based gaming browser environment. The core objective of this project is the complete elimination of corporate tracking vectors, background resource overhead, and unnecessary system dependencies, delivering a highly optimized runtime configuration suitable for low-latency execution environments.

Unlike standard application repacks, this framework utilizes a modular automation architecture. It interacts directly with upstream distribution channels to dynamically assemble the target environment on the client machine. This methodology guarantees binary integrity validation while allowing deep structural modifications.

---

## Architectural Principles and Core Functionality

### 1. Telemetry Interdiction and Daemon Decoupling
The deployment sequence performs a targeted mitigation of proprietary tracking mechanisms. The framework identifies and permanently decouples unmanaged background update loops and automated crash reporting daemons, including:
* `opera_autoupdate.exe`
* `opera_crashreporter.exe`
* `opera_autoupdate.gup`

This approach completely prevents unauthorized socket connections, outbound analytical payloads, and unmanaged background disk write cycles on the host storage sub-system.

### 2. Sandboxed Filesystem Isolation
Through the structured injection of an isolated runtime configuration framework (`sidekick.config`), the deployment forces the browser subsystems into a strict Portable Mode. All user profiles, state directories, caches, and session parameters are constrained within the root execution directory (`C:\MelodyGX\profile\`). This architecture eliminates persistent data leakage into `%APPDATA%`, `%LOCALAPPDATA%`, or the Windows Registry hierarchy.

### 3. Resource Overhead Optimization
By replacing default configuration matrices with a tailored, ad-free `Preferences` state layer, the application engine mitigates rendering pipeline stalls and auxiliary thread allocation. The removal of redundant advertising trackers, pre-cached promotional components, and analytical hooks directly translates to reduced RAM consumption and stabilized frame times in hardware-bound scenarios.

---

## Deployment and Execution Instructions

### Prerequisites
* Operating System: Windows 10 / Windows 11 (Architecture: x64)
* Execution Subsystem: PowerShell 5.1 or higher (integrated natively within the OS)

### Installation Sequence
1. Download the latest source archive by navigating to the top-right section of the repository, clicking the **Code** dropdown menu, and selecting **Download ZIP**.
2. Extract the contents of the archive to a local directory ensuring proper read/write permissions are available.
3. Open the root folder named `MelodyGX-Installer`.
4. Execute the initialization vector by double-clicking the **`run.bat`** file.

> **System Execution Note:** The `run.bat` vector explicitly bypasses restrictive default Windows execution policies using the `-ExecutionPolicy Bypass` flag. This facilitates an isolated runtime state for the PowerShell installer without altering the global security posture of the host operating system.

---

## Licensing and Liability Disclaimer

This framework is open-source software open for public distribution, modification, and integration under the terms of the **MIT License**. For extensive legal terminology, refer directly to the `LICENSE` document located within the root directory of this repository.
