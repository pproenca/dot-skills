---
title: Separate Production and Default Mode Checks
impact: MEDIUM
impactDescription: catches both shipping code and dev tooling issues
tags: ci, production, modes, comprehensive
---

## Separate Production and Default Mode Checks

Run both production mode and default mode in CI. Production catches shipping code issues; default catches dev tooling waste.

**Incorrect (single mode misses issues):**

```yaml
- run: npx knip --production
# Misses unused test utilities, dev dependencies
```

**Correct (both modes for comprehensive analysis):**

```yaml
jobs:
  knip-production:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx knip --production
        name: Check production code

  knip-all:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
      - run: npm ci
      - run: npx knip
        name: Check all code including dev
```

**Priority order:**
1. Production mode failures are critical (affects users)
2. Default mode failures are important (affects developers)

Reference: [Production Mode](https://knip.dev/features/production-mode)
