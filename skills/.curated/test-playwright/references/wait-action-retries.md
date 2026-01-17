---
title: Let Actions Auto-Wait Before Interacting
impact: HIGH
impactDescription: Playwright auto-waits for actionability
tags: wait, auto-wait, actionability, click, fill
---

## Let Actions Auto-Wait Before Interacting

Playwright actions like `click()` and `fill()` automatically wait for elements to be visible, enabled, and stable. Don't add manual waits before actions.

**Incorrect (redundant manual waits):**

```typescript
// tests/form.spec.ts
test('submit contact form', async ({ page }) => {
  await page.goto('/contact');

  // WRONG: unnecessary waits before actions
  await page.waitForSelector('input[name="name"]');
  await page.getByLabel('Name').fill('John Doe');

  await page.waitForSelector('input[name="email"]', { state: 'visible' });
  await page.getByLabel('Email').fill('john@example.com');

  await page.waitForSelector('button[type="submit"]', { state: 'attached' });
  await page.getByRole('button', { name: 'Submit' }).click();
});
```

**Correct (rely on auto-waiting):**

```typescript
// tests/form.spec.ts
test('submit contact form', async ({ page }) => {
  await page.goto('/contact');

  // Actions auto-wait for elements to be actionable
  await page.getByLabel('Name').fill('John Doe');
  await page.getByLabel('Email').fill('john@example.com');
  await page.getByRole('button', { name: 'Submit' }).click();

  await expect(page.getByText('Message sent')).toBeVisible();
});
```

**What Playwright checks before actions:**

```typescript
// Before click(), Playwright verifies:
// - Element is attached to DOM
// - Element is visible
// - Element is stable (not animating)
// - Element receives events (not obscured)
// - Element is enabled

// Before fill(), Playwright also verifies:
// - Element is editable

// This all happens automatically - no manual waits needed
await page.getByRole('button', { name: 'Submit' }).click();
```

**When manual waits ARE needed:**

```typescript
// When waiting for element to disappear
await page.getByRole('button', { name: 'Submit' }).click();
await expect(page.getByTestId('loading')).toBeHidden();

// When element state determines test flow
const submitButton = page.getByRole('button', { name: 'Submit' });
await submitButton.waitFor({ state: 'visible' });
const isDisabled = await submitButton.isDisabled();
if (isDisabled) {
  // Handle disabled state
}

// When waiting for element to be removed from DOM entirely
await expect(page.getByTestId('modal')).not.toBeAttached();
```

Reference: [Playwright Auto-Waiting](https://playwright.dev/docs/actionability)
