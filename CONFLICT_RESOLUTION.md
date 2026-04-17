# Merge Conflict Resolution Guide

When rebasing against upstream updates, conflicts may occur in files that were modified both in upstream and in your local display adaptation branch.

## Common Conflict Scenarios

### Scenario 1: Display Driver Files
**Files**: `main/displays/displayDriver.h`, `main/displays/displayDriver.cpp`

**Resolution Strategy**:
- Keep YOUR changes (3.5" display resolution 480x320, scaling configuration)
- Merge upstream improvements (bug fixes, new features)
- Manually review and combine both changes

```bash
# After conflict is marked, edit the file:
git add main/displays/displayDriver.h
git rebase --continue
```

### Scenario 2: UI Files
**Files**: `main/displays/ui.cpp`, `main/displays/ui.h`

**Resolution Strategy**:
- Keep scaling functions (`scale_x()`, `scale_y()`, `zoom_img()`)
- Merge upstream UI improvements
- Ensure font declarations stay updated

### Scenario 3: Build Configuration
**Files**: `main/CMakeLists.txt`, `main/Kconfig.projbuild`, `.vscode/tasks.json`

**Resolution Strategy**:
- Keep BOARD variable setup and preprocessor defines
- Merge upstream build improvements
- Preserve `BOARD=NERDOCTAXEGAMMA` in task command

### Scenario 4: Asset Files
**Files**: `main/displays/images/themes/NerdQaxePlus2/`

**Resolution Strategy**:
- Keep your resized PNG images (480x320)
- Update C header files if upstream modified them
- Test display rendering after merge

## Handling Conflicts During Rebase

### When Conflicts Occur
1. Git will pause the rebase and mark conflicts with markers:
   ```
   <<<<<<< HEAD (current branch)
   Your changes
   =======
   Upstream changes
   >>>>>>> (commit hash)
   ```

2. **Decision Matrix**:
   | File | Choose | Notes |
   |------|--------|-------|
   | displayDriver.* | YOURS | 3.5" display config is critical |
   | ui.cpp/h | MERGE | Keep scaling + upstream improvements |
   | CMakeLists.txt | MERGE | Keep board defines + upstream changes |
   | Kconfig.projbuild | MERGE | Keep board choice + upstream settings |
   | tasks.json | YOURS | BOARD variable is essential |
   | PNG images | YOURS | Resized for 3.5" display |

### Manual Resolution Steps

1. **Open conflicted file**:
   ```bash
   vim main/displays/ui.cpp
   ```

2. **Choose sections**:
   - Delete `<<<<<<< HEAD` markers
   - Delete `=======` markers
   - Delete `>>>>>>> hash` markers
   - Keep the code you want to keep from both versions

3. **Stage the resolved file**:
   ```bash
   git add main/displays/ui.cpp
   ```

4. **Continue rebase**:
   ```bash
   git rebase --continue
   ```

5. **If you make a mistake, abort**:
   ```bash
   git rebase --abort
   ```

## Example: Resolving a UI Conflict

**Original conflict in `main/displays/ui.cpp`**:
```cpp
<<<<<<< HEAD (Official_Bleeding_Edge_3.5Screen)
// Scaling functions for 3.5" display
inline lv_coord_t scale_x(lv_coord_t value)
{
    return (lv_coord_t) (value * ((float) TDISPLAYS3_LCD_H_RES / 320.0f));
}
=======
// New function from upstream
void updateUILayout()
{
    // New upstream implementation
}
>>>>>>> abc123def
```

**Resolution**: Keep BOTH (merge)
```cpp
// Scaling functions for 3.5" display
inline lv_coord_t scale_x(lv_coord_t value)
{
    return (lv_coord_t) (value * ((float) TDISPLAYS3_LCD_H_RES / 320.0f));
}

// New function from upstream
void updateUILayout()
{
    // New upstream implementation
}
```

## Testing After Rebase

After successful rebase, always:

1. **Clean build**:
   ```bash
   idf.py fullclean
   ```

2. **Rebuild**:
   ```bash
   BOARD=NERDOCTAXEGAMMA idf.py build
   ```

3. **Check firmware size** (should still be ~3.1MB):
   ```bash
   ls -lh build/esp-miner.bin
   ```

4. **Verify display features** work on hardware after flashing

## Reverting If Problems Occur

If the rebase goes wrong and you want to start over:

```bash
# Go back to the state before rebase
git rebase --abort

# Or reset to last known good state
git reset --hard Official_Bleeding_Edge_3.5Screen@{1}
```

## Getting Help

If you encounter issues:

1. Check Git status: `git status`
2. See rebase progress: `git rebase --help`
3. Review conflicts: `git diff`
4. Check branch history: `git log --graph --oneline --all`

## Automating Future Rebases

Run the rebase script anytime upstream updates:

```bash
./rebase_upstream.sh
```

The script will:
- ✅ Fetch upstream Official_Bleeding_Edge
- ✅ Guide you through the process
- ✅ Handle common scenarios
- ✅ Notify you of conflicts
