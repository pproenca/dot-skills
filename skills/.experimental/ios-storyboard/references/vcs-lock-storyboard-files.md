---
title: Use Git File Locking for Active Storyboard Edits
impact: LOW-MEDIUM
impactDescription: prevents parallel editing of the same storyboard
tags: vcs, git-lfs, locking, collaboration
---

## Use Git File Locking for Active Storyboard Edits

Even with well-split storyboards, two developers occasionally need to edit the same file (e.g., during a design system migration). Git LFS file locking provides an advisory lock that signals to the team that a storyboard is being actively edited, preventing a second developer from starting work that will inevitably conflict.

**Incorrect (no locking, two developers unknowingly edit the same storyboard):**

```bash
# Developer A starts working on Checkout.storyboard
# No signal to the team — Developer B also opens Checkout.storyboard

# Hours later, Developer B pushes first
git add Checkout.storyboard
git commit -m "Update payment form layout"
git push

# Developer A tries to push and gets a merge conflict in XML
git push
# error: failed to push — diverged history on Checkout.storyboard
# Manual XML merge required — high risk of corruption
```

**Correct (git lfs lock prevents parallel edits):**

First, configure LFS tracking for storyboard files:

```bash
# One-time setup
git lfs install
git lfs track "*.storyboard"
git add .gitattributes
git commit -m "Track storyboards with Git LFS"
```

Then lock before editing and unlock after committing:

```bash
# Developer A locks the file before starting work
git lfs lock Checkout.storyboard
# Lock acquired: Checkout.storyboard (by sarah)

# Developer B attempts to edit
git lfs lock Checkout.storyboard
# Lock failed: already locked by sarah

# Developer A finishes, commits, and unlocks
git add Checkout.storyboard
git commit -m "Update payment form layout"
git lfs unlock Checkout.storyboard
```

List all current locks to see who is editing which storyboard:

```bash
git lfs locks
# Checkout.storyboard    sarah    ID:123
```

**When NOT to use:**

Teams that have already split storyboards to one-scene-per-file granularity rarely need locking. The overhead of lock/unlock is only justified when storyboard files are shared across developers.

Reference: [Git LFS File Locking](https://github.com/git-lfs/git-lfs/wiki/File-Locking)
