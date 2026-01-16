---
title: Choose the Right Pool for Performance
impact: HIGH
impactDescription: 2-5× performance difference between pool types on large test suites
tags: perf, pool, threads, forks, workers, configuration
---

## Choose the Right Pool for Performance

Vitest supports different execution pools: `forks` (default), `threads`, and `vmThreads`. The default `forks` prioritizes compatibility but can be significantly slower. Consider `threads` for better performance.

**Default (forks pool):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Default - most compatible, but can be slower
    pool: 'forks',
  },
})
```

**Optimized (threads pool):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Generally faster, but some edge cases may not work
    pool: 'threads',
  },
})
```

**Pool comparison:**

| Pool | Speed | Isolation | Compatibility | Best For |
|------|-------|-----------|---------------|----------|
| `forks` | Slower | Full process | Highest | Default, native modules |
| `threads` | Faster | Worker threads | High | Most projects |
| `vmThreads` | Medium | VM contexts | Medium | Memory-constrained |

**Tuning thread count:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    pool: 'threads',
    poolOptions: {
      threads: {
        // Match CPU cores for compute-bound tests
        minThreads: 1,
        maxThreads: 4,
      },
    },
  },
})
```

**CLI usage:**

```bash
# Quick switch to threads pool
vitest --pool=threads

# Check if it improves your suite
vitest --pool=threads --reporter=verbose
```

**When to use forks:**
- Tests use native modules that don't work with worker threads
- Tests have compatibility issues with threads pool
- You need full process isolation

**Benefits:**
- Significant speedup for large test suites
- Better resource utilization
- Faster CI/CD feedback

Reference: [Vitest Pool Configuration](https://vitest.dev/config/#pool)
