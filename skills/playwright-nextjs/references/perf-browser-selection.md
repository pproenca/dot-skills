---
title: Select Browsers Strategically
impact: MEDIUM
impactDescription: balance coverage vs execution time
tags: perf, browsers, cross-browser, projects, configuration
---

## Select Browsers Strategically

Testing all browsers on every commit is slow. Run quick Chromium tests on PRs, full cross-browser testing on main branch or nightly.

**Incorrect (all browsers on every run):**

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
    { name: 'mobile-safari', use: { ...devices['iPhone 12'] } },
  ],
  // All 5 browsers run on every commit - 5× the time
});
```

**Correct (tiered browser testing):**

```typescript
// playwright.config.ts
const isCI = process.env.CI;
const isMainBranch = process.env.GITHUB_REF === 'refs/heads/main';

export default defineConfig({
  projects: [
    // Always run Chromium - fastest feedback
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },

    // Cross-browser only on main or scheduled
    ...(isMainBranch || process.env.FULL_TEST
      ? [
          { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
          { name: 'webkit', use: { ...devices['Desktop Safari'] } },
        ]
      : []),
  ],
});
```

**CI workflow with conditional browsers:**

```yaml
# .github/workflows/test.yml
name: Tests

on:
  pull_request:
  push:
    branches: [main]
  schedule:
    - cron: '0 0 * * *' # Nightly

jobs:
  test-quick:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright test --project=chromium

  test-full:
    if: github.ref == 'refs/heads/main' || github.event_name == 'schedule'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright test
        env:
          FULL_TEST: true
```

**Run specific browser locally:**

```bash
# Quick test on Chromium only
npx playwright test --project=chromium

# Full cross-browser test
npx playwright test

# Test specific browser
npx playwright test --project=firefox
```

**Speed comparison:**

| Strategy | Time | Coverage |
|----------|------|----------|
| Chromium only | 1× | 70% of issues |
| Chromium + Firefox | 2× | 90% of issues |
| All 5 browsers | 5× | 99% of issues |

Reference: [Playwright Projects](https://playwright.dev/docs/test-projects)
