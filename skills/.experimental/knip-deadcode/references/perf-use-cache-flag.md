---
title: Enable Cache for Repeated Analysis
impact: LOW-MEDIUM
impactDescription: 10-40% faster subsequent runs
tags: perf, cache, speed, optimization
---

## Enable Cache for Repeated Analysis

Enable Knip's built-in cache for faster repeated analysis. The cache stores module resolution results between runs.

**Incorrect (full analysis every time):**

```bash
knip  # 30 seconds
knip  # 30 seconds again
```

**Correct (cached analysis):**

```bash
knip --cache  # 30 seconds (builds cache)
knip --cache  # 18-20 seconds (uses cache)
```

**Permanent configuration:**

```json
{
  "$schema": "https://unpkg.com/knip@5/schema.json",
  "cache": true
}
```

**Custom cache location:**

```json
{
  "cache": true,
  "cacheLocation": ".cache/knip"
}
```

**Clear cache when needed:**

```bash
rm -rf node_modules/.cache/knip
```

**When cache helps most:**
- Large monorepos with many packages
- Repeated local development runs
- CI with cached node_modules

Reference: [Knip CLI](https://knip.dev/reference/cli)
