---
title: Fix Unused Files Before Dependencies
impact: HIGH
impactDescription: cascades to correct dependency detection
tags: deps, files, order, workflow
---

## Fix Unused Files Before Dependencies

Dependencies imported in unused files appear as unused dependencies. Fix unused file issues first, then re-run Knip to get accurate dependency reports.

**Incorrect (fixing dependencies while files are unused):**

```bash
knip
# Reports: unused files: src/old-feature.ts
# Reports: unused dependencies: lodash (imported only in src/old-feature.ts)

# User removes lodash from package.json
# Result: src/old-feature.ts still exists, may cause runtime errors
```

**Correct (fix files first, then dependencies):**

```bash
knip --files
# Fix or remove unused files first

knip --dependencies
# Now dependency report is accurate
```

**Filter for focused analysis:**

```bash
# Step 1: Fix unused files
knip --include files

# Step 2: Fix unused dependencies
knip --include dependencies

# Step 3: Fix unused exports
knip --include exports
```

Reference: [Handling Issues](https://knip.dev/guides/handling-issues)
