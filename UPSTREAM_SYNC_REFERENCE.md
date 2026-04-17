# Upstream Sync Quick Reference

Quick commands and procedures for keeping your workspace synced with Official_Bleeding_Edge while preserving customizations.

---

## TL;DR - Fast Sync

```bash
# One-command sync with automated conflict handling and verification
./rebase_upstream.sh
```

That's it! The script handles everything.

---

## Common Tasks

### Check if upstream has updates

```bash
git fetch upstream Official_Bleeding_Edge
git log --oneline HEAD..upstream/Official_Bleeding_Edge
```

Shows commits you're behind.

### See what changed in upstream

```bash
git fetch upstream Official_Bleeding_Edge
git diff HEAD..upstream/Official_Bleeding_Edge -- main/
```

Shows only changes to the main/ directory.

### Check differences in specific file

```bash
git fetch upstream Official_Bleeding_Edge
git diff HEAD:config.cvs upstream/Official_Bleeding_Edge:config.cvs
```

Compare your config.cvs with upstream's version.

---

## Conflict Resolution Cheat Sheet

### Quick conflict fixes by file type

#### "I want MY version of this file"
```bash
git checkout --ours <file>
```

### "I want UPSTREAM's version of this file"
```bash
git checkout --theirs <file>
```

### "I want to manually edit and combine both"
```bash
# Edit the file, remove conflict markers <<<<<<< ======= >>>>>>>
nano <file>
# Then mark as resolved
git add <file>
```

### Revert a bad merge/rebase

```bash
# During rebase
git rebase --abort

# After merge (if already committed)
git revert -m 1 <commit-hash>
```

---

## File-Specific Resolution Guide

### main/CMakeLists.txt

**What to keep:**
- Your: `set(PROJECT_VER "BleedingEdgeExperimental-20260417")`
- Upstream: All build configuration changes

**Quick fix:**
```bash
git show :2:main/CMakeLists.txt > main/CMakeLists.txt  # Keep theirs
# Then manually add back your PROJECT_VER line
```

### config.cvs

**What to keep:**
- Your: Entire file (device-specific configuration)

**Quick fix:**
```bash
git checkout --ours config.cvs
```

### Display files (ui.*, displayDriver.*)

**What to keep:**
- Your: All files (3.5" screen adaptations)

**Quick fix:**
```bash
git checkout --ours main/displays/ui.h
git checkout --ours main/displays/ui.cpp
git checkout --ours main/displays/displayDriver.h
git checkout --ours main/displays/displayDriver.cpp
```

### Unique workspace files

**What to keep:**
- Your: All versions (these don't exist upstream)

**Quick fix:**
```bash
git add flash_custom.sh
git add BUILD_AND_FLASH_GUIDE.md
git add MERGE_UPSTREAM_GUIDE.md
git add UPSTREAM_SYNC_REFERENCE.md
```

---

## Debug & Recovery

### Check what's in conflict right now

```bash
git status | grep "both"
```

### See which version of a file is which

```bash
# Your version (HEAD)
git show :1:<file>

# Theirs (upstream)
git show :3:<file>
```

### List all conflicts

```bash
git diff --name-only --diff-filter=U
```

### Abort everything and start over

```bash
# During rebase
git rebase --abort

# During merge
git merge --abort

# After completion (with commits)
git reset --hard HEAD~1
```

### Restore from backup

The rebase_upstream.sh script automatically creates backups in `backups/TIMESTAMP/`:

```bash
# List available backups
ls -la backups/

# Restore a specific backup
cp backups/20260417-120000/config.cvs.backup config.cvs
```

---

## Step-by-Step: First Time Sync

If this is your first upstream sync, follow these steps:

```bash
# 1. Make sure your workspace is clean
git status
# Should show "nothing to commit, working tree clean"

# 2. Run the automated script
./rebase_upstream.sh

# 3. If it completes successfully:
#    ✓ Rebase is done
#    ✓ Build was tested
#    ✓ All customizations preserved

# 4. If it fails with conflicts:
#    Read the guidance from rebase_upstream.sh
#    Resolve conflicts using the guides above
#    Continue rebase: git rebase --continue

# 5. Test on device after sync completes
./flash_custom.sh
idf.py -p /dev/ttyACM0 monitor
```

---

## Preventing Conflicts

### Before syncing, understand what changed

```bash
git fetch upstream Official_Bleeding_Edge
git log --stat upstream/Official_Bleeding_Edge ^HEAD
```

Shows exactly which files were modified upstream.

### Stash your changes if needed

```bash
# Save local changes temporarily
git stash

# Later restore them
git stash pop
```

### Create a test branch before syncing

```bash
# Don't sync on your main branch first time
git checkout -b test-upstream-sync
./rebase_upstream.sh

# If it works, merge back to main
git checkout Official_Bleeding_Edge_3.5Screen
git merge test-upstream-sync

# Clean up
git branch -d test-upstream-sync
```

---

## When to Use Merge vs Rebase

### Use Rebase (rebase_upstream.sh) When:
- You want clean, linear history
- You're the only developer on this branch
- You haven't pushed to a shared repo yet

### Use Merge When:
- You want to keep full history of when you diverged
- You've already pushed and other developers depend on it
- You want a clear "merge commit" marking the sync point

---

## Post-Sync Verification Checklist

After any upstream sync, verify:

- [ ] Build completes: `idf.py build`
- [ ] Custom version string present: `grep -r "BleedingEdgeExperimental" build/`
- [ ] Config generated: `ls -l config.bin`
- [ ] Device flashes: `./flash_custom.sh`
- [ ] Device boots normally: `idf.py -p /dev/ttyACM0 monitor`
- [ ] WiFi connects to: USR8054-2G
- [ ] Pool connects to: solo.ckpool.org:3333

---

## Emergency: Complete Reset

If something goes really wrong:

```bash
# Reset to before the last sync attempt
git reset --hard origin/Official_Bleeding_Edge_3.5Screen

# Or go back even further
git reset --hard HEAD~5

# Or use reflog to find a good commit
git reflog
git reset --hard <commit-hash>
```

---

## Getting Help

For more detailed information:
- **Automated sync**: See `rebase_upstream.sh` itself for detailed output
- **Manual merge**: See `MERGE_UPSTREAM_GUIDE.md`
- **Repository structure**: See `REPOSITORY_INFO.md`
- **Build process**: See `BUILD_AND_FLASH_GUIDE.md`

---

**Last Updated**: April 17, 2026  
**Status**: Ready for production use  
**Tested**: ✓ Display adaptations (3.5" screen)  
**Tested**: ✓ Custom modifications (version, config, flash script)
