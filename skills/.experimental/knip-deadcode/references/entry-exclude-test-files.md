---
title: Exclude Test Files from Production Entries
impact: CRITICAL
impactDescription: prevents test imports from marking production code as used
tags: entry, tests, production, false-negatives
---

## Exclude Test Files from Production Entries

Test files import production code, which marks it as "used". Separate test entries from production entries to detect truly unused production code.

**Incorrect (tests in same entry array, dead code hidden):**

```json
{
  "entry": ["src/**/*.ts"]
}
```

**Correct (test entries via plugin, production entries separate):**

```json
{
  "entry": ["src/index.ts", "src/cli.ts"],
  "jest": {
    "entry": ["**/*.test.ts", "**/*.spec.ts"]
  }
}
```

**For production mode analysis:**

```json
{
  "entry": ["src/index.ts!", "src/cli.ts!"],
  "project": ["src/**/*.ts!", "!src/**/*.test.ts"]
}
```

Run with `--production` to analyze only shipping code and catch dead code that tests artificially keep alive.

Reference: [Production Mode](https://knip.dev/features/production-mode)
