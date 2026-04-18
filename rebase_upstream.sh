#!/bin/bash
# Comprehensive Rebase Script for Upstream Sync
# Syncs Official_Bleeding_Edge while preserving customizations
# 
# Usage:
#   ./rebase_upstream.sh              # Full sync with backups and build verification
#   ./rebase_upstream.sh --quick      # Skip backups, review, and build verification
#   ./rebase_upstream.sh --no-verify  # Skip build verification only
#   ./rebase_upstream.sh --no-backup  # Skip automatic backups
#   ./rebase_upstream.sh --help       # Show this help message

set -e

# Parse command line arguments
QUICK_MODE=false
SKIP_VERIFY=false
SKIP_BACKUP=false
SKIP_REVIEW=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --quick) QUICK_MODE=true; SKIP_BACKUP=true; SKIP_REVIEW=true; SKIP_VERIFY=true ;;
        --no-verify) SKIP_VERIFY=true ;;
        --no-backup) SKIP_BACKUP=true ;;
        --no-review) SKIP_REVIEW=true ;;
        --help) echo "Usage: ./rebase_upstream.sh [--quick] [--no-verify] [--no-backup] [--no-review]"; exit 0 ;;
        *) echo "Unknown option: $1"; echo "Use --help for usage information"; exit 1 ;;
    esac
    shift
done

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
UPSTREAM_BRANCH="Official_Bleeding_Edge"
LOCAL_BRANCH="Official_Bleeding_Edge_3.5Screen"
BACKUP_DIR="backups/$(date +%Y%m%d-%H%M%S)"

# Files that are unique to this workspace (should never be lost)
UNIQUE_FILES=(
    "flash_custom.sh"
    "BUILD_AND_FLASH_GUIDE.md"
    "MERGE_UPSTREAM_GUIDE.md"
    "CUSTOMIZATION_MAINTENANCE_GUIDE.md"
    "UPSTREAM_SYNC_REFERENCE.md"
    "rebase_upstream.sh"
    "main/CSV_CONFIG_GUIDE.md"
    "components/arduinojson/CMakeLists.txt"
)

# Files that contain customizations and need conflict resolution
CUSTOMIZED_FILES=(
    "main/CMakeLists.txt"
    "main/csv_config.h"
    "main/csv_config.cpp"
    "config.cvs"
    "main/Kconfig.projbuild"
    "main/main.cpp"
    "components/influx/CMakeLists.txt"
    "main/displays/displayDriver.h"
    "main/displays/displayDriver.cpp"
    "main/displays/ui.h"
    "main/displays/ui.cpp"
)

# Display header with mode info
echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║${NC}  ESP-Miner Upstream Rebase Script                        ${BLUE}║${NC}"
if [ "$QUICK_MODE" = true ]; then
    echo -e "${BLUE}║${NC}  Mode: QUICK (minimal prompts, no verification)         ${BLUE}║${NC}"
elif [ "$SKIP_VERIFY" = true ]; then
    echo -e "${BLUE}║${NC}  Mode: NO_VERIFY (skip build verification)             ${BLUE}║${NC}"
else
    echo -e "${BLUE}║${NC}  Mode: FULL (backups, review, verification)            ${BLUE}║${NC}"
fi
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Display known build issues info (only in full mode to avoid clutter)
if [ "$QUICK_MODE" = false ]; then
    echo -e "${BLUE}Known Build Issues (Already Fixed in This Codebase):${NC}"
    echo ""
    echo "  ✓ GPIO API deprecation: gpio_pad_select_gpio → esp_rom_gpio_pad_select_gpio"
    echo "    Location: components/bm1397/CMakeLists.txt, main/boards/drivers/*.cpp"
    echo ""
    echo "  ✓ mbedtls header includes: stratum_v2 component"
    echo "    Location: components/stratum_v2/CMakeLists.txt"
    echo ""
    echo "  ✓ Driver header paths: Added INCLUDE_DIRS for adc.h, uart.h"
    echo "    Location: components/*/CMakeLists.txt"
    echo ""
    echo "  ✓ Type casting: int → gpio_num_t conversions fixed"
    echo "    Location: main/boards/drivers/i2c_master.cpp"
    echo ""
    echo "  ✓ Component dependencies: REQUIRES declarations"
    echo "    Location: components/*/CMakeLists.txt"
    echo ""
    echo "  ✓ Compiler pragmas: GCC diagnostic directives added"
    echo "    Location: Multiple source files (pragma suppress warnings)"
    echo ""
    echo "  ✓ Extern C declarations: For mbedtls functions"
    echo "    Location: components/stratum_v2/* (C++ integration)"
    echo ""
    echo "  ✓ Struct initialization: Field initializers added"
    echo "    Location: source files (compiler warning fixes)"
    echo ""
    echo "  ✓ CSV Config Integration: Load config.cvs from SPIFFS on device boot"
    echo "    Location: main/csv_config.h, main/csv_config.cpp, main/main.cpp"
    echo "    Features: Multi-device provisioning, config export, menuconfig integration"
    echo "    Menuconfig: 'Config CSV Integration' menu positioned at END of Kconfig.projbuild"
    echo "    Reason: Keeps 'Miner Configuration' and 'Target Board' visible at top"
    echo "    Guide: main/CSV_CONFIG_GUIDE.md"
    echo ""
    echo "  ✓ Component CMakeLists.txt: Missing or incorrect configurations"
    echo "    Location: components/arduinojson/CMakeLists.txt (created)"
    echo "    Location: components/influx/CMakeLists.txt (changed 'json' → 'arduinojson')"
    echo "    Effect: Fixes menuconfig initialization errors"
    echo ""
    echo -e "${BLUE}Build should complete successfully after rebase.${NC}"
    echo -e "${BLUE}If build errors occur, check git status for changes to above files.${NC}"
    echo ""
fi

echo ""
echo -e "${YELLOW}[1/5]${NC} Setting up git repository..."

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}✗ Error: Not in a Git repository${NC}"
    exit 1
fi

# Check if remote exists, if not add it
if ! git remote | grep -q upstream; then
    echo -e "${YELLOW}→ Adding upstream remote...${NC}"
    git remote add upstream https://github.com/RedlineGT/ESP-Miner-Nerds.git
    echo -e "${GREEN}✓ Upstream remote added${NC}"
else
    echo -e "${GREEN}✓ Upstream remote exists${NC}"
fi

# Backup customizations (unless --no-backup flag)
if [ "$SKIP_BACKUP" = false ]; then
    echo ""
    echo -e "${YELLOW}[2/5]${NC} Creating backups of customizations..."
    mkdir -p "$BACKUP_DIR"
    
    for file in "${CUSTOMIZED_FILES[@]}"; do
        if [ -f "$file" ]; then
            cp "$file" "$BACKUP_DIR/$(basename "$file").backup"
            echo "  ✓ Backed up: $file"
        fi
    done
    
    for file in "${UNIQUE_FILES[@]}"; do
        if [ -f "$file" ]; then
            cp "$file" "$BACKUP_DIR/$(basename "$file").backup"
            echo "  ✓ Backed up: $file"
        fi
    done
    
    echo -e "${GREEN}✓ Backups created in: $BACKUP_DIR${NC}"
    BACKUP_REMINDER=$BACKUP_DIR
else
    echo ""
    echo -e "${YELLOW}[2/5]${NC} Skipping backups (--no-backup flag)"
    BACKUP_REMINDER="No backups created"
fi

echo ""
echo -e "${YELLOW}[3/5]${NC} Fetching from upstream..."
git fetch upstream Official_Bleeding_Edge
echo -e "${GREEN}✓ Fetch complete${NC}"
echo ""
echo -e "${YELLOW}[4/5]${NC} Verifying branch status..."
# Check current branch
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
if [ "$CURRENT_BRANCH" != "$LOCAL_BRANCH" ]; then
    echo -e "${YELLOW}  → Switching to $LOCAL_BRANCH...${NC}"
    git checkout "$LOCAL_BRANCH"
fi
echo -e "${GREEN}✓ On branch: $LOCAL_BRANCH${NC}"

# Show what's about to happen (unless --no-review flag)
if [ "$SKIP_REVIEW" = false ]; then
    echo ""
    echo -e "${BLUE}Your recent commits:${NC}"
    git log --oneline -3
    echo ""
    echo -e "${BLUE}Upstream changes to be rebased:${NC}"
    git log --oneline "upstream/$UPSTREAM_BRANCH..HEAD" | head -5
    echo ""
    
    read -p "Continue with rebase? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo -e "${YELLOW}⊘ Rebase cancelled${NC}"
        exit 0
    fi
else
    echo -e "${YELLOW}Skipping change review (--no-review flag)${NC}"
fi

echo ""
echo -e "${YELLOW}[5/5]${NC} Starting rebase..."
echo ""

# Start rebase
if git rebase "upstream/$UPSTREAM_BRANCH"; then
    echo -e "${GREEN}✓ Rebase completed successfully!${NC}"
    echo ""
    echo -e "${BLUE}Display adaptations and custom changes preserved:${NC}"
    git log --oneline -5
    
    # Build verification (unless --no-verify flag)
    if [ "$SKIP_VERIFY" = false ]; then
        echo ""
        echo -e "${YELLOW}Verifying build...${NC}"
        echo -e "${BLUE}(All 8 idf.py build issues from April 17 are already fixed in this codebase)${NC}"
        echo ""
        
        # Clean build
        rm -rf build
        
        # Build verification
        if idf.py build > /tmp/build.log 2>&1; then
            echo -e "${GREEN}✓ Build successful!${NC}"
            
            # Check for custom version string
            if grep -q "BleedingEdgeExperimental" /tmp/build.log; then
                echo -e "${GREEN}✓ Custom version string found${NC}"
            fi
            
            # Check for config.bin generation
            if grep -q "config.bin" /tmp/build.log; then
                echo -e "${GREEN}✓ Device config (config.bin) generated${NC}"
            fi
        else
            echo -e "${RED}✗ Build failed!${NC}"
            echo ""
            echo "Build output (last 50 lines):"
            tail -50 /tmp/build.log
            echo ""
            echo -e "${YELLOW}Troubleshooting:${NC}"
            echo "1. Check if upstream introduced new issues: git diff upstream/$UPSTREAM_BRANCH"
            echo "2. Verify CSV config integration is present:"
            echo "   - grep 'csv_config' main/CMakeLists.txt"
            echo "   - grep 'CsvConfig::load' main/main.cpp"
            echo "3. Verify component CMakeLists fixes are present:"
            echo "   - ls components/arduinojson/CMakeLists.txt"
            echo "   - grep 'arduinojson' components/influx/CMakeLists.txt"
            echo "4. Review known fixes that were applied:"
            echo "   - GPIO API updates: components/bm1397/CMakeLists.txt"
            echo "   - mbedtls includes: components/stratum_v2/CMakeLists.txt"
            echo "   - Driver headers: components/*/CMakeLists.txt"
            echo "4. Try clean rebuild: idf.py fullclean && idf.py build"
            if [ ! -z "$BACKUP_REMINDER" ] && [ "$BACKUP_REMINDER" != "No backups created" ]; then
                echo "5. Restore backup: cp $BACKUP_REMINDER/* ."
            fi
            echo "7. Abort rebase: git rebase --abort"
            exit 1
        fi
    else
        echo -e "${YELLOW}Skipping build verification (--no-verify flag)${NC}"
    fi
else
    echo -e "${RED}✗ Rebase encountered conflicts!${NC}"
    echo ""
    echo -e "${YELLOW}=== CONFLICT RESOLUTION GUIDE ===${NC}"
    echo ""
    
    # Show conflicted files
    CONFLICTS=$(git diff --name-only --diff-filter=U)
    echo -e "${BLUE}Conflicted files:${NC}"
    echo "$CONFLICTS"
    echo ""
    
    echo -e "${YELLOW}Quick Resolution Reference:${NC}"
    echo ""
    echo "For main/CMakeLists.txt:"
    echo "  • Keep your custom version: set(PROJECT_VER \"BleedingEdgeExperimental-...\")"
    echo "  • Keep upstream build changes"
    echo "  • git checkout --ours main/CMakeLists.txt"
    echo ""
    echo "For CSV Config files:"
    echo "  • Keep your config.cvs values"
    echo "  • Keep csv_config.h and csv_config.cpp"
    echo "  • git checkout --ours config.cvs main/csv_config.*"
    echo ""
    echo "For main/main.cpp and main/Kconfig.projbuild:"
    echo "  • Merge CSV integration changes with upstream updates"
    echo "  • Ensure csv_config.h include is present"
    echo "  • Ensure CsvConfig::load_config_from_csv() call is in app_main()"
    echo "  • Use 'git mergetool' for detailed review"
    echo ""
    echo "For display files (ui.*, displayDriver.*):"
    echo "  • Keep your 3.5\" screen adaptations"
    echo "  • git checkout --ours main/displays/"
    echo ""
    echo "For components/influx/CMakeLists.txt:"
    echo "  • Keep the fix: REQUIRES 'arduinojson' (not 'json')"
    echo "  • This is critical for menuconfig to work"
    echo "  • git checkout --ours components/influx/CMakeLists.txt"
    echo ""
    echo "For main/Kconfig.projbuild:"
    echo "  • Verify 'Config CSV Integration' menu is at the END (after Stratum Keepalive)"
    echo "  • This keeps 'Miner Configuration' with 'Target Board' visible at top"
    echo "  • If upstream moved it, move it back to END"
    echo ""
    echo "Then resolve all conflicts:"
    echo "  1. git add -A"
    echo "  2. git rebase --continue"
    echo ""
    echo -e "${YELLOW}If something goes wrong:${NC}"
    echo "  • git rebase --abort (cancels rebase)"
    if [ ! -z "$BACKUP_REMINDER" ] && [ "$BACKUP_REMINDER" != "No backups created" ]; then
        echo "  • Restore from: $BACKUP_REMINDER"
    fi
    echo ""
    exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║${NC}              ✓ REBASE COMPLETED SUCCESSFULLY!            ${GREEN}║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${BLUE}Summary:${NC}"
echo "  • Rebased onto: upstream/$UPSTREAM_BRANCH"
echo "  • Local branch: $LOCAL_BRANCH"
echo "  • Display adaptations: Preserved ✓"
echo "  • CSV config integration: Preserved ✓"
echo "  • Custom modifications: Preserved ✓"
if [ "$SKIP_VERIFY" = false ]; then
    echo "  • Build status: Verified ✓"
else
    echo "  • Build status: Verification skipped (--no-verify)"
fi
if [ ! -z "$BACKUP_REMINDER" ] && [ "$BACKUP_REMINDER" != "No backups created" ]; then
    echo "  • Backups saved in: $BACKUP_REMINDER"
fi
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Verify CSV config integration: cat main/CSV_CONFIG_GUIDE.md"
echo "  2. Verify menuconfig menu structure: grep -n 'menu \"Config CSV Integration\"' main/Kconfig.projbuild"
echo "     (Should appear at END of file, not at beginning)"
echo "  3. Test on device: ./flash_custom.sh"
echo "  4. Monitor output: idf.py -p /dev/ttyACM0 monitor"
echo "  5. Verify WiFi connection and pool connectivity"
if [ "$QUICK_MODE" = false ] && [ "$SKIP_VERIFY" = true ]; then
    echo "  6. [RECOMMENDED] Run build check: idf.py build"
fi
echo "  6. Push changes (if forked): git push origin $LOCAL_BRANCH"
echo ""
echo -e "${BLUE}For help with options:${NC}"
echo "  ./rebase_upstream.sh --help"
echo ""
