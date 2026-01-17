---
title: Enable Parallel Test Execution
impact: CRITICAL
impactDescription: 2-10× faster test suites
tags: arch, parallel, workers, performance, configuration
---

## Enable Parallel Test Execution

Running tests sequentially wastes CI time. Playwright supports parallel execution at both file and test level—configure workers based on your CI resources.

**Incorrect (sequential execution):**

```typescript
// playwright.config.ts
export default defineConfig({
  workers: 1, // Forces sequential execution
  fullyParallel: false,
});

// Test suite takes 10 minutes
```

**Correct (parallel execution):**

```typescript
// playwright.config.ts
export default defineConfig({
  // Use 50% of available CPUs, minimum 1
  workers: process.env.CI ? 4 : undefined,
  fullyParallel: true,
});

// tests/dashboard.spec.ts
import { test } from '@playwright/test';

test.describe.configure({ mode: 'parallel' });

test('loads user stats', async ({ page }) => {
  await page.goto('/dashboard/stats');
  await expect(page.getByTestId('stats-panel')).toBeVisible();
});

test('loads notifications', async ({ page }) => {
  await page.goto('/dashboard/notifications');
  await expect(page.getByTestId('notification-list')).toBeVisible();
});

test('loads settings', async ({ page }) => {
  await page.goto('/dashboard/settings');
  await expect(page.getByTestId('settings-form')).toBeVisible();
});
```

**When NOT to use parallel execution:**
- Tests that modify shared database state
- Tests that use the same external service account
- Tests with intentional sequential dependencies

Reference: [Playwright Parallelism](https://playwright.dev/docs/test-parallel)
