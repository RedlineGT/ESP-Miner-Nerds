#!/bin/bash

# Custom flash script for ESP32-S3 NerdOctaxe device
# Usage: ./flash_custom.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$SCRIPT_DIR/build"

# Check if build directory exists
if [ ! -d "$BUILD_DIR" ]; then
    echo "ERROR: Build directory not found at $BUILD_DIR"
    echo "Please run 'idf.py build' first"
    exit 1
fi

# Check if all required binaries exist
REQUIRED_FILES=(
    "$BUILD_DIR/bootloader/bootloader.bin"
    "$BUILD_DIR/partition_table/partition-table.bin"
    "$SCRIPT_DIR/config.bin"
    "$BUILD_DIR/ota_data_initial.bin"
    "$BUILD_DIR/www.bin"
    "$BUILD_DIR/esp-miner.bin"
)

for file in "${REQUIRED_FILES[@]}"; do
    if [ ! -f "$file" ]; then
        echo "ERROR: Required file not found: $file"
        exit 1
    fi
done

# Check if esptool.py is available
if ! command -v esptool.py &> /dev/null; then
    echo "ERROR: esptool.py not found. Please install it:"
    echo "  pip install esptool"
    exit 1
fi

echo "Flashing ESP32-S3 device on /dev/ttyACM0..."
echo "Including: bootloader, partition table, CONFIG, web UI, app binary, OTA data"
echo ""

# Flash with explicit config.bin at 0x9000
esptool.py --chip esp32s3 -p /dev/ttyACM0 -b 460800 --before=default-reset --after=hard-reset write-flash --flash-mode dio --flash-freq 80m --flash-size 16MB \
  0x0 "$BUILD_DIR/bootloader/bootloader.bin" \
  0x8000 "$BUILD_DIR/partition_table/partition-table.bin" \
  0x9000 "$SCRIPT_DIR/config.bin" \
  0x10000 "$BUILD_DIR/esp-miner.bin" \
  0x410000 "$BUILD_DIR/www.bin" \
  0xf10000 "$BUILD_DIR/ota_data_initial.bin"

if [ $? -eq 0 ]; then
    echo ""
    echo "✓ Flash successful!"
    echo "Device should now be booting with config settings:"
    echo "  WiFi: USR8054-2G"
    echo "  Pool: solo.ckpool.org:3333"
else
    echo ""
    echo "✗ Flash failed!"
    exit 1
fi

