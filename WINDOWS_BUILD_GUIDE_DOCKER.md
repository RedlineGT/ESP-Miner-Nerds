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
1. Navigate to → `Board Configuration`
2. Set display type → `3.5" LCD (480×320 RGB565)`
3. Set device → `NERDOCTAXEGAMMA` (or your board)
4. Exit menu → Press `Q`, then confirm to save

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
