---
title: Use Network Idle for Complex Pages
impact: HIGH
impactDescription: waits for all resources to load
tags: wait, networkidle, navigation, loading, complex-pages
---

## Use Network Idle for Complex Pages

For pages with multiple API calls or lazy-loaded resources, `waitUntil: 'networkidle'` ensures all requests complete before assertions. Use judiciously—it can slow tests on pages with continuous polling.

**Incorrect (default navigation may finish too early):**

```typescript
// tests/analytics.spec.ts
test('shows complete analytics dashboard', async ({ page }) => {
  // Default 'load' event fires before all XHR requests complete
  await page.goto('/analytics');

  // May fail because chart data isn't loaded yet
  await expect(page.getByTestId('revenue-chart')).toBeVisible();
  await expect(page.getByTestId('users-chart')).toBeVisible();
  await expect(page.getByTestId('conversion-chart')).toBeVisible();
});
```

**Correct (wait for network idle):**

```typescript
// tests/analytics.spec.ts
test('shows complete analytics dashboard', async ({ page }) => {
  // Wait until no network requests for 500ms
  await page.goto('/analytics', { waitUntil: 'networkidle' });

  // All data loaded, charts rendered
  await expect(page.getByTestId('revenue-chart')).toBeVisible();
  await expect(page.getByTestId('users-chart')).toBeVisible();
  await expect(page.getByTestId('conversion-chart')).toBeVisible();
});
```

**Wait until options explained:**

```typescript
// 'domcontentloaded' - DOM is ready (fastest)
await page.goto('/page', { waitUntil: 'domcontentloaded' });

// 'load' - page fully loaded including images (default)
await page.goto('/page', { waitUntil: 'load' });

// 'networkidle' - no network requests for 500ms (slowest but most complete)
await page.goto('/page', { waitUntil: 'networkidle' });

// 'commit' - network response received (fastest, for SPAs)
await page.goto('/page', { waitUntil: 'commit' });
```

**When NOT to use networkidle:**

```typescript
// Pages with WebSocket connections or polling
// These never become truly "idle"

test('chat page loads', async ({ page }) => {
  // Don't use networkidle - WebSocket keeps connection open
  await page.goto('/chat', { waitUntil: 'domcontentloaded' });

  // Wait for specific content instead
  await expect(page.getByTestId('chat-messages')).toBeVisible();
});
```

**Alternative: wait for specific requests:**

```typescript
test('dashboard loads with data', async ({ page }) => {
  // More precise than networkidle
  const responsePromise = page.waitForResponse('/api/dashboard-data');
  await page.goto('/dashboard');
  await responsePromise;

  await expect(page.getByTestId('dashboard-content')).toBeVisible();
});
```

Reference: [Playwright Navigation](https://playwright.dev/docs/navigations)
