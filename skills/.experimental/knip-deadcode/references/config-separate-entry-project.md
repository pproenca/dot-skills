---
title: Separate Entry Files from Project Files
impact: CRITICAL
impactDescription: eliminates false positives from test file imports
tags: config, entry, project, patterns
---

## Separate Entry Files from Project Files

Entry files define starting points for dependency resolution. Project files define the full scope of files to check for unused status. Mixing them causes false positives.

**Incorrect (tests included in entry, production code appears used):**

```json
{
  "entry": ["src/**/*.ts"],
  "project": ["src/**/*.ts"]
}
```

**Correct (entry for production, project for all files):**

```json
{
  "entry": ["src/index.ts", "src/cli.ts"],
  "project": ["src/**/*.ts", "!src/**/*.test.ts"]
}
```

**Note:** Files in `project` but not reachable from `entry` are reported as unused. This is the intended behavior for detecting orphaned files.

Reference: [Configuring Project Files](https://knip.dev/guides/configuring-project-files)
