---
title: Intercept and Modify Real Responses
impact: MEDIUM-HIGH
impactDescription: test edge cases with real data structure
tags: mock, intercept, modify, route, api
---

## Intercept and Modify Real Responses

Sometimes you need real API response structure but want to modify specific values. Intercept the response, modify it, and return the altered version.

**Incorrect (fully mocked response may miss fields):**

```typescript
test('handles zero inventory', async ({ page }) => {
  // May miss required fields that real API returns
  await page.route('/api/product/1', async (route) => {
    await route.fulfill({
      body: JSON.stringify({
        id: 1,
        name: 'Widget',
        inventory: 0, // Testing this
        // Missing: price, description, images, reviews, etc.
      }),
    });
  });

  await page.goto('/product/1');
  // Test may fail due to missing fields
});
```

**Correct (intercept and modify real response):**

```typescript
test('handles zero inventory', async ({ page }) => {
  await page.route('/api/product/1', async (route) => {
    // Get real response
    const response = await route.fetch();
    const json = await response.json();

    // Modify only what we need to test
    json.inventory = 0;
    json.inStock = false;

    await route.fulfill({
      response,
      body: JSON.stringify(json),
    });
  });

  await page.goto('/product/1');

  await expect(page.getByText('Out of Stock')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Add to Cart' })).toBeDisabled();
});
```

**Modify response headers:**

```typescript
test('handles expired cache', async ({ page }) => {
  await page.route('/api/data', async (route) => {
    const response = await route.fetch();

    await route.fulfill({
      response,
      headers: {
        ...response.headers(),
        'cache-control': 'no-cache', // Force fresh data
        'x-cache': 'MISS',
      },
    });
  });

  await page.goto('/dashboard');
  // Verify app handles cache miss correctly
});
```

**Add delay to real response:**

```typescript
test('shows loading state', async ({ page }) => {
  await page.route('/api/slow-data', async (route) => {
    // Add artificial delay to test loading UI
    await new Promise((resolve) => setTimeout(resolve, 2000));
    await route.continue();
  });

  await page.goto('/dashboard');

  // Loading state should be visible during delay
  await expect(page.getByTestId('loading-spinner')).toBeVisible();

  // Then data appears
  await expect(page.getByTestId('data-content')).toBeVisible();
});
```

Reference: [Playwright Route Fetch](https://playwright.dev/docs/mock#mocking-with-har-files)
