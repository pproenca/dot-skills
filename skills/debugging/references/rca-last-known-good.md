---
title: Find the Last Known Good State
impact: HIGH
impactDescription: O(log n) regression detection via git bisect; establishes working baseline
tags: rca, regression, baseline, good-state, git-bisect
---

## Find the Last Known Good State

Identify when the code last worked correctly. Comparing working vs broken states reveals what changed and caused the bug. This is especially effective for regressions.

**Incorrect (debugging without baseline):**

```bash
# Bug: "Search feature doesn't work"
# Developer looks at current code trying to find bug
# No reference point for what "working" looks like
# Hours of reading code without knowing what changed
```

**Correct (find last known good state):**

```bash
# Bug: "Search feature doesn't work"

# Step 1: When did it last work?
# "It worked last Tuesday, stopped working after Wednesday deploy"

# Step 2: Find the last working commit
git log --oneline --since="last Tuesday" --until="Wednesday"
# abc123 (Wednesday) Add search filters
# def456 (Tuesday) Update search index
# ghi789 (Tuesday) Fix search pagination  ← Last known working

# Step 3: Compare working vs broken
git diff ghi789 abc123 -- src/search/

# Step 4: The diff shows exactly what changed
# Found: Search filters broke when no filters selected
```

**Using git bisect for automated search:**

```bash
# Automated binary search through commits
git bisect start
git bisect bad HEAD                  # Current is broken
git bisect good ghi789              # Tuesday commit worked

# Git checks out middle commit, test it:
npm test -- --grep "search"
# If tests pass:
git bisect good
# If tests fail:
git bisect bad

# Repeat until:
# abc123 is the first bad commit
# This commit introduced the bug
```

**Finding last known good without git:**

```python
# Check different data states
working_data = load_from_backup("tuesday_backup.json")
broken_data = load_from_current()

# Compare
def compare_data(good, bad):
    for key in good:
        if good[key] != bad[key]:
            print(f"Difference in {key}:")
            print(f"  Good: {good[key]}")
            print(f"  Bad: {bad[key]}")

compare_data(working_data, broken_data)
```

**When NOT to use this pattern:**
- Bug existed since feature was created (no "good" state)
- Bug depends on external state that can't be reproduced

Reference: [Git Bisect](https://git-scm.com/docs/git-bisect)
