---
title: Use Fix Type for Targeted Cleanup
impact: MEDIUM
impactDescription: reduces risk by fixing one category at a time
tags: fix, targeted, incremental, safety
---

## Use Fix Type for Targeted Cleanup

Use `--fix-type` to fix specific issue types incrementally. This reduces risk and makes review easier.

**Incorrect (fixes everything at once):**

```bash
knip --fix
# Removes exports, dependencies, files all at once
# Large diff, hard to review
```

**Correct (fix one type at a time):**

```bash
# Step 1: Fix unused exports
knip --fix-type exports
git diff && npm test && git commit -m "Remove unused exports"

# Step 2: Fix unused dependencies
knip --fix-type dependencies
git diff && npm install && npm test && git commit -m "Remove unused dependencies"

# Step 3: Fix unused types
knip --fix-type types
git diff && npm test && git commit -m "Remove unused types"
```

**Available fix types:**
- `exports` - Remove unused exports
- `types` - Remove unused type exports
- `dependencies` - Remove from package.json
- `enumMembers` - Remove unused enum values
- `classMembers` - Remove unused class members

Reference: [Auto-fix](https://knip.dev/features/auto-fix)
