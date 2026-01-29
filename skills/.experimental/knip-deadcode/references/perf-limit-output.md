---
title: Limit Output for Large Codebases
impact: LOW-MEDIUM
impactDescription: prevents terminal overflow and improves readability
tags: perf, output, limit, readability
---

## Limit Output for Large Codebases

Use `--max-show-issues` to limit output when dealing with many issues. This prevents terminal overflow and makes output actionable.

**Incorrect (thousands of issues overwhelm terminal):**

```bash
knip
# 5000 lines of output, terminal buffer exceeded
# Can't scroll back to see important issues
```

**Correct (limited output with counts):**

```bash
knip --max-show-issues 50
# Shows first 50 issues per type
# Displays total count for context
```

**Progressive cleanup workflow:**

```bash
# Step 1: See scope of problem
knip --max-show-issues 10
# "Showing 10 of 500 unused exports"

# Step 2: Fix a batch
knip --fix-type exports --max-show-issues 50

# Step 3: Repeat until clean
knip --max-show-issues 10
# "No issues found"
```

**Combine with filtering:**

```bash
knip --include exports --max-show-issues 20
# Focus on exports, limit to 20
```

Reference: [Knip CLI](https://knip.dev/reference/cli)
