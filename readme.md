Disclaimer: Use this at your own risk. This unofficial firmware ("Software") is provided "as is" without warranty, express or implied. Users assume all risks, including device failure, data loss, or bricking. The developers are not liable for damages arising from the use of this software, which is not endorsed by the original manufacturer. 

This firmware is built from the latest "develop" branch hence is considered experimental with changes and features being tested for squashing bugs. I am not the original developer, I just sync with their repository and apply my own changes to make it compatible with the 3.5 inch Yysluping screen that many folks are getting from Aliexpress. Yysluping provides the firmware on their github but they have not published their source code and on top of that their interface is horrendous, along with unclear information about their firmware version and labeling.

This firmware can be compiled for any of the Nerd* miners, you just have to change "Target Board" under "Miner Configuration" when you run "idf.py menuconfig"


# Project Statistics - April 18, 2026

**Generated:** 2026-04-18T00:00:00Z

## Overall Repository Statistics

| Metric | Count |
|--------|-------|
| **Total Commits** | 10 |
| **Files Changed** | 1,034 |
| **Lines Added** | 908,746 |
| **Lines Removed** | 490 |
| **Total Changes** | 909,236 |

## Commit History

1. **8198bd4** - Reorganize Kconfig.projbuild menu order: move CSV Integration to end
   - Modified: 7 files
   - Created: 6 files
   - 13 files total changed

2. **be4f5d4** - Revise readme for firmware configuration clarity
3. **518bd9f** - Add disclaimer and update configuration example
4. **cada4a7** - Add Docker build instructions for ESP-Miner
5. **514e618** - Document building ESP-Miner on Windows
6. **1f6f85f** - Update Official_Bleeding_Edge_3.5Screen with April 17 customizations
7. **7ee73cb** - Update rebase_upstream.sh with helper branch sync command
8. **510cd13** - Revise readme for 3.5" display support and updates
9. **dc3d203** - Add upstream sync automation scripts and documentation
10. **81f2408** - Initial commit: ESP-Miner with NerdOctaxeGamma board + 3.5 inch display adaptation

## Key Changes This Session

- ✅ Reorganized Kconfig.projbuild menu structure
- ✅ Moved CSV Config Integration menu to end of file
- ✅ Kept Miner Configuration with Target Board at top for better UX
- ✅ Updated rebase_upstream.sh with menu positioning guidance
- ✅ All changes synced to `Official_Bleeding_Edge_3.5Screen` branch

## Branch Information

- **Branch:** Official_Bleeding_Edge_3.5Screen
- **Remote:** origin (https://github.com/RedlineGT/ESP-Miner-Nerds.git)
- **Status:** Up-to-date and synced

---

*This statistics file is auto-generated and can be updated with each session's work.*




Changes Made to https://github.com/shufps/ESP-Miner-NerdQAxePlus/tree/develop (ESP-Miner-NerdQAxePlus)

ESP-Miner-Nerds (originally forked from ESP-Miner-NerdQAxePlus) has been modified to integrate 3.5" display support and upstream sync automation. Below is a comprehensive list of all changes applied, based on the integration from https://github.com/luclucs/qaxeplus2-large-screen (qaxeplus2-large-screen) and subsequent development tasks.


1. Display and UI Adaptations (qaxeplus2-large-screen)

displayDriver.h:
Updated LCD resolution from 320x170 to 480x320.
Added scaling defines: TDISPLAYS3_SCALE_FACTOR=3.0f, TDISPLAYS3_ZOOM_LEVEL calculation.
Modified panel mirroring and gap settings for the larger display.

displayDriver.cpp:
Adjusted panel configuration for the new resolution.

ui.cpp:
Added scaling functions: scale_x(), scale_y(), zoom_img() for coordinate adjustments.
Updated UI elements to use scaled coordinates.

ui.h:
Added declaration for ui_font_DigitalNumbers40.
main/displays/images/themes/NerdQaxePlus2/:
Replaced all PNG assets with 480x320 resized versions (e.g., backgrounds, icons, fonts).

CMakeLists.txt:
Added board selection preprocessor defines (e.g., CONFIG_BOARD_NERDOCTAXEGAMMA).
Included font references and board-specific compilation flags.

Kconfig.projbuild:
Added board choice menu with default NERDOCTAXEGAMMA.

tasks.json (Docker build task):
Added BOARD=NERDOCTAXEGAMMA environment variable.


2. Build and Configuration Changes
Configured build for NerdQaxePlus2 board (later switched to NerdOctaxeGamma).
Updated sdkconfig.defaults and sdkconfig.ci for ESP32-S3 compatibility.
Used Docker-based build environment (esp-idf-builder) for reproducible firmware generation.
Firmware builds successfully (~3.1MB binary).


3. Git Repository Setup and Branch Management
Initialized Git repository in the workspace.
Set remote origin to https://github.com/RedlineGT/ESP-Miner-Nerds.git.
Created branch Official_Bleeding_Edge_3.5Screen with all adaptations.
Committed changes in two main commits:
Initial commit: ESP-Miner with NerdOctaxeGamma board + 3.5" display adaptation.
Latest commit: Added upstream sync automation scripts and documentation.
Force-pushed the branch to remote, overwriting existing remote branch history.


4. Automation and Documentation Scripts
rebase_upstream.sh (executable script):
Automates Git rebase onto upstream Official_Bleeding_Edge branch.
Includes conflict detection and resolution prompts.

CONFLICT_RESOLUTION.md:
Comprehensive guide for handling merge conflicts during upstream sync.
Covers strategies for display-related files, build configs, and asset updates.

QUICK_REFERENCE.md:
Cheat sheet for sync workflow, commands, and troubleshooting.
Includes steps for rebasing, pushing, and maintaining adaptations.


5. Other Modifications
Resolved build issues: Added missing BOARD environment variable, manually cloned libsecp256k1 submodule.
Updated repository references: Changed upstream from original to https://github.com/RedlineGT/ESP-Miner-Nerds/tree/Official_Bleeding_Edge.
No changes to core mining logic, stratum protocols, or hardware drivers beyond display/UI scaling.


Key Outcomes
Display Support: Firmware now supports 3.5" screens with proper scaling (3x factor) for NerdQaxePlus2/NerdOctaxeGamma boards.
Maintainability: Automation scripts enable easy syncing with upstream updates while preserving customizations.

Repository State: Branch Official_Bleeding_Edge_3.5Screen is live on GitHub with all changes committed and pushed.
All changes are focused on display adaptation and maintenance automation, with no alterations to the core ESP-Miner functionality.



# Building ESP-Miner on Windows (Without Docker)

A step-by-step guide to build the ESP-Miner firmware on Windows using ESP-IDF v6.1.

## Prerequisites

### System Requirements
- Windows 10 or later
- 8GB+ RAM recommended
- 5GB+ free disk space

### Required Software

| Software | Download | Notes |
|----------|----------|-------|
| Git for Windows | https://git-scm.com/download/win | Version control |
| Python 3.11+ | https://www.python.org/downloads/ | **Check "Add to PATH"** |
| Visual Studio Build Tools | https://visualstudio.microsoft.com/downloads/ | Install "Desktop development with C++" |

---

## Installation Steps

### Step 1: Prepare Your Environment

#### 1.1 Verify Python Installation
```cmd
python --version
```
Expected output: `Python 3.11.x` or higher

#### 1.2 Create Workspace Directory
```cmd
mkdir C:\esp
cd C:\esp
```

---

### Step 2: Install ESP-IDF v6.1

#### 2.1 Clone ESP-IDF Repository
```cmd
git clone --branch v6.1 --recursive https://github.com/espressif/esp-idf.git
cd esp-idf
```

#### 2.2 Run Installation Script
```cmd
install.bat
```
⏱️ *This takes 5-10 minutes and installs all required tools*

#### 2.3 Activate ESP-IDF Environment
```cmd
export.bat
```
⚠️ **Important**: Run this command in every new Command Prompt session before building

---

### Step 3: Download ESP-Miner Source Code

#### 3.1 Clone Repository
```cmd
cd C:\esp
git clone https://github.com/RedlineGT/ESP-Miner-Nerds.git
cd ESP-Miner-Nerds
```

#### 3.2 Checkout 3.5" Display Branch
```cmd
git checkout Official_Bleeding_Edge_3.5Screen
```

---

### Step 4: Configure Project

#### 4.1 Set Target Chip
```cmd
idf.py set-target esp32s3
```

#### 4.2 Open Configuration Menu
```cmd
idf.py menuconfig
```

**Configuration steps in menu:**
**Configuration steps in menu:**
1. Navigate to → `Miner Configuration`
2. Set device → `NERDOCTAXEGAMMA` (or your board, example NERDQUAXEPLUS2 for the NerdQuaxe++)
3. Exit menu → Press `Q`, then confirm to save


---

### Step 5: Build Firmware

#### 5.1 Clean Build (First Time Only)
```cmd
idf.py fullclean
```

#### 5.2 Build Project
```cmd
idf.py build
```

✅ **Expected output:**
```
App "esp-miner" version: BleedingEdgeExperimental-20260417
Project build complete.
```

Build artifacts are saved in the `build/` directory.

---

### Step 6: Flash to ESP32-S3

#### 6.1 Connect Device
- Plug USB cable into ESP32-S3 board

#### 6.2 Find COM Port
1. Open **Device Manager** (`Win + X` → Device Manager)
2. Expand **Ports (COM & LPT)**
3. Look for `USB Serial Device (COM#)` - note the number

#### 6.3 Flash Firmware
```cmd
idf.py -p COM3 flash
```
*Replace `COM3` with your actual port number*

#### 6.4 Monitor Device (Optional)
```cmd
idf.py -p COM3 monitor
```
Press `Ctrl+]` to exit monitor

---

## Custom Configuration (Optional)

### Deploy with WiFi/Pool Settings

#### Step 1: Edit Configuration
Edit `config.cvs` with your settings:
```
WiFi SSID: YourNetwork
WiFi Password: YourPassword
Pool Address: solo.ckpool.org:3333
Wallet Address: your_btc_address
Hostname: esp-miner
```

#### Step 2: Rebuild and Flash
```cmd
idf.py build
idf.py -p COM3 flash
```

---

## Quick Build Reference

<details>
<summary><b>Click to expand: Quick Commands</b></summary>

```cmd
# Activate ESP-IDF (required every session)
C:\esp\esp-idf\export.bat

# Navigate to project
cd C:\esp\ESP-Miner-Nerds

# Clean rebuild
idf.py fullclean && idf.py build

# Flash to device
idf.py -p COM3 flash

# Monitor output
idf.py -p COM3 monitor

# Check build size
idf.py size
```

</details>

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `idf.py: command not found` | Run `C:\esp\esp-idf\export.bat` in current Command Prompt |
| `Python not found` | Restart Command Prompt after installing Python, or verify PATH in System Variables |
| `cmake: command not found` | Install Visual Studio Build Tools with CMake included |
| `Access Denied` | Run Command Prompt as Administrator |
| Build fails with errors | Run `idf.py fullclean` then rebuild |
| USB device not detected | Install CH340 drivers (search: "CH340 driver Windows") |
| `Port COM3 not found` | Verify device is plugged in; check Device Manager |

---

## Project Structure

```
ESP-Miner-Nerds/
├── main/                          # Main application source
├── components/                    # ESP-IDF components
├── build/                         # Build output (generated)
├── CMakeLists.txt                 # Build configuration
├── sdkconfig                      # ESP-IDF config (generated)
├── config.cvs                     # Device configuration
├── flash_custom.sh                # Flash script with config
└── README.md                      # Project documentation
```

---

## Resources

- **ESP-IDF Documentation**: https://docs.espressif.com/projects/esp-idf/
- **ESP32-S3 Datasheet**: https://www.espressif.com/en/products/socs/esp32-s3/
- **Project Repository**: https://github.com/RedlineGT/ESP-Miner-Nerds
- **Issues/Discussions**: https://github.com/RedlineGT/ESP-Miner-Nerds/issues

---

## Build Specifications

| Parameter | Value |
|-----------|-------|
| **Target Chip** | ESP32-S3 QFN56 |
| **RAM** | 8MB PSRAM + 520KB SRAM |
| **Clock Speed** | 240 MHz |
| **Display** | 3.5" LCD (480×320 RGB565) |
| **NVS Config** | 0x9000 (12KB) |
| **ESP-IDF Version** | v6.1 |
| **Firmware Version** | BleedingEdgeExperimental-20260417 |

---

## Contributing

Found an issue? Please report it on [GitHub Issues](https://github.com/RedlineGT/ESP-Miner-Nerds/issues).

---

**Last Updated**: April 18, 2026


# Building ESP-Miner on Windows with Docker

A step-by-step guide to build the ESP-Miner firmware on Windows using Docker and ESP-IDF v6.1.

## Prerequisites

### System Requirements
- Windows 10 or later (Pro, Enterprise, or Home with WSL2)
- 8GB+ RAM recommended (Docker needs memory)
- 10GB+ free disk space
- Administrator access

### Required Software

| Software | Download | Notes |
|----------|----------|-------|
| Docker Desktop for Windows | https://www.docker.com/products/docker-desktop | Includes WSL2 setup |
| Git for Windows | https://git-scm.com/download/win | Version control |
| Optional: Visual Studio Code | https://code.visualstudio.com/ | Recommended editor |

---

## Installation Steps

### Step 1: Install Docker Desktop

#### 1.1 Download and Install
1. Visit https://www.docker.com/products/docker-desktop
2. Click "Download for Windows"
3. Run the installer
4. Follow the setup wizard (default options are fine)

#### 1.2 Enable WSL2 (Windows Subsystem for Linux 2)
Docker Desktop will prompt to install WSL2. **Accept the installation** - this is required.

#### 1.3 Restart Computer
Docker Desktop will request a restart. **Restart Windows** to complete setup.

#### 1.4 Verify Installation
Open PowerShell or Command Prompt and run:
```cmd
docker --version
```
Expected output: `Docker version 25.x.x` or higher

---

### Step 2: Clone ESP-Miner Repository

#### 2.1 Create Workspace Directory
```cmd
mkdir C:\esp-workspace
cd C:\esp-workspace
```

#### 2.2 Clone Repository
```cmd
git clone https://github.com/RedlineGT/ESP-Miner-Nerds.git
cd ESP-Miner-Nerds
```

#### 2.3 Checkout 3.5" Display Branch
```cmd
git checkout Official_Bleeding_Edge_3.5Screen
```

---

### Step 3: Build Docker Image

#### 3.1 Navigate to Docker Directory
```cmd
cd docker
dir
```

#### 3.2 Build ESP-IDF Docker Image
```cmd
docker build -t esp-idf-builder:latest .
```

⏱️ *First build takes 5-10 minutes (downloads ~2GB base image + tools)*

**Expected output:**
```
Successfully built [image-id]
Successfully tagged esp-idf-builder:latest
```

---

### Step 4: Configure Project

#### 4.1 Build Inside Docker Container
```cmd
cd C:\esp-workspace\ESP-Miner-Nerds
docker run --rm -it -v "%cd%":/project esp-idf-builder /bin/bash
```

*You're now inside the Docker container shell*

#### 4.2 Set Target Chip
```bash
idf.py set-target esp32s3
```

#### 4.3 Open Configuration Menu
```bash
idf.py menuconfig
```

**Configuration steps in menu:**
1. Navigate to → `Miner Configuration`
2. Set device → `NERDOCTAXEGAMMA` (or your board)
3. Exit menu → Press `Q`, then confirm to save

#### 4.4 Exit Container
```bash
exit
```

---

### Step 5: Build Firmware in Docker

#### 5.1 Clean Build (First Time Only)
```cmd
docker run --rm -it -v "%cd%":/project esp-idf-builder idf.py fullclean
```

#### 5.2 Build Project
```cmd
docker run --rm -it -v "%cd%":/project esp-idf-builder idf.py build
```

✅ **Expected output:**
```
App "esp-miner" version: BleedingEdgeExperimental-20260417
Project build complete.
```

Build artifacts are saved in the `build/` directory on your Windows machine.

---

### Step 6: Flash to ESP32-S3

#### 6.1 Connect Device
- Plug USB cable into ESP32-S3 board
- Windows will install USB drivers automatically

#### 6.2 Find COM Port
1. Open **Device Manager** (`Win + X` → Device Manager)
2. Expand **Ports (COM & LPT)**
3. Look for `USB Serial Device (COM#)` - note the number

#### 6.3 Identify Docker Container Serial Port

Docker on Windows can access COM ports via special names. Run:
```cmd
docker run --rm -it -v "%cd%":/project esp-idf-builder bash -c "ls -la /dev/ttyUSB* /dev/ttyACM* 2>/dev/null || echo 'No USB devices found - ensure device is connected'"
```

#### 6.4 Flash Firmware
```cmd
docker run --rm -it -v "%cd%":/project --device=/dev/ttyUSB0 esp-idf-builder idf.py -p /dev/ttyUSB0 -b 921600 flash
```

*Replace `/dev/ttyUSB0` with your device path if different*

#### 6.5 Monitor Device (Optional)
```cmd
docker run --rm -it -v "%cd%":/project --device=/dev/ttyUSB0 esp-idf-builder idf.py -p /dev/ttyUSB0 monitor
```

Press `Ctrl+]` to exit monitor

---

## Custom Configuration (Optional)

### Deploy with WiFi/Pool Settings

#### Step 1: Edit Configuration
Edit `config.cvs` with your settings:
```
WiFi SSID: YourNetwork
WiFi Password: YourPassword
Pool Address: solo.ckpool.org:3333
Wallet Address: your_btc_address
Hostname: esp-miner
```

#### Step 2: Rebuild and Flash in Docker
```cmd
docker run --rm -it -v "%cd%":/project esp-idf-builder idf.py build
docker run --rm -it -v "%cd%":/project --device=/dev/ttyUSB0 esp-idf-builder idf.py -p /dev/ttyUSB0 flash
```

---

## Quick Build Reference

<details>
<summary><b>Click to expand: Quick Docker Commands</b></summary>

```cmd
# Navigate to project
cd C:\esp-workspace\ESP-Miner-Nerds

# Open Docker shell (interactive)
docker run --rm -it -v "%cd%":/project esp-idf-builder /bin/bash

# Clean rebuild
docker run --rm -it -v "%cd%":/project esp-idf-builder idf.py fullclean && idf.py build

# Build only
docker run --rm -it -v "%cd%":/project esp-idf-builder idf.py build

# Flash to device
docker run --rm -it -v "%cd%":/project --device=/dev/ttyUSB0 esp-idf-builder idf.py -p /dev/ttyUSB0 flash

# Monitor output
docker run --rm -it -v "%cd%":/project --device=/dev/ttyUSB0 esp-idf-builder idf.py -p /dev/ttyUSB0 monitor

# Check build size
docker run --rm -it -v "%cd%":/project esp-idf-builder idf.py size

# List Docker images
docker images

# Remove Docker image (cleanup)
docker rmi esp-idf-builder:latest
```

</details>

---

## Understanding Docker Volume Mounting

Docker commands use `-v "%cd%":/project` which:
- Maps your current Windows directory to `/project` inside the container
- Allows Docker to access your source code
- Saves build artifacts back to Windows

**Before running commands, ensure you're in the project directory:**
```cmd
cd C:\esp-workspace\ESP-Miner-Nerds
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `docker: command not found` | Docker Desktop not installed or not in PATH; restart Command Prompt after installing |
| `Cannot connect to Docker daemon` | Start Docker Desktop; it must be running before Docker commands |
| Build fails inside container | Run `docker run --rm -it -v "%cd%":/project esp-idf-builder idf.py fullclean` to clean |
| USB device not accessible in Docker | Add `--device=/dev/ttyUSB0` flag to docker run command |
| `ttyUSB0: No such device` | Device not connected or using different port; check Device Manager for actual port |
| Docker image too large | Run `docker image prune` to clean up unused images |
| Slow build performance | Increase Docker resource limits in Docker Desktop settings (Memory, CPU) |
| Windows Defender blocking Docker | Add Docker to Windows Defender Exclusions or disable real-time scanning |

---

## Advanced: Using Provided Docker Script

The repository includes a build script:

```cmd
cd docker
bash build_docker.sh
```

This script handles:
- Building the Docker image
- Mounting volumes correctly
- Setting environment variables
- Cross-platform path handling

---

## Project Structure

```
ESP-Miner-Nerds/
├── docker/
│   ├── Dockerfile                 # Docker image definition
│   ├── build_docker.sh            # Build automation script
│   ├── compile.sh                 # Compilation script
│   └── flash.sh                   # Flash automation script
├── main/                          # Main application source
├── components/                    # ESP-IDF components
├── build/                         # Build output (generated)
├── CMakeLists.txt                 # Build configuration
├── sdkconfig                      # ESP-IDF config (generated)
├── config.cvs                     # Device configuration
└── README.md                      # Project documentation
```

---

## Docker Benefits vs Native Build

| Aspect | Docker | Native |
|--------|--------|--------|
| **Setup Time** | 15 minutes | 30+ minutes |
| **Disk Space** | ~3GB | ~5GB |
| **Dependency Management** | Automatic | Manual |
| **Consistency** | Guaranteed | OS-dependent |
| **Performance** | Good (WSL2) | Best |
| **Portability** | Any OS | Windows only |

---

## Resources

- **Docker Documentation**: https://docs.docker.com/
- **ESP-IDF Documentation**: https://docs.espressif.com/projects/esp-idf/
- **ESP32-S3 Datasheet**: https://www.espressif.com/en/products/socs/esp32-s3/
- **Project Repository**: https://github.com/RedlineGT/ESP-Miner-Nerds
- **WSL2 Setup Guide**: https://learn.microsoft.com/en-us/windows/wsl/

---

## Build Specifications

| Parameter | Value |
|-----------|-------|
| **Target Chip** | ESP32-S3 QFN56 |
| **RAM** | 8MB PSRAM + 520KB SRAM |
| **Clock Speed** | 240 MHz |
| **Display** | 3.5" LCD (480×320 RGB565) |
| **NVS Config** | 0x9000 (12KB) |
| **ESP-IDF Version** | v6.1 |
| **Firmware Version** | BleedingEdgeExperimental-20260417 |
| **Build Environment** | Docker (containerized) |

---

## Contributing

Found an issue? Please report it on [GitHub Issues](https://github.com/RedlineGT/ESP-Miner-Nerds/issues).

---

**Last Updated**: April 18, 2026

