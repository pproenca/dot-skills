---
title: Use getByText for Static Content
impact: HIGH
impactDescription: matches user perception of the page
tags: loc, getByText, content, selectors, text
---

## Use getByText for Static Content

For static text content like headings, paragraphs, and labels, use `getByText` to select elements the way users see them.

**Incorrect (selecting by structure):**

```typescript
// tests/homepage.spec.ts
test('displays welcome message', async ({ page }) => {
  await page.goto('/');

  // Breaks when HTML structure changes
  await expect(page.locator('main > div > h1')).toHaveText('Welcome');

  // Breaks when class name changes
  await expect(page.locator('.hero-subtitle')).toBeVisible();

  // Too broad - may match unintended elements
  await expect(page.locator('p')).toContainText('Get started');
});
```

**Correct (selecting by text content):**

```typescript
// tests/homepage.spec.ts
test('displays welcome message', async ({ page }) => {
  await page.goto('/');

  // Direct text matching
  await expect(page.getByText('Welcome to our platform')).toBeVisible();

  // Exact text matching when needed
  await expect(page.getByText('Welcome', { exact: true })).toBeVisible();

  // Combine with role for specificity
  await expect(
    page.getByRole('heading', { name: 'Welcome to our platform' })
  ).toBeVisible();
});
```

**Handling partial text:**

```typescript
// Contains text (default behavior)
await expect(page.getByText('Sign up today')).toBeVisible();

// Matches "Sign up today and get 20% off"

// Exact text matching
await expect(page.getByText('Sign up today', { exact: true })).toBeVisible();
// Only matches exactly "Sign up today"

// Regex for flexible matching
await expect(page.getByText(/Sign up/i)).toBeVisible();
// Case-insensitive matching
```

**When NOT to use getByText:**
- Dynamic content that changes frequently
- Numbers or dates that vary
- User-generated content

```typescript
// For dynamic content, use data-testid instead
await expect(page.getByTestId('user-count')).toHaveText('42 users');
```

Reference: [Playwright getByText](https://playwright.dev/docs/locators#locate-by-text)
