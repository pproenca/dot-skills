---
title: Review Auto-Fix Changes Before Commit
impact: MEDIUM
impactDescription: prevents accidental code loss
tags: fix, review, safety, git
---

## Review Auto-Fix Changes Before Commit

Always review auto-fix changes using git diff before committing. Knip may remove code that's used through dynamic patterns it cannot detect.

**Incorrect (blind commit after auto-fix):**

```bash
knip --fix
git add -A && git commit -m "Remove unused code"
# May have removed dynamically used code
```

**Correct (review changes first):**

```bash
knip --fix
git diff

# Review each removal
# Verify no dynamic imports were broken
# Check for pattern-based usage

git add -A && git commit -m "Remove verified unused code"
```

**Staged review workflow:**

```bash
# Step 1: See what would be removed (dry run)
knip

# Step 2: Apply fixes
knip --fix

# Step 3: Review changes
git diff --stat  # Quick overview
git diff         # Detailed review

# Step 4: Test
npm test

# Step 5: Commit
git add -A && git commit -m "Remove unused code verified by Knip"
```

Reference: [Auto-fix](https://knip.dev/features/auto-fix)
