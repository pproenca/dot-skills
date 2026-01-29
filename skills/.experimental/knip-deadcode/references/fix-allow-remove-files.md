---
title: Explicitly Allow File Removal
impact: MEDIUM
impactDescription: prevents accidental file deletion
tags: fix, files, removal, safety
---

## Explicitly Allow File Removal

File removal requires explicit opt-in with `--allow-remove-files`. This prevents accidental deletion of files that may be used through patterns Knip cannot detect.

**Incorrect (trying to remove files without flag):**

```bash
knip --fix
# Unused files are not removed
# User confused why files remain
```

**Correct (explicitly enable file removal):**

```bash
# First, review what would be removed
knip --include files

# If all listed files are truly unused, enable removal
knip --fix --allow-remove-files
```

**Safer workflow with backup:**

```bash
# Create backup branch
git checkout -b backup/before-knip-cleanup

# Return to main branch
git checkout main

# Remove files with confidence
knip --fix --allow-remove-files

# Review removals
git status
git diff --cached

# If something wrong, restore from backup
git checkout backup/before-knip-cleanup -- path/to/file.ts
```

Reference: [Auto-fix](https://knip.dev/features/auto-fix)
