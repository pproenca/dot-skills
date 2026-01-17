---
title: Use Web-First Assertions
impact: HIGH
impactDescription: auto-retry eliminates timing failures
tags: wait, assertions, auto-retry, expect, web-first
---

## Use Web-First Assertions

Web-first assertions automatically retry until conditions are met or timeout is reached. Manual assertions check once and fail immediately, causing flakiness.

**Incorrect (manual assertions):**

```typescript
// tests/loading.spec.ts
test('shows success message after save', async ({ page }) => {
  await page.goto('/settings');
  await page.getByLabel('Name').fill('John Doe');
  await page.getByRole('button', { name: 'Save' }).click();

  // WRONG: checks once, fails if element isn't immediately visible
  const isVisible = await page.getByText('Settings saved').isVisible();
  expect(isVisible).toBe(true);

  // WRONG: same problem with getAttribute
  const text = await page.locator('.status').textContent();
  expect(text).toBe('Success');
});
```

**Correct (web-first assertions):**

```typescript
// tests/loading.spec.ts
test('shows success message after save', async ({ page }) => {
  await page.goto('/settings');
  await page.getByLabel('Name').fill('John Doe');
  await page.getByRole('button', { name: 'Save' }).click();

  // Auto-retries until visible or timeout
  await expect(page.getByText('Settings saved')).toBeVisible();

  // Auto-retries text content check
  await expect(page.locator('.status')).toHaveText('Success');
});
```

**Common web-first assertions:**

```typescript
// Visibility
await expect(locator).toBeVisible();
await expect(locator).toBeHidden();

// Text content
await expect(locator).toHaveText('Expected');
await expect(locator).toContainText('partial');

// Attributes
await expect(locator).toHaveAttribute('href', '/home');
await expect(locator).toHaveClass(/active/);

// Form state
await expect(locator).toBeEnabled();
await expect(locator).toBeDisabled();
await expect(locator).toBeChecked();
await expect(locator).toHaveValue('input value');

// Count
await expect(locator).toHaveCount(5);

// URL
await expect(page).toHaveURL('/dashboard');
await expect(page).toHaveTitle('Dashboard');
```

**Configuring assertion timeout:**

```typescript
// playwright.config.ts
export default defineConfig({
  expect: {
    timeout: 10000, // 10 seconds for slow pages
  },
});

// Or per-assertion
await expect(locator).toBeVisible({ timeout: 15000 });
```

Reference: [Playwright Assertions](https://playwright.dev/docs/test-assertions)
