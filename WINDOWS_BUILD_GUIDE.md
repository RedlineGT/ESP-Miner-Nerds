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
1. Navigate to → `Board Configuration`
2. Set display type → `3.5" LCD (480×320 RGB565)`
3. Set device → `NERDOCTAXEGAMMA` (or your board)
4. Exit menu → Press `Q`, then confirm to save

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
