---
title: Use Production Mode for Shipping Code Analysis
impact: CRITICAL
impactDescription: focuses on code that reaches users, reduces noise
tags: config, production, mode, shipping
---

## Use Production Mode for Shipping Code Analysis

Production mode analyzes only the code you ship, excluding tests, stories, and dev tooling. This catches dead code that affects bundle size and user experience.

**Incorrect (default mode includes test dependencies):**

```bash
knip
```

**Correct (production mode for shipping code):**

```bash
knip --production
```

**Configuration with production markers:**

```json
{
  "entry": [
    "src/index.ts!",
    "src/cli.ts!"
  ],
  "project": [
    "src/**/*.ts!",
    "!src/**/*.test.ts"
  ]
}
```

The `!` suffix marks patterns for production mode. Only these patterns are analyzed when running `--production`.

**Strict production mode:**

```bash
knip --production --strict
```

Strict mode also enforces workspace isolation and includes peer dependencies.

Reference: [Production Mode](https://knip.dev/features/production-mode)
