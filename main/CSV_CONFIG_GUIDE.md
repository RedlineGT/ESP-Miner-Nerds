# Config CSV Integration Guide

## Overview

The firmware now supports loading and managing device configuration via a `config.cvs` file stored in SPIFFS (SPI Flash File System). This allows for:

- **Easy device provisioning** - Copy the same config file to multiple devices
- **Non-volatile storage** - Configuration persists across firmware updates
- **Centralized management** - One config file per device variant
- **Compatibility** - Config.cvs values override menuconfig defaults while respecting Kconfig overrides

## How It Works

```
┌─────────────────────────────────────────────────────┐
│                  Device Boot                        │
└────────────────┬────────────────────────────────────┘
                 │
                 ▼
        ┌─────────────────┐
        │  Load NVS Flash │
        └────────┬────────┘
                 │
                 ▼
     ┌─────────────────────────┐
     │ Config.cvs exists?      │
     │ (in SPIFFS)             │
     └────────┬────────┬───────┘
          YES │        │ NO
             ▼        ▼
    ┌──────────────────┐
    │ Load CSV values  │ Use Kconfig
    │ into NVS         │ defaults
    │ (Overrides!)     │
    └──────────────────┘
             │
             ▼
     ┌──────────────────┐
     │ Run Application  │
     │ with merged      │
     │ configuration    │
     └──────────────────┘
```

## Getting Started

### Step 1: Create Your config.cvs

Use the provided [config.cvs.example](../config.cvs.example) as a template:

```csv
key,type,encoding,value
main,namespace,,

# Device Identification
hostname,data,string,MyNerdAxe

# Wi-Fi Configuration
wifissid,data,string,MySSID
wifipass,data,string,MyPassword123

# Stratum Pool (Primary)
stratumurl,data,string,solo.ckpool.org
stratumport,data,u16,3333
stratumuser,data,string,bc1qXXXXXXXX.worker1
stratumpass,data,string,x
stratumdiff,data,u64,1000

# Stratum Pool (Fallback)
fbstratumurl,data,string,
fbstratumport,data,u16,3333
fbstratumuser,data,string,
fbstratumpass,data,string,x
```

### Step 2: Flash config.cvs to SPIFFS

#### Using esptool directly:
```bash
# First, build the project
idf.py build

# Then flash the filesystem with config.cvs
idf.py flash -p /dev/ttyUSB0
```

#### Using the provided script (if available):
```bash
./flash_custom.sh config.cvs
```

#### Manual SPIFFS partition creation:
```bash
# Create a SPIFFS image with your config
mkspiffs -c config.cvs -s 3145728 spiffs.bin

# Flash it
esptool.py -p /dev/ttyUSB0 write_flash 0x410000 spiffs.bin
```

### Step 3: Boot the Device

On the next boot:
1. Firmware initializes NVS
2. Checks if config.cvs exists in SPIFFS
3. **If found**: Loads all key-value pairs into NVS (overriding defaults)
4. **If not found**: Uses Kconfig defaults from menuconfig

The web interface and API will now reflect the loaded configuration.

## Configuration Priority

The configuration is applied in this priority order (highest wins):

1. **Values in NVS from previous runtime** (web UI changes, API modifications)
2. **Values loaded from config.cvs** (if file exists in SPIFFS)
3. **Kconfig defaults** (compiled defaults from menuconfig)

## Modifying Configuration

### Via Web Interface
1. Navigate to the device's web UI
2. Modify settings as needed
3. Click "Save"
4. Changes are stored in NVS

### Via HTTP API
```bash
# Example: Set stratum URL via API
curl -X POST http://192.168.1.100/api/config/set \
  -H "Content-Type: application/json" \
  -d '{"stratumurl":"pool.example.com"}'
```

### Export Configuration Back to CSV
After making changes, you can export the current configuration:

```bash
# If enabled in menuconfig (CONFIG_ENABLE_CSV_CONFIG_EXPORT)
curl http://192.168.1.100/api/config/export > new_config.cvs
```

Or use the provided function directly:
```cpp
#include "csv_config.h"
CsvConfig::export_config_to_csv(); // Exports NVS to config.cvs
```

## Field Reference

### Network Configuration
| Key | Type | Description | Example |
|-----|------|-------------|---------|
| `hostname` | string | Device hostname on LAN | `MyNerdAxe` |
| `wifissid` | string | Wi-Fi network SSID | `HomeNetwork` |
| `wifipass` | string | Wi-Fi password | `MyPassword123` |

### Primary Pool Configuration
| Key | Type | Description | Example |
|-----|------|-------------|---------|
| `stratumurl` | string | Pool server hostname/IP | `solo.ckpool.org` |
| `stratumport` | u16 | Pool server port | `3333` |
| `stratumuser` | string | Username/wallet address | `bc1qXXXXX.worker1` |
| `stratumpass` | string | Password (usually "x") | `x` |
| `stratumdiff` | u64 | Initial difficulty | `1000` |

### Fallback Pool Configuration
| Key | Type | Description | Example |
|-----|------|-------------|---------|
| `fbstratumurl` | string | Fallback pool hostname | `backup-pool.io` |
| `fbstratumport` | u16 | Fallback pool port | `3333` |
| `fbstratumuser` | string | Fallback username | `bc1qXXXXX.worker2` |
| `fbstratumpass` | string | Fallback password | `x` |

## Common Use Cases

### Multi-Device Deployment
1. Create a master config.cvs with your pool and network settings
2. For each device, create a device-specific config.cvs with unique hostname/worker ID
3. Flash each device with its respective config.cvs
4. All devices boot with their specific configuration

### Testing Different Pools
1. Create config1.cvs with pool A settings
2. Create config2.cvs with pool B settings
3. Flash config1.cvs to device, test
4. Reflash config2.cvs to device, test
5. No recompilation needed!

### Remote Configuration Updates
1. Device boots with factory config.cvs
2. User modifies settings via web UI
3. Admin exports config: `curl http://device/api/config/export > device_backup.cvs`
4. Admin can now use this as template for other devices

## Troubleshooting

### config.cvs not loading

**Check logs:**
```bash
# Monitor the device via serial
idf.py monitor -p /dev/ttyUSB0

# Look for messages like:
# [CsvConfig] Loading configuration from config.cvs
# [CsvConfig] Loaded X configuration values from config.cvs
```

**If "not found" error:**
1. Verify config.cvs is in SPIFFS
2. Check file path: `/spiffs/config.cvs`
3. Verify file permissions and format

**If values not updating in NVS:**
1. Check CSV format (must match exactly)
2. Verify field types match (u16, string, u64)
3. Check for encoding issues in CSV file

### Values reverting after reboot

This is normal! Here's why:
- Config.cvs is read on boot (loads into NVS)
- Changes via web UI are stored in NVS only
- On next boot, config.cvs values reload (overwriting NVS changes)

**Solution:** 
1. Make changes via web UI
2. Export config: `curl http://device/api/config/export > config.cvs`
3. Flash updated config.cvs to SPIFFS
4. Reboot device

## API Reference

### C++ Functions

```cpp
// Load config.cvs from SPIFFS into NVS
bool CsvConfig::load_config_from_csv();

// Export NVS configuration to config.cvs
bool CsvConfig::export_config_to_csv();

// Check if config.cvs exists
bool CsvConfig::csv_file_exists();
```

### HTTP Endpoints (when enabled)

```
POST /api/config/set
  Body: {"key": "value", "key2": "value2"}
  
GET /api/config/export
  Returns: CSV formatted configuration
  
GET /api/config/get?key=stratumurl
  Returns: {"stratumurl": "pool.example.com"}
```

## Security Considerations

⚠️ **Warning:** The config.cvs file contains sensitive information:
- Wi-Fi passwords in plaintext
- Stratum credentials
- Wallet addresses

### Best Practices

1. **Never commit config.cvs to version control** (add to `.gitignore`)
2. **Secure file transmission** - Use SFTP/SCP, not HTTP
3. **Protect device access** - Restrict web UI access if on untrusted networks
4. **Backup configurations** - Keep copies in a secure location
5. **Update after sensitive changes** - If credentials leak, update config.cvs

## Advanced Usage

### Conditional Configuration Loading

You can extend the CSV loader to support device profiles:

```cpp
// Load config based on device type
if (board->getDeviceModel() == "NerdOctaxeGamma") {
    CsvConfig::load_config_from_csv(); // Uses default /spiffs/config.cvs
} else {
    // Could load device-specific path like /spiffs/config_v2.cvs
}
```

### Custom Field Types

The CSV loader supports:
- `string` - Text values
- `u16` - 16-bit unsigned integers
- `u32` - 32-bit unsigned integers  
- `u64` - 64-bit unsigned integers

To add more types, modify `csv_config.cpp` in the type parsing section.

## Related Files

- **CSV Loader**: [csv_config.h](./csv_config.h), [csv_config.cpp](./csv_config.cpp)
- **NVS Config**: [nvs_config.h](./nvs_config.h), [nvs_config.cpp](./nvs_config.cpp)
- **Example Config**: [config.cvs.example](../config.cvs.example)
- **Menuconfig**: [Kconfig.projbuild](./Kconfig.projbuild)

## Changelog

### Version 1.0
- Initial CSV config integration
- Load config.cvs from SPIFFS on boot
- Export NVS configuration to CSV
- Menuconfig integration guide
