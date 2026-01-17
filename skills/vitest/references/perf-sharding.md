---
title: Use Sharding for CI Parallelization
impact: HIGH
impactDescription: Linear speedup with additional CI nodes (3 nodes = ~3× faster)
tags: perf, sharding, ci, parallel, github-actions
---

## Use Sharding for CI Parallelization

Sharding splits your test suite across multiple CI machines. Each machine runs a subset of tests in parallel, providing near-linear speedup with additional nodes.

**Without sharding (single node):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx vitest run
```

**With sharding (multiple nodes):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3]
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx vitest run --reporter=blob --shard=${{ matrix.shard }}/3

  merge-reports:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - uses: actions/download-artifact@v4
      - run: npx vitest --merge-reports
```

**Blob reporter for merged results:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    reporters: process.env.CI ? ['blob'] : ['default'],
  },
})
```

**Coverage with sharding:**

```yaml
jobs:
  test:
    strategy:
      matrix:
        shard: [1, 2, 3]
    steps:
      - run: npx vitest run --coverage --shard=${{ matrix.shard }}/3

  merge:
    needs: test
    steps:
      - run: npx vitest --merge-reports --coverage
```

**Optimal shard count:**

| Test Suite Size | Recommended Shards |
|-----------------|-------------------|
| < 100 tests | 1-2 |
| 100-500 tests | 2-4 |
| 500-1000 tests | 4-6 |
| > 1000 tests | 6-10 |

**Benefits:**
- Near-linear speedup with additional nodes
- Merged coverage and reports
- Works with any CI system

Reference: [Vitest Test Sharding](https://vitest.dev/guide/improving-performance#sharding)
