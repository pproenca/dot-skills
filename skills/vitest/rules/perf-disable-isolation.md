---
title: Disable Test Isolation When Safe
impact: HIGH
impactDescription: 30-50% faster test execution for well-isolated tests
tags: perf, isolation, no-isolate, speed, configuration
---

## Disable Test Isolation When Safe

By default, Vitest runs each test file in an isolated environment. This ensures tests don't affect each other but adds overhead. For projects with proper cleanup, disabling isolation speeds up execution significantly.

**Default (full isolation):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Default - each file runs in fresh environment
    isolate: true,
  },
})
```

**Optimized (disabled isolation):**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Faster - files share environment
    isolate: false,
  },
})
```

**Prerequisites for disabling isolation:**

1. Tests properly clean up after themselves
2. No global state modification without restoration
3. All mocks are restored in afterEach
4. No test relies on being the first/only test in the environment

**Hybrid approach with projects:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    projects: [
      {
        // Unit tests - safe to share environment
        name: 'unit',
        include: ['src/**/*.test.ts'],
        isolate: false,
      },
      {
        // Integration tests - need isolation
        name: 'integration',
        include: ['tests/integration/**/*.test.ts'],
        isolate: true,
      },
    ],
  },
})
```

**CLI usage:**

```bash
# Quick test with isolation disabled
vitest --no-isolate

# Check for tests that depend on isolation
vitest --no-isolate --reporter=verbose
```

**When NOT to disable isolation:**
- Tests modify global state without cleanup
- Tests use `vi.mock` at the module level without `vi.resetModules`
- Tests have known order dependencies

**Benefits:**
- Faster test suite execution
- Reduced memory usage
- Quicker feedback loops

Reference: [Vitest Improving Performance](https://vitest.dev/guide/improving-performance#test-isolation)
