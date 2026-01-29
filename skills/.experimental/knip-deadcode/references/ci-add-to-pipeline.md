---
title: Add Knip to CI Pipeline
impact: MEDIUM
impactDescription: prevents dead code regressions over time
tags: ci, github-actions, pipeline, automation
---

## Add Knip to CI Pipeline

Run Knip in CI to catch dead code before it merges. This prevents accumulation of unused files, dependencies, and exports.

**Incorrect (no CI check, dead code accumulates):**

```yaml
# No Knip step in CI
name: CI
on: push
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm test
```

**Correct (Knip check in CI):**

```yaml
name: CI
on: push
jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: 20
          cache: npm
      - run: npm ci --ignore-scripts
      - run: npx knip
```

**Add to package.json scripts:**

```json
{
  "scripts": {
    "knip": "knip",
    "lint": "eslint . && knip"
  }
}
```

Reference: [Using Knip in CI](https://knip.dev/guides/using-knip-in-ci)
