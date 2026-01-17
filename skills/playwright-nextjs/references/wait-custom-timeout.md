---
title: Configure Timeouts Appropriately
impact: MEDIUM
impactDescription: balance between flakiness and fast feedback
tags: wait, timeout, configuration, playwright-config, timing
---

## Configure Timeouts Appropriately

Default timeouts may be too short for slow pages or too long for fast feedback. Configure timeouts based on your application's actual performance characteristics.

**Incorrect (default timeouts causing issues):**

```typescript
// playwright.config.ts
export default defineConfig({
  // Default: 30s test timeout might be too short for slow CI
  // Default: 5s assertion timeout might miss slow API responses
});

// tests/heavy-page.spec.ts
test('loads data visualization', async ({ page }) => {
  await page.goto('/analytics'); // Times out on slow networks
  await expect(page.getByTestId('chart')).toBeVisible(); // Times out waiting for data
});
```

**Correct (tuned timeouts):**

```typescript
// playwright.config.ts
export default defineConfig({
  // Global test timeout
  timeout: 60000, // 60s for tests

  // Assertion timeout
  expect: {
    timeout: 10000, // 10s for assertions
  },

  // Navigation timeout
  use: {
    navigationTimeout: 30000, // 30s for page loads
    actionTimeout: 15000, // 15s for actions like click
  },
});
```

**Per-test timeout overrides:**

```typescript
// For a single slow test
test('generates large report', async ({ page }) => {
  test.setTimeout(120000); // 2 minutes for this test only

  await page.goto('/reports/generate');
  await page.getByRole('button', { name: 'Generate Full Report' }).click();

  // This assertion gets extra time
  await expect(page.getByText('Report ready')).toBeVisible({
    timeout: 60000,
  });
});
```

**Environment-specific timeouts:**

```typescript
// playwright.config.ts
export default defineConfig({
  timeout: process.env.CI ? 60000 : 30000,

  expect: {
    timeout: process.env.CI ? 15000 : 5000,
  },

  use: {
    navigationTimeout: process.env.CI ? 45000 : 15000,
  },
});
```

**Timeout debugging:**

```typescript
// Add test info to understand where time is spent
test('slow page investigation', async ({ page }) => {
  const start = Date.now();

  await page.goto('/dashboard');
  console.log(`Navigation: ${Date.now() - start}ms`);

  await expect(page.getByTestId('content')).toBeVisible();
  console.log(`Content visible: ${Date.now() - start}ms`);
});
```

Reference: [Playwright Timeouts](https://playwright.dev/docs/test-timeouts)
