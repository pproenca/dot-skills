---
title: Configure Retries for Flaky Test Recovery
impact: MEDIUM
impactDescription: reduces false negatives from intermittent failures
tags: perf, retries, flaky, reliability, configuration
---

## Configure Retries for Flaky Test Recovery

Some test flakiness is unavoidable (network, timing). Configure retries to automatically recover from intermittent failures, especially in CI.

**Incorrect (no retries, tests fail on first flake):**

```typescript
// playwright.config.ts
export default defineConfig({
  // No retries configured
  // Any flaky test fails the entire CI run
});
```

**Correct (strategic retries):**

```typescript
// playwright.config.ts
export default defineConfig({
  // More retries in CI where flakiness is more common
  retries: process.env.CI ? 2 : 0,

  // Use reporter to track which tests needed retries
  reporter: [
    ['html', { open: 'never' }],
    ['list'],
  ],
});
```

**Retry configuration options:**

```typescript
// playwright.config.ts
export default defineConfig({
  retries: 2,

  // Only rerun failed tests, not entire file
  use: {
    trace: 'on-first-retry', // Capture trace on retry for debugging
    video: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
});
```

**Per-test retry configuration:**

```typescript
// tests/critical.spec.ts
import { test } from '@playwright/test';

// Critical tests get extra retries
test.describe('payment flow', () => {
  test.describe.configure({ retries: 3 });

  test('complete checkout', async ({ page }) => {
    // This test gets 3 retries
  });
});

// Unstable third-party integration
test('external API test', async ({ page }) => {
  test.info().annotations.push({ type: 'flaky', description: 'External API' });
  // ...
});
```

**Identify and fix flaky tests:**

```typescript
// Instead of relying on retries, fix the root cause

// BAD: Flaky due to timing
test('shows notification', async ({ page }) => {
  await page.click('#trigger');
  await page.waitForTimeout(1000); // Hoping it's enough
  await expect(page.getByText('Done')).toBeVisible();
});

// GOOD: Deterministic wait
test('shows notification', async ({ page }) => {
  await page.click('#trigger');
  await expect(page.getByText('Done')).toBeVisible(); // Auto-retries
});
```

**Monitor retry rate:**

```bash
# See which tests are flaky
npx playwright test --reporter=list

# Output shows:
# ✓ [1/2] test name (1.2s) [retry #1]
# Investigate tests that consistently need retries
```

Reference: [Playwright Retries](https://playwright.dev/docs/test-retries)
