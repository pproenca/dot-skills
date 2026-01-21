---
title: Use Soft Assertions for Non-Critical Checks
impact: MEDIUM
impactDescription: collect multiple failures without stopping test
tags: wait, soft-assertions, expect, debugging, multiple-checks
---

## Use Soft Assertions for Non-Critical Checks

Soft assertions continue test execution even when they fail, collecting all failures for review. Use them for non-blocking checks where you want to see all issues at once.

**Incorrect (test stops at first failure):**

```typescript
// tests/profile.spec.ts
test('profile page displays all user info', async ({ page }) => {
  await page.goto('/profile');

  // Test stops at first failure - you don't see other issues
  await expect(page.getByTestId('username')).toHaveText('johndoe');
  await expect(page.getByTestId('email')).toHaveText('john@example.com');
  await expect(page.getByTestId('avatar')).toBeVisible();
  await expect(page.getByTestId('bio')).toContainText('Developer');
  await expect(page.getByTestId('join-date')).toBeVisible();
});
```

**Correct (soft assertions for comprehensive feedback):**

```typescript
// tests/profile.spec.ts
test('profile page displays all user info', async ({ page }) => {
  await page.goto('/profile');

  // Collect all failures - test continues after each failure
  await expect.soft(page.getByTestId('username')).toHaveText('johndoe');
  await expect.soft(page.getByTestId('email')).toHaveText('john@example.com');
  await expect.soft(page.getByTestId('avatar')).toBeVisible();
  await expect.soft(page.getByTestId('bio')).toContainText('Developer');
  await expect.soft(page.getByTestId('join-date')).toBeVisible();

  // At end, if any soft assertion failed, test fails with all errors
});
```

**Mix soft and hard assertions:**

```typescript
test('complete checkout flow', async ({ page }) => {
  await page.goto('/cart');

  // Hard assertion: test can't continue without this
  await expect(page.getByTestId('cart-items')).toHaveCount(3);

  // Soft assertions: check all details, report all issues
  await expect.soft(page.getByTestId('item-1-name')).toHaveText('Widget');
  await expect.soft(page.getByTestId('item-1-price')).toHaveText('$9.99');
  await expect.soft(page.getByTestId('item-2-name')).toHaveText('Gadget');
  await expect.soft(page.getByTestId('subtotal')).toHaveText('$29.97');

  // Hard assertion: critical for next step
  await page.getByRole('button', { name: 'Checkout' }).click();
  await expect(page).toHaveURL('/checkout');
});
```

**When to use soft assertions:**
- Checking multiple independent UI elements
- Validating form field values
- Verifying list contents
- Visual regression checks

**When NOT to use soft assertions:**
- Critical preconditions for next steps
- Navigation that affects subsequent tests
- State changes that must succeed

Reference: [Playwright Soft Assertions](https://playwright.dev/docs/test-assertions#soft-assertions)
