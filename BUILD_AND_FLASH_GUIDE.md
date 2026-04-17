# Complete Guide: Building and Flashing ESP-Miner Firmware

## Prerequisites

Before starting, ensure you have:
- Git installed on your system
- Visual Studio Code installed
- Docker installed (for containerized builds) - **Optional but recommended**
- USB cable to connect ESP32-S3 device
- ESP32-S3 device with USB support

---

## Step 1: Clone the Repository from GitHub

### Option A: Using VS Code Git Integration

1. Open **Visual Studio Code**
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac) to open the Command Palette
3. Type `Git: Clone` and select it
4. Enter the repository URL:
   ```
   https://github.com/RedlineGT/ESP-Miner-Nerds
   ```
4. VS Code will prompt for the branch. Enter: `Official_Bleeding_Edge_3.5Screen`
5. Choose a folder where you want to clone the repository
6. VS Code will ask if you want to open the cloned repository - click **Open**

### Option B: Using Terminal

**If you already have the project cloned:**
```bash
cd /path/to/your/project
code .
```
Skip to Step 2.

**If you need to clone the repository:**

1. Open a terminal/command prompt
2. Navigate to your desired directory:
   ```bash
   cd ~/projects  # or your preferred location
   ```
3. Clone the repository with the specific branch:
   ```bash
   git clone -b Official_Bleeding_Edge_3.5Screen https://github.com/RedlineGT/ESP-Miner-Nerds.git
   ```
   This creates a folder named `ESP-Miner-Nerds` containing the project
4. Open the cloned folder in VS Code:
   ```bash
   cd ESP-Miner-Nerds
   code .
   ```

---

## Step 2: Install ESP-IDF Extension in VS Code

1. In VS Code, go to **Extensions** (Ctrl+Shift+X / Cmd+Shift+X)
2. Search for `ESP-IDF`
3. Install the **ESP-IDF** extension by Espressif Systems
4. Wait for installation to complete

---

## Step 3: Configure ESP-IDF Environment

### Using the ESP-IDF Setup Wizard (Recommended)

1. Press `Ctrl+Shift+P` to open the Command Palette
2. Search for `ESP-IDF: Configure ESP-IDF Extension`
3. Select **Advanced Install** or **Express Install**
   - **Express Install**: Automatically downloads and configures ESP-IDF
   - **Advanced Install**: Manual configuration (only if you already have ESP-IDF installed)
4. Choose the installation path (default is fine)
5. Wait for ESP-IDF to download and install (~5-10 minutes depending on internet)
6. Select the target chip: **ESP32-S3**

Once complete, you should see: `ESP-IDF tools have been successfully installed`

---

## Step 4: Verify Project Structure

The cloned repository should contain:

```
ESP-Miner-Nerds/
├── CMakeLists.txt          # Build configuration
├── config.cvs              # Device configuration (WiFi, Pool, etc.)
├── main/                   # Main application source code
├── components/             # Library components
├── build/                  # Build output (auto-generated)
├── partitions.csv          # Flash partition table
├── flash_custom.sh         # Custom flash script (includes config)
└── README.md
```

---

## Step 5: Configure Device Settings (Optional but Recommended)

Before building, you may want to configure device-specific settings:

1. Open `config.cvs` in VS Code
2. Edit the following parameters:

```csv
hostname,data,string,NerdOctaxeOne              # Device name
wifissid,data,string,YOUR_WIFI_SSID             # WiFi network name
wifipass,data,string,YOUR_WIFI_PASSWORD         # WiFi password
stratumurl,data,string,solo.ckpool.org          # Mining pool address
stratumport,data,u16,3333                       # Mining pool port
stratumuser,data,string,YOUR_WALLET.WORKER_NAME # Wallet address
```

3. Save the file (Ctrl+S)

---

## Step 6: Set the Target Device (ESP32-S3)

1. Press `Ctrl+Shift+P` to open the Command Palette
2. Search for `ESP-IDF: Set Espressif device target`
3. Select **ESP32-S3**
4. Confirm the selection

---

## Step 7: Connect Your Device

1. Connect your ESP32-S3 device to your computer via USB cable
2. The device should appear as `/dev/ttyACM0` (Linux/Mac) or `COM*` (Windows)

### Give Docker Permission to Access the Device (If Using Docker)

If you're using Docker to build, grant it permission to access the serial port:

```bash
# Linux only - allows Docker to access /dev/ttyACM0
sudo usermod -aG dialout $USER
sudo chmod 666 /dev/ttyACM0

# You may need to log out and back in for group changes to take effect
```

---

## Step 8: Build the Firmware

### Option A: Using VS Code ESP-IDF Extension (Recommended)

1. Press `Ctrl+Shift+P` to open the Command Palette
2. Search for `ESP-IDF: Build your project`
3. Wait for the build to complete (3-5 minutes first time, faster on subsequent builds)
4. You should see in the output:
   ```
   Project build complete. To flash, run: idf.py flash
   ```

### Option B: Using Terminal Command

1. Open the integrated terminal in VS Code (Ctrl+` or Cmd+`)
2. Run:
   ```bash
   cd /workspaces  # or your project directory
   idf.py build
   ```
3. Wait for completion

### Build Output Verification

After a successful build, you should see:
- `Created NVS binary: ===> /workspaces/config.bin` (contains your WiFi/Pool settings)
- `Project build complete`
- The binary file: `build/esp-miner.bin` (~3.9MB)

---

## Step 9: Flash the Firmware to Device

### Option A: Using Custom Flash Script (Recommended - Includes Device Configuration)

This method flashes all partitions including your device configuration:

```bash
cd /workspaces
./flash_custom.sh
```

**What this does:**
- Writes bootloader (0x0)
- Writes partition table (0x8000)
- **Writes config.bin with WiFi/Pool settings (0x9000)** ← Important!
- Writes main app (0x10000)
- Writes web UI (0x410000)
- Writes OTA data (0xf10000)

### Option B: Using VS Code ESP-IDF Extension

1. Press `Ctrl+Shift+P` to open the Command Palette
2. Search for `ESP-IDF: Select port to use`
3. Choose `/dev/ttyACM0` (or your device port)
4. Press `Ctrl+Shift+P` again
5. Search for `ESP-IDF: Flash your project`
6. Wait for flashing to complete

### Option C: Using Terminal Command

```bash
idf.py -p /dev/ttyACM0 -b 460800 flash
```

**⚠️ Important Note**: The default `idf.py flash` command skips the config partition. For a complete flash with your WiFi and pool settings, use the custom flash script instead.

---

## Step 10: Monitor Device Output (Verify Flash Success)

After flashing, monitor the device output to verify it's working:

### Using VS Code:

1. Press `Ctrl+Shift+P`
2. Search for `ESP-IDF: Monitor your device`
3. Select `/dev/ttyACM0` (or your device port)
4. You should see boot messages and device information

### Using Terminal:

```bash
idf.py -p /dev/ttyACM0 monitor
```

### Expected Output:

```
ESP-Miner v1.0 starting...
WiFi: Connecting to USR8054-2G...
WiFi: Connected
Stratum: Connecting to solo.ckpool.org:3333...
Stratum: Connected
Ready to mine!
```

Exit monitoring: Press `Ctrl+]`

---

## Step 11: Verify Settings on Device

Once the device boots successfully:

1. Check the device's web interface (if available)
2. Verify it connects to the configured WiFi network
3. Verify it connects to the mining pool
4. Check that hostname and wallet address are correct

---

## Troubleshooting

### Build Fails with Errors

**Solution:**
```bash
# Clean build - removes all previous build artifacts
rm -rf build
idf.py build
```

### Device Not Found / Serial Port Issues

**Linux:**
```bash
# Check connected devices
ls -la /dev/ttyACM*

# Give user permission to serial port
sudo usermod -aG dialout $USER
sudo chmod 666 /dev/ttyACM0

# Log out and back in for changes to take effect
```

**Windows:**
- Check Device Manager for your device's COM port
- Update USB drivers if needed

**Mac:**
- Try `/dev/tty.usbmodem*` instead of `/dev/ttyACM0`

### "Flash script not found" Error

**Solution:**
```bash
cd /workspaces
chmod +x flash_custom.sh
./flash_custom.sh
```

### Device Doesn't Boot After Flash

**Solution - Full Factory Reset:**
```bash
# Erase entire flash memory
esptool.py -p /dev/ttyACM0 erase_flash

# Then flash again
cd /workspaces
./flash_custom.sh
```

### Config Settings Not Appearing on Device

**Cause:** Default flash command skips config partition
**Solution:** Always use the custom flash script:
```bash
./flash_custom.sh
```

---

## Quick Reference: Common Commands

```bash
# Build the firmware
idf.py build

# Clean build (removes previous artifacts)
rm -rf build && idf.py build

# Flash with custom script (includes config)
./flash_custom.sh

# Flash with default tool (config not included)
idf.py -p /dev/ttyACM0 flash

# Monitor device output
idf.py -p /dev/ttyACM0 monitor

# Full chip erase (factory reset)
esptool.py -p /dev/ttyACM0 erase_flash

# Check ESP-IDF version
idf.py version

# Set target to ESP32-S3
idf.py set-target esp32s3
```

---

## Summary: Complete Workflow

```bash
# 1. Clone and open in VS Code
git clone -b Official_Bleeding_Edge_3.5Screen https://github.com/RedlineGT/ESP-Miner-Nerds.git
cd ESP-Miner-Nerds
code .

# 2. Install ESP-IDF (via VS Code extension setup wizard)

# 3. Configure settings
# Edit config.cvs with your WiFi and pool settings

# 4. Build the firmware
idf.py build

# 5. Flash to device (with config included)
./flash_custom.sh

# 6. Monitor boot
idf.py -p /dev/ttyACM0 monitor

# Done! Device is now mining
```

---

## Additional Resources

- [ESP-IDF Documentation](https://docs.espressif.com/projects/esp-idf/)
- [ESP32-S3 Datasheet](https://www.espressif.com/sites/default/files/documentation/esp32-s3_datasheet_en.pdf)
- [Repository GitHub](https://github.com/RedlineGT/ESP-Miner-Nerds) (Branch: Official_Bleeding_Edge_3.5Screen)

---

**Last Updated:** April 17, 2026
**Target Device:** ESP32-S3 QFN56
**Firmware:** esp-miner with custom versioning support
