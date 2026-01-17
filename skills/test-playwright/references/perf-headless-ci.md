---
title: Use Headless Mode in CI
impact: MEDIUM
impactDescription: 30-40% faster execution, less resource usage
tags: perf, headless, ci, performance, configuration
---

## Use Headless Mode in CI

Running browsers in headless mode (no visible UI) is faster and uses less memory. Enable it in CI environments.

**Incorrect (headed mode in CI):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    headless: false, // Shows browser UI - slow and resource-intensive
  },
});
```

**Correct (headless in CI, headed locally for debugging):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Headless in CI, headed when debugging locally
    headless: process.env.CI ? true : false,
  },
});
```

**Or use CLI flag:**

```bash
# CI: headless by default
npx playwright test

# Local debugging: headed
npx playwright test --headed

# Debug with Playwright Inspector
npx playwright test --debug
```

**Project-specific headless config:**

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        headless: true,
      },
    },
    {
      name: 'debug',
      use: {
        ...devices['Desktop Chrome'],
        headless: false,
        launchOptions: {
          slowMo: 100, // Slow down for visual debugging
        },
      },
    },
  ],
});

// Run headless
// npx playwright test --project=chromium

// Run headed for debugging
// npx playwright test --project=debug
```

**Performance comparison:**

| Mode | Speed | Memory | Use Case |
|------|-------|--------|----------|
| Headless | 100% | ~100MB | CI, automated runs |
| Headed | 60-70% | ~300MB | Debugging, demos |
| Headed + slowMo | 30-50% | ~300MB | Step-by-step debugging |

**CI configuration example:**

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: npx playwright test
  env:
    CI: true
    # Playwright automatically runs headless when CI=true
```

Reference: [Playwright Test Configuration](https://playwright.dev/docs/test-configuration#testing-options)
