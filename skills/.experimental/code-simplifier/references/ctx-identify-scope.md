---
title: Identify Recently Modified Code as Default Scope
impact: CRITICAL
impactDescription: Focuses simplification effort on code 10x more likely to need changes
tags: ctx, scope, git-history, targeting
---

## Identify Recently Modified Code as Default Scope

Not all code benefits equally from simplification. Recently modified files contain active development areas where simplification provides immediate value. Cold code that hasn't changed in months is likely stable and low-priority. Use git history to identify hot spots and focus simplification efforts where they matter most.

**Incorrect (simplifying random old code without checking activity):**

```bash
# Developer picks a file at random to simplify
# File hasn't been touched in 2 years and works fine

# utils/legacy-formatter.js - last modified 2022-03-15
# 47 lines of working code that no one has needed to change

# Result: PR sits in review for weeks, no one has context
# Risk: Introduces bugs in stable, untested legacy code
```

**Correct (checking git history to find active areas):**

```bash
# First, identify recently modified files
git log --since="30 days ago" --name-only --pretty=format: | sort | uniq -c | sort -rn | head -20

# Output shows hot spots:
#  15 src/api/user-service.ts
#  12 src/components/Dashboard.tsx
#   8 src/utils/validation.ts

# Focus simplification on user-service.ts - actively being worked on
# Team has context, tests are fresh, benefits are immediate
```

**Scoping strategies:**

- `git log --since="30 days ago"` for recent activity
- `git blame` to understand who owns which sections
- Look for files with many recent commits (churn indicates complexity)
- Prioritize files mentioned in open PRs or recent issues

**When NOT to use:**

- When specifically asked to simplify a legacy module
- During dedicated refactoring sprints with allocated time
- When preparing code for deprecation

**Benefits:**

- Simplifications ship faster with available reviewers
- Reduces risk of breaking untested legacy code
- Aligns with natural development momentum
- Changes are more likely to be maintained

**References:**

- `git shortlog -sn --since="90 days ago"` to find active contributors
- Check issue tracker for related tickets
