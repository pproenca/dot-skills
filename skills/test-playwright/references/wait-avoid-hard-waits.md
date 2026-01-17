---
title: Avoid Hard Waits
impact: HIGH
impactDescription: hard waits waste time or cause flakiness
tags: wait, timeout, waitForTimeout, anti-pattern, timing
---

## Avoid Hard Waits

`waitForTimeout` pauses for a fixed duration regardless of actual state. If the app is faster, you waste time. If slower, tests fail. Use auto-waiting or specific wait conditions instead.

**Incorrect (hard waits):**

```typescript
// tests/dashboard.spec.ts
test('loads dashboard data', async ({ page }) => {
  await page.goto('/dashboard');

  // WRONG: arbitrary wait, might be too short or too long
  await page.waitForTimeout(3000);
  await expect(page.getByTestId('stats-panel')).toBeVisible();

  await page.getByRole('button', { name: 'Refresh' }).click();

  // WRONG: guessing how long refresh takes
  await page.waitForTimeout(2000);
  await expect(page.getByText('Updated')).toBeVisible();
});
```

**Correct (specific wait conditions):**

```typescript
// tests/dashboard.spec.ts
test('loads dashboard data', async ({ page }) => {
  await page.goto('/dashboard');

  // Wait for specific element to appear
  await expect(page.getByTestId('stats-panel')).toBeVisible();

  await page.getByRole('button', { name: 'Refresh' }).click();

  // Wait for network request to complete
  await page.waitForResponse(
    (response) =>
      response.url().includes('/api/stats') && response.status() === 200
  );

  await expect(page.getByText('Updated')).toBeVisible();
});
```

**Alternative wait strategies:**

```typescript
// Wait for loading indicator to disappear
await expect(page.getByTestId('loading-spinner')).toBeHidden();

// Wait for specific network request
await page.waitForResponse('/api/users');

// Wait for navigation to complete
await Promise.all([
  page.waitForNavigation(),
  page.getByRole('link', { name: 'Profile' }).click(),
]);

// Wait for element state
await page.getByRole('button', { name: 'Submit' }).waitFor({ state: 'visible' });

// Wait for function condition
await page.waitForFunction(() => {
  return document.querySelector('.data-table')?.children.length > 0;
});
```

**When hard waits are acceptable (rare):**

```typescript
// Testing debounce behavior (intentional delay)
test('search debounces input', async ({ page }) => {
  await page.getByLabel('Search').fill('test');
  // Intentional: testing that search doesn't trigger immediately
  await page.waitForTimeout(100);
  await expect(page.getByTestId('search-results')).toBeHidden();

  // After debounce period, results appear
  await expect(page.getByTestId('search-results')).toBeVisible();
});
```

Reference: [Playwright Auto-Waiting](https://playwright.dev/docs/actionability)
