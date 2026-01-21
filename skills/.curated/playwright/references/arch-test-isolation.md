---
title: Use Fresh Browser Context for Each Test
impact: CRITICAL
impactDescription: eliminates cross-test state pollution
tags: arch, isolation, context, browser, fixtures
---

## Use Fresh Browser Context for Each Test

Tests that share browser state can pass or fail unpredictably based on execution order. Playwright creates a fresh context per test by default—never disable this behavior.

**Incorrect (shared state between tests):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Reusing context causes state leakage
    launchOptions: {
      args: ['--disable-web-security'],
    },
  },
});

// tests/checkout.spec.ts
test('add to cart', async ({ page }) => {
  await page.goto('/product/1');
  await page.getByRole('button', { name: 'Add to Cart' }).click();
  // Cart state persists to next test!
});

test('checkout empty cart', async ({ page }) => {
  await page.goto('/checkout');
  // Fails because cart has items from previous test
  await expect(page.getByText('Your cart is empty')).toBeVisible();
});
```

**Correct (isolated context per test):**

```typescript
// tests/checkout.spec.ts
test('add to cart', async ({ page }) => {
  await page.goto('/product/1');
  await page.getByRole('button', { name: 'Add to Cart' }).click();
  await expect(page.getByTestId('cart-count')).toHaveText('1');
});

test('checkout empty cart', async ({ page }) => {
  // Fresh context - no cart items from previous test
  await page.goto('/checkout');
  await expect(page.getByText('Your cart is empty')).toBeVisible();
});
```

**Benefits:**
- Tests can run in any order
- Failures are isolated and easier to debug
- Parallel execution becomes safe

Reference: [Playwright Test Isolation](https://playwright.dev/docs/browser-contexts)
