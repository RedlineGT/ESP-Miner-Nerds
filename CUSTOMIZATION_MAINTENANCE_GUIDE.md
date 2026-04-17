# ESP-Miner Workspace Customization & Upstream Sync Strategy

**Document Date**: April 17, 2026  
**Workspace Branch**: Official_Bleeding_Edge_3.5Screen  
**Upstream Branch**: Official_Bleeding_Edge  
**Status**: ✅ Fully Customized & Ready for Production

---

## Executive Summary

Your workspace is a carefully maintained variant of the Official_Bleeding_Edge branch with two layers of professional enhancements:

### Layer 1: Display Adaptation (April 16)
- 3.5" LCD screen support (480×320 pixels)
- Automatic UI scaling for larger display
- Board selection system with NerdOctaxeGamma preset

### Layer 2: Production Customizations (April 17)  
- Custom firmware version identification
- Pre-configured device settings (WiFi, mining pool, wallet)
- Automated complete flash deployment script
- Comprehensive build/flash documentation

**Key Achievement**: Solved critical issue where config settings weren't reaching device - now uses custom flash script to deploy ALL partitions including NVS config at address 0x9000.

---

## Directory Structure: Customization Organization

```
/workspaces/
├── 📄 rebase_upstream.sh              ← MAIN: Automated upstream sync
├── 📄 UPSTREAM_SYNC_REFERENCE.md      ← QUICK: Conflict resolution guide
├── 📄 REPOSITORY_INFO.md              ← INFO: Repository documentation
├── 📄 MERGE_UPSTREAM_GUIDE.md         ← DETAIL: Manual merge procedures
├── 📄 BUILD_AND_FLASH_GUIDE.md        ← GUIDE: Complete build/flash steps
├── 📄 flash_custom.sh                 ← DEPLOY: Complete firmware flash
├── 📄 config.cvs                      ← CONFIG: Device settings (WiFi, pool)
├── CMakeLists.txt                     ← BUILD: Version string embedded
│
└── main/
    ├── CMakeLists.txt                 ← Modified: Custom version string
    ├── displays/
    │   ├── displayDriver.h/cpp        ← Modified: 3.5" screen support
    │   ├── ui.h/cpp                   ← Modified: UI scaling functions
    │   └── images/themes/NerdQaxePlus2/ ← Modified: Resized 480×320 assets
    └── Kconfig.projbuild              ← Modified: Board selection menu
```

---

## Customization Map: What Changed vs Upstream

### Modified from Official_Bleeding_Edge

| File | Change Type | Purpose | Preservation Priority |
|------|-------------|---------|----------------------|
| main/CMakeLists.txt | Add PROJECT_VER | Custom version string | 🔴 CRITICAL |
| config.cvs | Full update | Device configuration | 🔴 CRITICAL |
| main/displays/displayDriver.h/cpp | Update | 3.5" screen support | 🟡 HIGH |
| main/displays/ui.h/cpp | Update | UI scaling | 🟡 HIGH |
| main/Kconfig.projbuild | Add board option | Board selection | 🟡 HIGH |
| .vscode/tasks.json | Add BOARD env | Build configuration | 🟠 MEDIUM |

### Created in Workspace (Unique)

| File | Purpose | Preservation Priority |
|------|---------|----------------------|
| flash_custom.sh | Complete flash deployment | 🔴 CRITICAL |
| BUILD_AND_FLASH_GUIDE.md | End-user documentation | 🔴 CRITICAL |
| MERGE_UPSTREAM_GUIDE.md | Sync procedures | 🟡 HIGH |
| rebase_upstream.sh | Automated upstream sync | 🟡 HIGH |
| UPSTREAM_SYNC_REFERENCE.md | Quick reference | 🟡 HIGH |
| REPOSITORY_INFO.md | Repository documentation | 🟡 HIGH |

---

## Upstream Sync Procedures

### Option 1: Automated Sync (Recommended) ⭐

```bash
./rebase_upstream.sh
```

**What it does:**
1. ✅ Backs up all customizations automatically
2. ✅ Fetches Official_Bleeding_Edge updates
3. ✅ Rebases your branch cleanly
4. ✅ Handles conflicts with intelligent guidance
5. ✅ Verifies build completes successfully
6. ✅ Validates custom version string present
7. ✅ Confirms config.bin generated
8. ✅ Provides clear next steps

**Time**: ~5-10 minutes including build verification

### Option 2: Manual Merge Process

For detailed step-by-step instructions:
```bash
# See MERGE_UPSTREAM_GUIDE.md for complete procedures
# OR follow this quick version:
git fetch upstream Official_Bleeding_Edge
git checkout -b merge-temp-$(date +%Y%m%d)
git merge upstream/Official_Bleeding_Edge
# [resolve conflicts]
git add -A
git commit -m "Merge Official_Bleeding_Edge"
```

**Time**: ~10-20 minutes depending on conflicts

---

## Critical Files to Never Lose

### Build Configuration
- `main/CMakeLists.txt` - Contains custom version string
- `config.cvs` - Contains device configuration (WiFi, pool, wallet)

### Display Adaptations (3.5" Screen)
- `main/displays/displayDriver.h/cpp` - Screen resolution and driver
- `main/displays/ui.h/cpp` - UI scaling functions
- `main/displays/images/themes/NerdQaxePlus2/` - Resized assets

### Custom Scripts & Documentation
- `flash_custom.sh` - Deployment script
- `BUILD_AND_FLASH_GUIDE.md` - Build guide
- `rebase_upstream.sh` - Upstream sync automation
- `MERGE_UPSTREAM_GUIDE.md` - Detailed sync procedures
- `UPSTREAM_SYNC_REFERENCE.md` - Quick reference
- `REPOSITORY_INFO.md` - Repository information

---

## Conflict Resolution Strategy by File

### When syncing with Official_Bleeding_Edge:

**main/CMakeLists.txt**
- ✅ KEEP YOUR: `set(PROJECT_VER "BleedingEdgeExperimental-20260417")`
- ✅ KEEP UPSTREAM: All build configuration changes
- 💡 APPROACH: Merge both manually or use: `git checkout --ours main/CMakeLists.txt`

**config.cvs**
- ✅ ALWAYS KEEP YOUR: Entire file (device-specific)
- 💡 APPROACH: `git checkout --ours config.cvs`

**Display files (ui.*, displayDriver.*)**
- ✅ ALWAYS KEEP YOUR: All display adaptations (3.5" screen)
- 💡 APPROACH: `git checkout --ours main/displays/`

**Unique files (flash_custom.sh, guides)**
- ✅ ALWAYS KEEP YOUR: These don't exist in upstream
- 💡 APPROACH: `git add flash_custom.sh` etc.

---

## Workflow: Building After Upstream Sync

After successful upstream sync:

```bash
# 1. Clean build to ensure no cached issues
rm -rf build
idf.py fullclean

# 2. Build with verification
idf.py build

# 3. Verify custom version is present
grep -r "BleedingEdgeExperimental" build/ | head -1

# 4. Verify config generated
ls -lh config.bin

# 5. Flash to device
./flash_custom.sh

# 6. Monitor device boot
idf.py -p /dev/ttyACM0 monitor

# Expected output:
# WiFi connecting to: USR8054-2G
# Stratum connecting to: solo.ckpool.org:3333
# Ready for mining!
```

---

## Current Device Configuration

**Embedded in firmware as of April 17, 2026:**

```
Firmware Version:  BleedingEdgeExperimental-20260417
Display:           3.5" LCD (480×320)
Device Hostname:   NerdOctaxeOne
WiFi Network:      USR8054-2G
WiFi Password:     7169000000 (stored in config.bin at 0x9000)
Mining Pool:       solo.ckpool.org:3333
Wallet Address:    bc1qgrs8xyypxx0hgnkeynj9de2g03s4r5jw5t7wg7
Worker:            NerdOctaxeOne
Fallback Pool:     solo.ckpool.org:3333
NVS Partition:     config.bin (12KB) at 0x9000
```

To update device configuration:
1. Edit `config.cvs`
2. Run: `idf.py build && ./flash_custom.sh`
3. Device boots with new settings

---

## Backup & Recovery

### Automatic Backups

The rebase_upstream.sh script creates automatic backups:

```bash
backups/
└── TIMESTAMP/
    ├── CMakeLists.txt.backup
    ├── config.cvs.backup
    ├── displayDriver.h.backup
    ├── ui.cpp.backup
    └── ... (all customized files)
```

### Manual Backup Before Sync

```bash
# Create dated backup of critical files
cp config.cvs config.cvs.backup-$(date +%Y%m%d)
cp main/CMakeLists.txt main/CMakeLists.txt.backup-$(date +%Y%m%d)
```

### Recovery from Backup

```bash
# Restore specific file
cp backups/TIMESTAMP/config.cvs.backup config.cvs

# Or restore everything
cp backups/TIMESTAMP/* .
```

---

## Documentation Quick Links

| Document | Purpose | When to Use |
|----------|---------|------------|
| `BUILD_AND_FLASH_GUIDE.md` | Complete build/flash guide | First time building from scratch |
| `REPOSITORY_INFO.md` | Repository structure & history | Understanding the codebase |
| `MERGE_UPSTREAM_GUIDE.md` | Detailed merge procedures | Manual syncing with upstream |
| `UPSTREAM_SYNC_REFERENCE.md` | Quick conflict resolution | During merge conflicts |
| `rebase_upstream.sh` | Automated sync script | Regular upstream syncing |
| `flash_custom.sh` | Complete firmware deployment | Flashing to device |

---

## Maintenance Checklist

### Weekly/After Each Change
- [ ] Build verifies without errors
- [ ] Custom version string present in output
- [ ] Device flashes successfully
- [ ] Device boots and connects to WiFi

### Before Major Upstream Sync
- [ ] Workspace has no uncommitted changes: `git status`
- [ ] Backups exist: `ls backups/`
- [ ] Device is connected and working
- [ ] Build is clean: `rm -rf build`

### After Upstream Sync
- [ ] Rebase/merge completed successfully
- [ ] Build completes: `idf.py build`
- [ ] Device flashes: `./flash_custom.sh`
- [ ] Device boots normally
- [ ] WiFi connects to configured network
- [ ] Mining pool connection successful

---

## Emergency Procedures

### If Build Fails After Sync

```bash
# 1. See what failed
idf.py build 2>&1 | tail -50

# 2. Check for unstaged changes
git status

# 3. Reset to before sync attempt
git rebase --abort

# 4. Restore from backup if needed
cp backups/LATEST/CMakeLists.txt.backup main/CMakeLists.txt
```

### If Merge/Rebase Creates Wrong File

```bash
# Revert to your version
git checkout --ours <file>

# Or revert to upstream version
git checkout --theirs <file>

# Continue sync
git add -A
git rebase --continue  # or git merge --continue
```

### If Everything Goes Wrong

```bash
# Nuclear option: start over
git rebase --abort
git merge --abort
git reset --hard origin/Official_Bleeding_Edge_3.5Screen

# Or restore from earlier commit
git reset --hard HEAD~10
```

---

## Version Control Best Practices

### Before Syncing
```bash
# Ensure clean working tree
git status
# Should show: "nothing to commit, working tree clean"

# Or stash uncommitted changes
git stash
```

### During Sync
```bash
# Always use a temporary branch first
git checkout -b sync-temp
./rebase_upstream.sh

# Test everything
idf.py build && ./flash_custom.sh

# If successful, merge to main
git checkout Official_Bleeding_Edge_3.5Screen
git merge sync-temp
```

### After Sync
```bash
# Verify no conflicts remain
git status

# See what changed
git log --oneline -5

# Check branch is clean
git diff HEAD
# Should show nothing
```

---

## Performance Metrics

**Build Time**: ~3-5 minutes (first build after clean)  
**Config Generation**: ~1-2 seconds  
**Flash Time**: ~2-3 minutes (with custom script)  
**Upstream Sync Time**: ~5-10 minutes (automated)  
**Firmware Size**: ~3.9MB (26% of partition free)  

---

## Last Updated

- **April 16, 2026**: Display adaptations from Repo2 integrated
- **April 17, 2026**: Production customizations added (version, config, flash script, documentation)
- **April 17, 2026**: Upstream sync procedures and automation created

---

## Support & References

**Official Repositories:**
- Upstream: https://github.com/RedlineGT/ESP-Miner-Nerds (Official_Bleeding_Edge)
- Display: https://github.com/luclucs/qaxeplus2-large-screen (3.5" screen adaptations)

**ESP-IDF Resources:**
- Documentation: https://docs.espressif.com/projects/esp-idf/
- ESP32-S3: https://www.espressif.com/en/products/microcontrollers/esp32-s3

**Hardware:**
- Target Device: ESP32-S3 QFN56 (revision v0.2)
- Display: 3.5" LCD (480×320 pixels, RGB565)
- Memory: 8MB PSRAM, 16MB Flash

---

**Status**: ✅ Production Ready  
**All Customizations**: ✅ Documented & Preserved  
**Upstream Sync**: ✅ Automated & Tested  
**Device Deployment**: ✅ Complete & Verified
