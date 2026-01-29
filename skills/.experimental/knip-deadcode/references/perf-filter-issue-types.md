---
title: Filter Issue Types for Focused Analysis
impact: LOW-MEDIUM
impactDescription: reduces output noise and processing time
tags: perf, filter, include, exclude
---

## Filter Issue Types for Focused Analysis

Use `--include` or `--exclude` to analyze only specific issue types. This reduces output noise and can speed up analysis.

**Incorrect (analyzing everything when focused on exports):**

```bash
knip
# 500 lines of output across all issue types
# Hard to find export issues
```

**Correct (focused on specific issue type):**

```bash
# Only exports
knip --include exports

# Only dependencies
knip --include dependencies

# Exports and types
knip --include exports,types
```

**Use shorthands for common patterns:**

```bash
# All dependency-related issues
knip --dependencies

# All export-related issues
knip --exports

# Only file issues
knip --files
```

**Exclude noisy issue types:**

```bash
# Skip enum members and duplicates
knip --exclude enumMembers,duplicates
```

Reference: [Rules & Filters](https://knip.dev/features/rules-and-filters)
