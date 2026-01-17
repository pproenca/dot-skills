---
title: Use Bail for Fast Failure in CI
impact: MEDIUM
impactDescription: Saves CI minutes by stopping early when tests fail
tags: perf, bail, ci, fail-fast, early-exit
---

## Use Bail for Fast Failure in CI

When running in CI, continuing after failures wastes time and resources. The `--bail` flag stops test execution after a configurable number of failures, providing faster feedback on broken builds.

**Without bail (runs all tests):**

```bash
# Continues running all 1000 tests even after first failure
npx vitest run
# Takes 10 minutes, reports 50 failures
```

**With bail (stops early):**

```bash
# Stops after first failure
npx vitest run --bail=1
# Takes 30 seconds, reports 1 failure
```

**Configuration:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    bail: process.env.CI ? 1 : 0, // 0 means no bail
  },
})
```

**Higher bail count for flaky detection:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    // Stop after 3 failures - catches multiple issues
    bail: 3,
  },
})
```

**CI workflow with bail:**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    steps:
      - run: npx vitest run --bail=1
      # If tests fail, subsequent steps are skipped
```

**When NOT to use bail:**
- Running full test suite for comprehensive failure report
- Debugging multiple related failures
- Generating complete coverage reports

**Combining with retry:**

```typescript
// vitest.config.ts
export default defineConfig({
  test: {
    bail: 1,
    retry: 2, // Retry flaky tests before bailing
  },
})
```

**Benefits:**
- Faster CI feedback
- Reduced CI costs (fewer compute minutes)
- Developers see failures immediately

Reference: [Vitest CLI Options](https://vitest.dev/guide/cli#options)
