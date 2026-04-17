# Incorporating Upstream Updates from Official_Bleeding_Edge Branch

This guide documents the process for syncing updates from the Official_Bleeding_Edge branch while preserving local customizations made to this workspace.

---

## Overview

Your workspace is a **curated variant** of the Official_Bleeding_Edge branch with these customizations:

### Layer 1: Display Adaptation (April 16)
- 3.5" LCD screen support (480×320)
- Board selection system (NerdOctaxeGamma)
- UI scaling and font adjustments
- Resized PNG assets

### Layer 2: Custom Modifications (April 17)
- Custom version string: `BleedingEdgeExperimental-20260417`
- Device configuration: `config.cvs` (WiFi, pool, wallet)
- Custom flash script: `flash_custom.sh`
- Build/flash documentation

When the Official_Bleeding_Edge branch updates, you need to pull those changes while keeping your customizations.

---

## Git Setup

### Step 1: Configure Git Remotes

First, set up remotes to track both upstream and your local repository:

```bash
cd /workspaces

# Add upstream remote (Official_Bleeding_Edge branch source)
git remote add upstream https://github.com/RedlineGT/ESP-Miner-Nerds.git

# Verify remotes are configured
git remote -v
```

**Expected output:**
```
origin     https://github.com/YOUR_USERNAME/YOUR_FORK.git (fetch)
origin     https://github.com/YOUR_USERNAME/YOUR_FORK.git (push)
upstream   https://github.com/RedlineGT/ESP-Miner-Nerds.git (fetch)
upstream   https://github.com/RedlineGT/ESP-Miner-Nerds.git (nourl) (push)
```

### Step 2: Create a Merge Branch

Always merge into a temporary branch first, not directly into your working branch:

```bash
# Ensure you're on your current branch
git checkout Official_Bleeding_Edge_3.5Screen

# Create a new merge branch
git checkout -b upstream-merge-$(date +%Y%m%d)

# Example: upstream-merge-20260417
```

---

## Fetching Upstream Updates

### Step 3: Fetch Latest from Upstream

```bash
# Fetch all updates from upstream without merging yet
git fetch upstream Official_Bleeding_Edge
```

### Step 4: Check What Changed

Review which files were modified in the upstream branch:

```bash
# See commits since last update
git log --oneline upstream/Official_Bleeding_Edge ^HEAD --graph

# See what files changed
git diff --name-only HEAD upstream/Official_Bleeding_Edge
```

---

## Merging with Conflict Resolution

### Step 5: Merge Upstream

```bash
# Merge upstream into your temporary merge branch
git merge upstream/Official_Bleeding_Edge
```

This will likely result in merge conflicts in files you've customized.

### Step 6: Identify Merge Conflicts

```bash
# List all files with conflicts
git status
```

**Files in this workspace that will likely conflict:**
- `main/CMakeLists.txt` (custom version string)
- `main/displays/displayDriver.h/cpp` (3.5" screen changes)
- `main/displays/ui.h/cpp` (UI scaling)
- `config.cvs` (device configuration)

**Files to preserve (unique to your workspace):**
- `flash_custom.sh` (take your version)
- `BUILD_AND_FLASH_GUIDE.md` (take your version)
- `MERGE_UPSTREAM_GUIDE.md` (this file - take your version)

---

## Resolving Merge Conflicts

### Step 7: Merge Strategy by File

#### For `main/CMakeLists.txt`

This file contains both upstream changes AND your custom version string:

```bash
# Open the file
nano main/CMakeLists.txt

# Look for conflict markers: <<<<<<< HEAD, =======, >>>>>>>
# Strategy: Keep BOTH upstream changes and your version string
```

**Your custom section to preserve:**
```cmake
# Set custom app version for esp_app_get_description()
set(PROJECT_VER "BleedingEdgeExperimental-20260417")
```

**Action:**
1. Keep all upstream build changes
2. Keep your `set(PROJECT_VER "...")` line
3. Remove conflict markers

#### For Display Files (`main/displays/displayDriver.h/cpp`, `ui.h/cpp`)

These are your 3.5" screen adaptations. Upstream likely didn't touch these:

```bash
# Check if upstream actually modified these
git diff upstream/Official_Bleeding_Edge -- main/displays/displayDriver.h

# If no changes, accept yours:
git checkout --ours main/displays/displayDriver.h
git checkout --ours main/displays/displayDriver.cpp
git checkout --ours main/displays/ui.h
git checkout --ours main/displays/ui.cpp
```

#### For `config.cvs`

Your device configuration - keep your version:

```bash
git checkout --ours config.cvs
```

#### For Unique Files (flash_custom.sh, guides)

```bash
# These are only in your workspace, mark as resolved
git add flash_custom.sh
git add BUILD_AND_FLASH_GUIDE.md
git add MERGE_UPSTREAM_GUIDE.md
```

#### For Other Modified Files

```bash
# For each conflict in other files, determine if:
# - Upstream change is important: git checkout --theirs <file>
# - Your version is better: git checkout --ours <file>
# - Needs manual merge: edit the file and resolve

# Example: if only upstream modified a component
git checkout --theirs components/some_component/file.cpp
```

### Step 8: Mark All Conflicts as Resolved

```bash
# After resolving all conflicts, add them to staging
git add -A

# Verify no conflicts remain
git status
```

**Should show:**
```
On branch upstream-merge-20260417
All conflicts fixed but you are still merging.
  (use "git commit" to continue)
```

### Step 9: Complete the Merge

```bash
# Finish the merge with a descriptive message
git commit -m "Merge Official_Bleeding_Edge ($(date +%Y%m%d)): Upstream updates + preserved customizations

- Merged upstream Official_Bleeding_Edge branch
- Preserved: Custom version string, display adaptations, device config
- Updated: Core firmware components, dependencies
- Status: Ready for testing"
```

---

## Testing After Merge

### Step 10: Verify Build

```bash
# Clean build to ensure everything works
rm -rf build
idf.py fullclean
idf.py build
```

**Check for:**
- ✅ No build errors
- ✅ Config.bin generated successfully
- ✅ Custom version string in output: `BleedingEdgeExperimental-20260417`
- ✅ Binary size reasonable: ~3.9MB

### Step 11: Test Flash

```bash
# Flash to device
./flash_custom.sh
```

**Verify:**
- ✅ Bootloader writes successfully
- ✅ Config.bin writes to 0x9000
- ✅ Device boots normally
- ✅ WiFi connects to USR8054-2G
- ✅ Pool connection works

### Step 12: Check for Regressions

```bash
# Monitor device output for any errors
idf.py -p /dev/ttyACM0 monitor
```

---

## Finalizing the Merge

### Step 13: If Tests Pass

```bash
# Switch back to main branch
git checkout Official_Bleeding_Edge_3.5Screen

# Merge the tested merge branch into your main branch
git merge upstream-merge-20260417

# Delete the temporary merge branch
git branch -d upstream-merge-20260417
```

### Step 14: If Tests Fail

```bash
# Abort the merge and try again
git merge --abort

# Or reset to before the merge
git reset --hard upstream-merge-20260417^

# Fix the issues and try again from Step 5
```

---

## Pushing Updates (If Using a Fork)

### Step 15: Push to Your Fork (Optional)

If you're maintaining this as a public fork:

```bash
# Push the merged branch to your fork
git push origin Official_Bleeding_Edge_3.5Screen

# Push the merge history
git push origin upstream-merge-20260417
```

---

## Handling File Preservation

### Important Files to Never Lose

These files contain your customizations and should be backed up before major merges:

```bash
# Backup your customizations before merge
cp main/CMakeLists.txt main/CMakeLists.txt.backup-$(date +%Y%m%d)
cp config.cvs config.cvs.backup-$(date +%Y%m%d)
cp flash_custom.sh flash_custom.sh.backup-$(date +%Y%m%d)
```

### Files to Always Keep After Merge

Per REPOSITORY_INFO.md:
- `main/CMakeLists.txt` (with your PROJECT_VER section)
- `main/displays/displayDriver.h/cpp` (3.5" changes)
- `main/displays/ui.h/cpp` (scaling functions)
- `main/displays/images/themes/NerdQaxePlus2/` (resized assets)
- `main/Kconfig.projbuild` (board selection)
- `config.cvs` (device config)
- `flash_custom.sh` (custom flash)
- `.vscode/tasks.json` (BOARD environment variable)

---

## Complete Workflow Summary

```bash
# 1. Setup remotes (one-time only)
git remote add upstream https://github.com/RedlineGT/ESP-Miner-Nerds.git

# 2. Create merge branch
git checkout Official_Bleeding_Edge_3.5Screen
git checkout -b upstream-merge-$(date +%Y%m%d)

# 3. Fetch and merge
git fetch upstream Official_Bleeding_Edge
git merge upstream/Official_Bleeding_Edge

# 4. Resolve conflicts (interactive - edit files as needed)
# Use: git checkout --ours <file>  OR  git checkout --theirs <file>

# 5. Complete merge
git add -A
git commit -m "Merge upstream: Official_Bleeding_Edge $(date +%Y%m%d)"

# 6. Test build and flash
rm -rf build
idf.py build
./flash_custom.sh

# 7. Monitor device
idf.py -p /dev/ttyACM0 monitor

# 8. If successful, merge into main branch
git checkout Official_Bleeding_Edge_3.5Screen
git merge upstream-merge-$(date +%Y%m%d)

# 9. Cleanup
git branch -d upstream-merge-$(date +%Y%m%d)

# 10. Push (if maintaining fork)
git push origin Official_Bleeding_Edge_3.5Screen
```

---

## Troubleshooting

### Merge Keeps Failing

```bash
# Abort current merge attempt
git merge --abort

# Try a three-way merge with better strategy
git merge -X ours upstream/Official_Bleeding_Edge
# OR
git merge -X theirs upstream/Official_Bleeding_Edge
```

### Lost Your Changes During Merge

```bash
# Restore from reflog (git keeps history)
git reflog
git reset --hard <commit-hash>
```

### Need to See Exact Diff Before Merging

```bash
# See what changed in specific file
git diff HEAD upstream/Official_Bleeding_Edge -- main/CMakeLists.txt

# See changes in your custom files
git diff HEAD upstream/Official_Bleeding_Edge -- config.cvs
git diff HEAD upstream/Official_Bleeding_Edge -- flash_custom.sh
```

### Rolling Back a Bad Merge

```bash
# If already merged, revert the merge commit
git revert -m 1 <merge-commit-hash>

# Or reset to before the merge
git reset --hard upstream-merge-20260417^
```

---

## Documentation Updates

After each upstream merge, update:

1. **REPOSITORY_INFO.md**
   ```markdown
   ## Last Updated
   April 17, 2026  ← Update this date
   ```

2. **This guide** - Add to merge log:
   ```markdown
   ## Merge History
   - April 17, 2026: Merged Official_Bleeding_Edge - No conflicts
   - [Add new entries here]
   ```

---

## Automation (Optional)

Create a shell script to automate the merge process:

```bash
#!/bin/bash
# merge-upstream.sh

BRANCH="Official_Bleeding_Edge_3.5Screen"
MERGE_BRANCH="upstream-merge-$(date +%Y%m%d)"
BACKUP_DATE=$(date +%Y%m%d_%H%M%S)

echo "🔄 Starting upstream merge process..."

# Backup important files
echo "📦 Backing up customizations..."
cp main/CMakeLists.txt main/CMakeLists.txt.backup-${BACKUP_DATE}
cp config.cvs config.cvs.backup-${BACKUP_DATE}
cp flash_custom.sh flash_custom.sh.backup-${BACKUP_DATE}

# Create merge branch
echo "🌿 Creating merge branch: $MERGE_BRANCH"
git checkout $BRANCH
git checkout -b $MERGE_BRANCH

# Fetch and merge
echo "📥 Fetching upstream..."
git fetch upstream Official_Bleeding_Edge

echo "🔗 Merging upstream..."
git merge upstream/Official_Bleeding_Edge

# Check for conflicts
if git status | grep -q "conflict"; then
    echo "⚠️  Merge conflicts detected!"
    echo "Please resolve conflicts and run: git add -A && git commit"
    echo "Then run: git checkout $BRANCH && git merge $MERGE_BRANCH"
    exit 1
fi

# Complete merge
git add -A
git commit -m "Merge upstream: Official_Bleeding_Edge $(date +%Y%m%d)"

# Build test
echo "🔨 Testing build..."
rm -rf build
if ! idf.py build; then
    echo "❌ Build failed! Merge aborted."
    git reset --hard $MERGE_BRANCH^
    exit 1
fi

echo "✅ Merge successful!"
echo "Next: git checkout $BRANCH && git merge $MERGE_BRANCH"
```

Save as `merge-upstream.sh` and run:
```bash
chmod +x merge-upstream.sh
./merge-upstream.sh
```

---

## Best Practices

1. **Always merge into a temporary branch first** - Never merge directly into your working branch
2. **Test before finalizing** - Run full build and flash test
3. **Keep backups** - Use `git branch` to keep history
4. **Document changes** - Update REPOSITORY_INFO.md after successful merge
5. **Review conflicts carefully** - Don't auto-accept changes you don't understand
6. **Test on device** - Verify behavior after merge, not just build success
7. **Preserve customizations** - Reference REPOSITORY_INFO.md for files to keep

---

**Last Updated**: April 17, 2026  
**Process Tested**: N/A (Guide based on git best practices)  
**Next Update Trigger**: When Official_Bleeding_Edge branch has significant updates
