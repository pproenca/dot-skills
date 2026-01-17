---
title: Test Server Actions End-to-End
impact: MEDIUM
impactDescription: validates complete form-to-server flow
tags: next, server-actions, forms, mutations, testing
---

## Test Server Actions End-to-End

Server Actions handle form submissions and mutations. Test them through the UI to verify the complete flow from form to server and back.

**Incorrect (incomplete server action testing):**

```typescript
// tests/contact.spec.ts
test('submit form', async ({ page }) => {
  await page.goto('/contact');
  await page.getByLabel('Name').fill('John');
  await page.getByRole('button', { name: 'Submit' }).click();
  // Only checks button was clicked - doesn't verify:
  // - Server action completed
  // - Success/error feedback appeared
  // - Form state reset properly
});
```

**Correct (complete server action testing):**

```typescript
// tests/contact.spec.ts
test('submit contact form via server action', async ({ page }) => {
  await page.goto('/contact');

  // Fill out form
  await page.getByLabel('Name').fill('John Doe');
  await page.getByLabel('Email').fill('john@example.com');
  await page.getByLabel('Message').fill('Hello, this is a test message.');

  // Submit triggers server action
  await page.getByRole('button', { name: 'Send Message' }).click();

  // Verify success feedback (server action completed)
  await expect(page.getByText('Message sent successfully')).toBeVisible();

  // Form should reset
  await expect(page.getByLabel('Name')).toHaveValue('');
});
```

**Test Server Action error handling:**

```typescript
test('server action validation errors', async ({ page }) => {
  await page.goto('/contact');

  // Submit without required fields
  await page.getByRole('button', { name: 'Send Message' }).click();

  // Server action returns validation errors
  await expect(page.getByText('Name is required')).toBeVisible();
  await expect(page.getByText('Email is required')).toBeVisible();
});
```

**Test useFormStatus integration:**

```typescript
test('shows pending state during server action', async ({ page }) => {
  // Slow down the server action
  await page.route('/contact', async (route) => {
    if (route.request().method() === 'POST') {
      await new Promise((r) => setTimeout(r, 2000));
    }
    await route.continue();
  });

  await page.goto('/contact');
  await page.getByLabel('Name').fill('John Doe');
  await page.getByLabel('Email').fill('john@example.com');
  await page.getByLabel('Message').fill('Test');

  await page.getByRole('button', { name: 'Send Message' }).click();

  // Button should show pending state
  await expect(page.getByRole('button', { name: 'Sending...' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Sending...' })).toBeDisabled();
});
```

Reference: [Next.js Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)
