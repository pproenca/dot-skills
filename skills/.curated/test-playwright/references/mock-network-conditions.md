---
title: Simulate Network Conditions
impact: MEDIUM
impactDescription: validates offline and slow network behavior
tags: mock, network, offline, slow, throttle
---

## Simulate Network Conditions

Test how your app behaves under poor network conditions. Playwright can simulate slow networks, offline mode, and connection changes.

**Incorrect (no network condition testing):**

```typescript
// tests/dashboard.spec.ts
test('dashboard works', async ({ page }) => {
  // Only tests happy path with good network
  await page.goto('/dashboard');
  await expect(page.getByTestId('content')).toBeVisible();

  // Never tests:
  // - What happens when user goes offline?
  // - Does loading state appear on slow networks?
  // - Does the app recover after network failures?
});
```

**Correct (test network conditions):**

```typescript
// tests/dashboard.spec.ts
test('shows offline message when disconnected', async ({ page, context }) => {
  await page.goto('/dashboard');

  // Go offline
  await context.setOffline(true);

  // Trigger a network request
  await page.getByRole('button', { name: 'Refresh' }).click();

  // Should show offline message
  await expect(page.getByText('You are offline')).toBeVisible();

  // Go back online
  await context.setOffline(false);
  await page.getByRole('button', { name: 'Retry' }).click();

  // Should recover
  await expect(page.getByTestId('data-content')).toBeVisible();
});
```

**Simulating slow network:**

```typescript
test('shows loading states on slow network', async ({ page }) => {
  // Throttle network requests
  const client = await page.context().newCDPSession(page);
  await client.send('Network.emulateNetworkConditions', {
    offline: false,
    downloadThroughput: (50 * 1024) / 8, // 50kb/s
    uploadThroughput: (20 * 1024) / 8, // 20kb/s
    latency: 500, // 500ms latency
  });

  await page.goto('/dashboard');

  // Loading state should be visible due to slow network
  await expect(page.getByTestId('loading-skeleton')).toBeVisible();

  // Eventually content loads
  await expect(page.getByTestId('dashboard-content')).toBeVisible({
    timeout: 30000,
  });
});
```

**Simulate network failure mid-request:**

```typescript
test('recovers from network failure', async ({ page }) => {
  let requestCount = 0;

  await page.route('/api/data', async (route) => {
    requestCount++;
    if (requestCount === 1) {
      await route.abort('failed'); // First request fails
    } else {
      await route.fulfill({ body: JSON.stringify({ data: 'success' }) });
    }
  });

  await page.goto('/dashboard');
  await expect(page.getByText('success')).toBeVisible();
});
```

Reference: [Playwright Network Emulation](https://playwright.dev/docs/api/class-browsercontext#browser-context-set-offline)
