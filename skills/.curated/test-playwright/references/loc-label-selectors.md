---
title: Use getByLabel for Form Inputs
impact: CRITICAL
impactDescription: matches user behavior, encourages accessible forms
tags: loc, getByLabel, forms, accessibility, inputs
---

## Use getByLabel for Form Inputs

Form inputs should be selected by their label text, which matches how users identify them. This approach also validates that forms are properly labeled for accessibility.

**Incorrect (selecting by input attributes):**

```typescript
// tests/registration.spec.ts
test('submit registration form', async ({ page }) => {
  await page.goto('/register');

  // Breaks when name attribute changes
  await page.locator('input[name="email"]').fill('user@example.com');

  // Breaks when placeholder changes
  await page.locator('input[placeholder="Enter password"]').fill('secret123');

  // Breaks when ID changes
  await page.locator('#confirm-password').fill('secret123');

  // Breaks when type is used elsewhere
  await page.locator('input[type="tel"]').fill('555-1234');
});
```

**Correct (selecting by label):**

```typescript
// tests/registration.spec.ts
test('submit registration form', async ({ page }) => {
  await page.goto('/register');

  // Matches visible label text - stable and accessible
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('secret123');
  await page.getByLabel('Confirm Password').fill('secret123');
  await page.getByLabel('Phone Number').fill('555-1234');

  await page.getByRole('button', { name: 'Register' }).click();
});
```

**Handling multiple matches:**

```typescript
// When labels are ambiguous, use exact matching
await page.getByLabel('Email', { exact: true }).fill('user@example.com');

// Or scope to a specific form section
await page
  .getByRole('group', { name: 'Contact Information' })
  .getByLabel('Email')
  .fill('contact@example.com');

await page
  .getByRole('group', { name: 'Billing Information' })
  .getByLabel('Email')
  .fill('billing@example.com');
```

**For inputs without visible labels:**

```typescript
// Use aria-label when visual label isn't present
<input type="search" aria-label="Search products" />

// Test can still use getByLabel
await page.getByLabel('Search products').fill('shoes');
```

Reference: [Playwright getByLabel](https://playwright.dev/docs/locators#locate-by-label)
