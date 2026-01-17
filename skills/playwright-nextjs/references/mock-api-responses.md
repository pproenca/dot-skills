---
title: Mock API Responses for Deterministic Tests
impact: MEDIUM-HIGH
impactDescription: eliminates external dependencies
tags: mock, api, route, intercept, deterministic
---

## Mock API Responses for Deterministic Tests

Real API calls make tests slow and flaky due to network variability, rate limits, and data changes. Mock responses to control exactly what your app receives.

**Incorrect (real API calls):**

```typescript
// tests/products.spec.ts
test('displays product list', async ({ page }) => {
  await page.goto('/products');

  // Depends on real API state - could change anytime
  // Slow due to network latency
  // May fail due to rate limits
  await expect(page.getByTestId('product-card')).toHaveCount(10);
});
```

**Correct (mocked API responses):**

```typescript
// tests/products.spec.ts
test('displays product list', async ({ page }) => {
  // Intercept API calls and return mock data
  await page.route('/api/products', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        products: [
          { id: 1, name: 'Widget', price: 9.99 },
          { id: 2, name: 'Gadget', price: 19.99 },
          { id: 3, name: 'Gizmo', price: 29.99 },
        ],
      }),
    });
  });

  await page.goto('/products');

  // Test against controlled data
  await expect(page.getByTestId('product-card')).toHaveCount(3);
  await expect(page.getByText('Widget')).toBeVisible();
  await expect(page.getByText('$9.99')).toBeVisible();
});
```

**Mock error responses:**

```typescript
test('shows error message on API failure', async ({ page }) => {
  await page.route('/api/products', async (route) => {
    await route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Internal Server Error' }),
    });
  });

  await page.goto('/products');

  await expect(page.getByText('Failed to load products')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Retry' })).toBeVisible();
});
```

**Mock with pattern matching:**

```typescript
// Mock all API routes
await page.route('/api/**', async (route) => {
  const url = route.request().url();

  if (url.includes('/api/user')) {
    await route.fulfill({ body: JSON.stringify({ name: 'John' }) });
  } else if (url.includes('/api/products')) {
    await route.fulfill({ body: JSON.stringify({ products: [] }) });
  } else {
    await route.continue(); // Let unmatched requests through
  }
});
```

Reference: [Playwright Network Mocking](https://playwright.dev/docs/mock)
