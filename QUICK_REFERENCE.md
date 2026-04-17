# Quick Reference: Syncing with Upstream

## Automated Way (Recommended)

```bash
# Run the rebase script
./rebase_upstream.sh
```

The script handles:
- Adding upstream remote
- Fetching latest changes
- Running interactive rebase
- Prompting for confirmation

## Manual Way

### Step 1: Fetch Upstream
```bash
git remote add upstream https://github.com/RedlineGT/ESP-Miner-Nerds.git
git fetch upstream Official_Bleeding_Edge
```

### Step 2: Rebase Your Branch
```bash
git rebase upstream/Official_Bleeding_Edge
```

### Step 3: Handle Conflicts (if any)
```bash
# Edit conflicted files
git add <resolved-files>
git rebase --continue

# Or abort if something goes wrong
git rebase --abort
```

### Step 4: Rebuild Firmware
```bash
idf.py fullclean
BOARD=NERDOCTAXEGAMMA idf.py build
```

## Checking Status

```bash
# See local vs upstream
git log --graph --oneline --all

# Check for unpushed commits
git status

# See what branches exist
git branch -a
```

## Emergency Commands

```bash
# Undo rebase if it went wrong
git rebase --abort

# Go back to before rebase
git reset --hard HEAD@{1}

# Start fresh from a specific point
git reset --hard official_bleeding_edge_3.5screen@{1}
```

## Files to Preserve

These are your critical display adaptation changes:
- ✅ `main/displays/displayDriver.h` (resolution 480x320)
- ✅ `main/displays/displayDriver.cpp` (LCD settings)
- ✅ `main/displays/ui.cpp` (scaling functions)
- ✅ `main/displays/ui.h` (font declarations)
- ✅ `main/CMakeLists.txt` (board defines)
- ✅ `main/Kconfig.projbuild` (board choice)
- ✅ `.vscode/tasks.json` (BOARD variable)
- ✅ `main/displays/images/themes/NerdQaxePlus2/` (resized assets)

## Branch Strategy

```
upstream/Official_Bleeding_Edge ──── fetch updates
          ↓
Official_Bleeding_Edge_3.5Screen ─── your customized version
          ↑
     (rebase here when upstream changes)
```

## Typical Workflow

1. **Weekly/Monthly**: Check for upstream updates
   ```bash
   ./rebase_upstream.sh
   ```

2. **If conflicts**: Resolve them using CONFLICT_RESOLUTION.md guide
   
3. **After rebase**: Test everything
   ```bash
   idf.py fullclean && BOARD=NERDOCTAXEGAMMA idf.py build
   ```

4. **Optional**: Push to your own remote (GitHub, GitLab, etc.)
   ```bash
   git remote add origin <your-repo-url>
   git push -u origin Official_Bleeding_Edge_3.5Screen
   ```

## Helpful Git Config

Add these for better Git experience:

```bash
git config --local --add rebase.autoStash true
git config --local --add rebase.abbreviateCommands true
git config --local --add pull.rebase true
```

## See Also

- `REPOSITORY_INFO.md` - Overview of repos and changes
- `CONFLICT_RESOLUTION.md` - Detailed conflict handling
- `rebase_upstream.sh` - The automated rebase script
