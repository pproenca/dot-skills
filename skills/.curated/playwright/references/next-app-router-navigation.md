---
title: Test App Router Navigation Patterns
impact: MEDIUM
impactDescription: validates soft navigation preserves state
tags: next, app-router, navigation, routing, layouts
---

## Test App Router Navigation Patterns

App Router uses soft navigation (client-side) between routes. Test that layouts persist, loading states work, and navigation doesn't cause unnecessary re-renders.

**Incorrect (no layout state testing):**

```typescript
// tests/navigation.spec.ts
test('navigation works', async ({ page }) => {
  await page.goto('/dashboard');
  await page.getByRole('link', { name: 'Settings' }).click();
  await expect(page).toHaveURL('/dashboard/settings');
  // Only tests URL changed - doesn't verify:
  // - Layout state persisted
  // - Loading UI appeared
  // - No full page reload
});
```

**Correct (verify soft navigation behavior):**

```typescript
// tests/navigation.spec.ts
test('soft navigation preserves layout state', async ({ page }) => {
  await page.goto('/dashboard');

  // Set some state in the layout (e.g., sidebar collapsed)
  await page.getByRole('button', { name: 'Collapse Sidebar' }).click();
  await expect(page.getByTestId('sidebar')).toHaveClass(/collapsed/);

  // Navigate to nested route
  await page.getByRole('link', { name: 'Settings' }).click();
  await expect(page).toHaveURL('/dashboard/settings');

  // Layout state should persist (sidebar still collapsed)
  await expect(page.getByTestId('sidebar')).toHaveClass(/collapsed/);
});
```

**Test loading UI during navigation:**

```typescript
test('shows loading state during navigation', async ({ page }) => {
  await page.goto('/products');

  // Slow down the navigation target
  await page.route('/api/product/*', async (route) => {
    await new Promise((r) => setTimeout(r, 1000));
    await route.fulfill({ body: JSON.stringify({ name: 'Widget' }) });
  });

  // Click to navigate
  await page.getByRole('link', { name: 'View Widget' }).click();

  // loading.tsx should render
  await expect(page.getByTestId('product-loading')).toBeVisible();

  // Then actual content
  await expect(page.getByTestId('product-details')).toBeVisible();
});
```

**Test parallel routes:**

```typescript
test('parallel routes render independently', async ({ page }) => {
  await page.goto('/dashboard');

  // Both parallel route slots should render
  await expect(page.getByTestId('stats-slot')).toBeVisible();
  await expect(page.getByTestId('activity-slot')).toBeVisible();

  // Opening modal keeps background content
  await page.getByRole('button', { name: 'View Details' }).click();
  await expect(page.getByRole('dialog')).toBeVisible();
  await expect(page.getByTestId('stats-slot')).toBeVisible();
});
```

Reference: [Next.js App Router](https://nextjs.org/docs/app)
