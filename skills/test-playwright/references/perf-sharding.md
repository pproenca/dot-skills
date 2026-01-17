---
title: Use Sharding for Large Test Suites
impact: MEDIUM
impactDescription: 50-80% faster CI with distributed execution
tags: perf, sharding, ci, parallel, distribution
---

## Use Sharding for Large Test Suites

For large test suites, split tests across multiple CI machines using sharding. Each shard runs a portion of tests in parallel.

**Incorrect (single machine runs all tests):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright test
      # All 500 tests run on one machine - takes 30 minutes
```

**Correct (sharded across machines):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test --shard=${{ matrix.shard }}/4
      # Each machine runs ~125 tests - total time ~8 minutes
```

**Merge test reports from shards:**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright test --shard=${{ matrix.shard }}/4
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: blob-report-${{ matrix.shard }}
          path: blob-report
          retention-days: 1

  merge-reports:
    needs: test
    runs-on: ubuntu-latest
    if: always()
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - uses: actions/download-artifact@v4
        with:
          pattern: blob-report-*
          merge-multiple: true
          path: all-blob-reports
      - run: npx playwright merge-reports --reporter html ./all-blob-reports
      - uses: actions/upload-artifact@v4
        with:
          name: html-report
          path: playwright-report
```

**Configure blob reporter for sharding:**

```typescript
// playwright.config.ts
export default defineConfig({
  reporter: process.env.CI
    ? [['blob'], ['github']] // Blob for merging, GitHub for annotations
    : [['html', { open: 'never' }]],
});
```

**Optimal shard count:**

| Test Count | Recommended Shards |
|------------|-------------------|
| < 50 | 1 (no sharding) |
| 50-200 | 2-4 |
| 200-500 | 4-8 |
| 500+ | 8-16 |

Reference: [Playwright Sharding](https://playwright.dev/docs/test-sharding)
