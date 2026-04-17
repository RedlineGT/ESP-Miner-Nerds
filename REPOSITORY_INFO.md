# Repository Information

## Source Repositories

### Primary Repository (Repo1)
- **Current Location**: https://github.com/RedlineGT/ESP-Miner-Nerds/tree/Official_Bleeding_Edge
- **Previous Location**: https://github.com/shufps/ESP-Miner-NerdQAxePlus/tree/develop
- **Branch**: Official_Bleeding_Edge

### Reference Repository (Repo2)
- **Location**: https://github.com/luclucs/qaxeplus2-large-screen/tree/main
- **Purpose**: Source of 3.5" display adaptation
- **Commits Used**:
  - c7918de4: Modified code to support the 3.5in screen nerdqaxe miners
  - 4aea7bc8: Modified font sizes to fit the bigger screen

## Modifications Applied

This workspace contains modifications from Repo2 integrated into Repo1:

### Display Adaptation (3.5" Screen Support)
- **Files Modified**:
  - `main/displays/displayDriver.h` - Display resolution 320x170 → 480x320
  - `main/displays/displayDriver.cpp` - LCD panel settings
  - `main/displays/ui.h` - Font declarations
  - `main/displays/ui.cpp` - Scaling functions and UI coordinates
  - `main/CMakeLists.txt` - Font file references

### Board Selection System
- **Files Modified**:
  - `main/Kconfig.projbuild` - Board choice menu
  - `main/CMakeLists.txt` - Preprocessor defines for board variants

### VS Code Configuration
- **Files Modified**:
  - `.vscode/tasks.json` - Build task with BOARD environment variable

### Assets
- **PNG Images**: Replaced with resized versions from repo2
  - `main/displays/images/themes/NerdQaxePlus2/Raw Images/*.png`
  - `main/displays/images/themes/NerdQaxePlus2/ui_img_*.c` (embedded image data)

## Build Configuration

**Current Target Board**: NerdOctaxeGamma
**Display Support**: 3.5" LCD with automatic scaling
**Firmware Size**: ~3.1MB (26% free space in partition)

## Syncing with Upstream

When pulling updates from the new repo1 location:

1. Fetch updates from Official_Bleeding_Edge branch
2. Apply display adaptation changes if they conflict
3. Rebuild firmware with BOARD environment variable
4. Test on target hardware

## Files to Preserve on Updates

These files should be preserved and not overwritten:
- `main/Kconfig.projbuild` (board selection menu)
- `main/CMakeLists.txt` (board defines section)
- `.vscode/tasks.json` (BOARD environment variable)
- `main/displays/displayDriver.h` (resolution changes)
- `main/displays/displayDriver.cpp` (LCD settings)
- `main/displays/ui.cpp` (scaling functions)
- `main/displays/images/themes/NerdQaxePlus2/` (resized assets)

## Last Updated
April 16, 2026
