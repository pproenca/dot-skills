---
title: Check Recent Changes First
impact: CRITICAL
impactDescription: 80%+ of bugs are caused by recent changes; reduces search space dramatically
tags: prob, git, changes, regression, bisect
---

## Check Recent Changes First

Most bugs are introduced by recent changes. Before deep investigation, check what changed since the code last worked correctly. This dramatically reduces your search space.

**Incorrect (ignoring change history):**

```bash
# Bug report: "Login stopped working yesterday"

# Developer starts reading the entire auth codebase
# 50 files, 5000 lines of code to review
# 4 hours later, still searching...
```

**Correct (check recent changes):**

```bash
# Bug report: "Login stopped working yesterday"

# Step 1: When did it last work?
git log --oneline --since="3 days ago" -- src/auth/

# Output:
# a1b2c3d Add rate limiting to login endpoint
# e4f5g6h Update password validation regex
# i7j8k9l Refactor session handling

# Step 2: Check the suspicious commits
git show e4f5g6h  # Password validation change

# Found it! Regex now rejects valid passwords with special chars
# 10 minutes instead of 4 hours
```

**Using git bisect for systematic search:**

```bash
# When you know a good commit and bad commit
git bisect start
git bisect bad HEAD                    # Current version is broken
git bisect good v2.0.0                 # This version worked
# Git checks out middle commit
# Test and mark as good or bad
git bisect good  # or: git bisect bad
# Repeat until Git identifies the first bad commit

# Automate with a test script:
git bisect run npm test -- --grep "login"
```

**Change investigation checklist:**
- What was the last known working version/date?
- What commits/deploys happened since then?
- Who made changes to related code?
- Were there any config/environment changes?
- Did dependencies update?

**When NOT to use this pattern:**
- Bug has existed unnoticed for a long time
- Legacy code with unclear change history
- Issues caused by external factors (data, load, third-party services)

Reference: [Git Bisect Documentation](https://git-scm.com/docs/git-bisect)
