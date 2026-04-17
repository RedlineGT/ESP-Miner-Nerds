# rebase_upstream.sh Script Updates

## Overview
The `rebase_upstream.sh` script has been enhanced with flexible execution modes to reduce redundant processes and improve efficiency for regular upstream syncs.

## Key Improvements

### 1. **Command-Line Flags for Execution Modes**
```bash
./rebase_upstream.sh              # Full mode (default)
./rebase_upstream.sh --quick      # Quick mode (minimal prompts)
./rebase_upstream.sh --no-verify  # Skip build verification only
./rebase_upstream.sh --no-backup  # Skip automatic backups
./rebase_upstream.sh --help       # Show usage information
```

### 2. **Execution Modes Explained**

#### **Full Mode** (Default - `./rebase_upstream.sh`)
- ✓ Creates timestamped backups of customizations
- ✓ Reviews changes before rebasing (manual confirmation)
- ✓ Runs complete build verification after rebase
- ✓ Ideal for initial setup and careful syncs
- **Use when**: First-time sync, significant upstream changes expected

#### **Quick Mode** (`./rebase_upstream.sh --quick`)
- ✓ Skips backup creation
- ✓ Skips change review (no manual confirmation)
- ✓ Skips build verification
- ⚠️ Fast but risky - use only if confident
- **Use when**: Regular maintenance syncs on tested configuration

#### **No-Verify Mode** (`./rebase_upstream.sh --no-verify`)
- ✓ Creates backups
- ✓ Reviews changes
- ✗ Skips build verification (saves time for large changes)
- **Use when**: Build verification done manually separately

#### **No-Backup Mode** (`./rebase_upstream.sh --no-backup`)
- ✓ Skips backup creation
- ✓ Reviews changes
- ✓ Runs build verification
- **Use when**: Disk space limited or confident in recovery

### 3. **Reduced Processing Steps**
- **Before**: 7 steps (including separate file verification)
- **After**: 5 core steps with optional verification
- Steps can be skipped with appropriate flags

## Process Flow

```
┌─ Setup git remote (skip if exists)
├─ [OPTIONAL] Create backups (--no-backup to skip)
├─ Fetch from upstream
├─ Verify branch status
├─ [OPTIONAL] Review changes (--no-review to skip)
├─ Start rebase (with conflict handling)
└─ [OPTIONAL] Verify build (--no-verify to skip)
```

## Real-World Usage Examples

### **First Rebase (New Setup)**
```bash
./rebase_upstream.sh
# Full verification, creates backups, manual review
```

### **Regular Monthly Sync**
```bash
./rebase_upstream.sh --quick
# Fast sync for routine Official_Bleeding_Edge updates
```

### **Uncertain Changes**
```bash
./rebase_upstream.sh --no-verify
# Keep backups and review, skip time-consuming build
```

### **Automated Script/CI**
```bash
./rebase_upstream.sh --quick --no-backup
# Minimal output, no user interaction, no disk overhead
```

## Conflict Resolution
The script automatically provides guidance for the most common conflict scenarios:

1. **main/CMakeLists.txt** - Version string handling
2. **config.cvs** - Device configuration preservation
3. **display files** - 3.5" screen adaptations
4. General case-by-case resolution instructions

If conflicts occur:
```bash
git add -A
git rebase --continue
```

## Backup Recovery
Backups are saved with timestamp:
```bash
# Restore all customizations from a specific backup
cp backups/20260417-142530/* .
git status
```

## Exit Codes
- **0**: Success (rebase completed and verified)
- **1**: Failure (build error, conflict, or validation issue)

## Script Features

### ✓ Already Implemented
- Automatic upstream remote setup
- Timestamped backup creation
- Intelligent conflict guidance by file type
- Build verification with custom version/config checking
- Color-coded output for clarity
- Help documentation

### ✓ Enhancements in This Update
- Command-line flag parsing
- Flexible execution modes
- Step counting (always shows current progress)
- Mode indication in header
- Smart backup reminders
- Conditional next-steps guidance

## Integration with Other Tools

This script works with:
- **[BUILD_AND_FLASH_GUIDE.md](BUILD_AND_FLASH_GUIDE.md)** - Post-rebase deployment
- **[MERGE_UPSTREAM_GUIDE.md](MERGE_UPSTREAM_GUIDE.md)** - Manual conflict resolution details
- **[UPSTREAM_SYNC_REFERENCE.md](UPSTREAM_SYNC_REFERENCE.md)** - Quick reference card
- **[CUSTOMIZATION_MAINTENANCE_GUIDE.md](CUSTOMIZATION_MAINTENANCE_GUIDE.md)** - Complete strategy
- **flash_custom.sh** - For testing after successful rebase

## Documentation Comments in Script
The script is extensively commented for debugging:
```bash
# Review the script itself for detailed inline comments
cat rebase_upstream.sh | grep "^#"
```

## Future Enhancements
Potential additions for future versions:
- [ ] Automatic conflict resolution with --auto-resolve flag
- [ ] Dry-run mode (--dry-run) to preview without changes
- [ ] Custom branch naming support
- [ ] Email notifications on completion/failure
- [ ] Integration with CI/CD systems

## Troubleshooting

### Script fails with "Not in a Git repository"
```bash
# Make sure you're in the workspace directory
cd /workspaces
./rebase_upstream.sh
```

### Conflicts prevent rebase completion
```bash
# Manual conflict resolution required
# Follow on-screen guidance or see MERGE_UPSTREAM_GUIDE.md
git status  # See which files need resolution
git add <file>
git rebase --continue
```

### Build fails after rebase
```bash
# Option 1: Fix the issue and rebuild
idf.py fullclean
idf.py build

# Option 2: Restore from backup and retry
cp backups/20260417-142530/* .
git rebase --abort
./rebase_upstream.sh --quick
```

---

**Last Updated**: 2026-04-17  
**Compatible With**: rebase_upstream.sh v2.0+  
**Status**: ✓ Production Ready
