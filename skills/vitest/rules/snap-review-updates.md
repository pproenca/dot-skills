---
title: Review Snapshot Updates Before Committing
impact: MEDIUM
impactDescription: Prevents bugs from being silently committed via blind snapshot updates
tags: snap, code-review, updates, verification
---

## Review Snapshot Updates Before Committing

Blindly running `vitest -u` and committing updated snapshots is a common source of bugs. Always review snapshot changes to verify they represent intended behavior changes, not regressions.

**Incorrect workflow:**

```bash
# Tests fail
vitest run

# Blindly update all snapshots without reviewing
vitest -u

# Commit without checking what changed
git add -A && git commit -m "Update snapshots"
# Bug shipped - snapshot now contains wrong output
```

**Correct workflow:**

```bash
# Tests fail
vitest run

# Review what's different before updating
git diff

# If changes are intentional, update
vitest -u

# Review the snapshot changes specifically
git diff --cached **/*.snap
git diff --cached **/*.test.ts

# Commit with context
git add -A && git commit -m "Update user serialization to include email field"
```

**Interactive snapshot update:**

```bash
# Watch mode allows reviewing each update
vitest --watch

# Press 'u' to update all snapshots
# Or use 'i' for interactive update (one at a time)
```

**CI protection:**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    steps:
      - run: npx vitest run
      # Fail CI if snapshots are out of date
      # Forces developers to update locally and review
```

**Questions to ask when reviewing:**
- Did I expect this output to change?
- Does the new output look correct?
- Is this change related to my code changes?
- Could this be hiding a regression?

**Benefits:**
- Catches accidental behavior changes
- Maintains snapshot quality as documentation
- Forces intentional changes

Reference: [Vitest Snapshot Updating](https://vitest.dev/guide/snapshot#updating-snapshots)
