---
title: Use Watch Mode for Local Development
impact: MEDIUM
impactDescription: instant feedback on dead code during development
tags: ci, watch, development, feedback
---

## Use Watch Mode for Local Development

Use `--watch` during development to get instant feedback on dead code. Knip re-analyzes when files change.

**Incorrect (manual runs after each change):**

```bash
# Make changes
knip
# Make more changes
knip
# Repeat...
```

**Correct (continuous analysis with watch):**

```bash
knip --watch
```

Output updates as you save files:
```text
Watching for file changes...
[12:34:56] Change detected: src/utils.ts
[12:34:57] ✓ No issues found

[12:35:10] Change detected: src/legacy.ts
[12:35:11] Found 2 unused exports
  - formatLegacyDate
  - parseLegacyString
```

**Combine with filters for focused feedback:**

```bash
knip --watch --include exports
# Only watches for unused exports
```

**When to use watch mode:**
- During refactoring sessions
- When cleaning up dead code
- When learning codebase structure

**Note:** Watch mode is for local development, not CI.

Reference: [Knip CLI](https://knip.dev/reference/cli)
