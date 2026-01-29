---
title: Use Negation Patterns for Exclusions
impact: CRITICAL
impactDescription: prevents false positives without hiding real issues
tags: config, patterns, negation, globs
---

## Use Negation Patterns for Exclusions

Use `!` prefix in glob patterns to exclude specific files from entry or project patterns. This is more precise than using `ignore`.

**Incorrect (broad ignore hides legitimate issues):**

```json
{
  "entry": ["src/**/*.ts"],
  "ignore": ["src/generated/**"]
}
```

**Correct (negation in pattern, scoped exclusion):**

```json
{
  "entry": ["src/**/*.ts", "!src/generated/**/*.ts"],
  "project": ["src/**/*.ts", "!src/**/*.generated.ts"]
}
```

**When to use `ignore` vs negation:**
- Negation patterns: Exclude from specific entry/project arrays
- `ignore`: Suppress all issue types for matching files globally

Reference: [Knip Configuration](https://knip.dev/reference/configuration)
