---
title: Enable Cache for Faster CI Runs
impact: MEDIUM
impactDescription: 10-40% faster CI pipeline
tags: ci, cache, performance, speed
---

## Enable Cache for Faster CI Runs

Enable Knip's built-in cache for 10-40% faster analysis on subsequent runs. Cache persists analysis results between CI runs.

**Incorrect (full analysis every run):**

```yaml
- run: npx knip
```

**Correct (cache enabled for speed):**

```yaml
- name: Cache Knip results
  uses: actions/cache@v4
  with:
    path: node_modules/.cache/knip
    key: knip-${{ hashFiles('**/package-lock.json') }}
    restore-keys: knip-

- run: npx knip --cache
```

**Set custom cache location:**

```bash
knip --cache --cache-location .cache/knip
```

**In configuration:**

```json
{
  "cache": true
}
```

**Note:** Cache invalidates when dependencies change. The cache key should include lock file hash for correctness.

Reference: [Knip CLI](https://knip.dev/reference/cli)
