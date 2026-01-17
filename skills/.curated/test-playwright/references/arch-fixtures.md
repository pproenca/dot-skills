---
title: Use Fixtures for Shared Setup
impact: CRITICAL
impactDescription: eliminates setup duplication across tests
tags: arch, fixtures, setup, reusable, dependency-injection
---

## Use Fixtures for Shared Setup

Repeating setup code in every test is error-prone and slow. Fixtures provide reusable, composable setup that Playwright manages automatically.

**Incorrect (duplicated setup in each test):**

```typescript
// tests/admin.spec.ts
test('admin can view users', async ({ page }) => {
  // Setup duplicated in every admin test
  await page.goto('/login');
  await page.getByLabel('Email').fill('admin@example.com');
  await page.getByLabel('Password').fill('adminpass');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/admin/dashboard');

  await page.goto('/admin/users');
  await expect(page.getByRole('table')).toBeVisible();
});

test('admin can create user', async ({ page }) => {
  // Same setup repeated
  await page.goto('/login');
  await page.getByLabel('Email').fill('admin@example.com');
  await page.getByLabel('Password').fill('adminpass');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/admin/dashboard');

  await page.goto('/admin/users/new');
  // ...
});
```

**Correct (custom fixture):**

```typescript
// fixtures/admin.ts
import { test as base, expect } from '@playwright/test';

type AdminFixtures = {
  adminPage: Page;
};

export const test = base.extend<AdminFixtures>({
  adminPage: async ({ page }, use) => {
    // Setup: login as admin
    await page.goto('/login');
    await page.getByLabel('Email').fill('admin@example.com');
    await page.getByLabel('Password').fill('adminpass');
    await page.getByRole('button', { name: 'Sign in' }).click();
    await page.waitForURL('/admin/dashboard');

    // Provide the authenticated page to the test
    await use(page);

    // Teardown: logout (optional)
    await page.goto('/logout');
  },
});

export { expect };

// tests/admin.spec.ts
import { test, expect } from '../fixtures/admin';

test('admin can view users', async ({ adminPage }) => {
  await adminPage.goto('/admin/users');
  await expect(adminPage.getByRole('table')).toBeVisible();
});

test('admin can create user', async ({ adminPage }) => {
  await adminPage.goto('/admin/users/new');
  await expect(adminPage.getByRole('form')).toBeVisible();
});
```

**Benefits:**
- DRY principle enforced
- Automatic setup and teardown
- Composable fixtures for complex scenarios

Reference: [Playwright Fixtures](https://playwright.dev/docs/test-fixtures)
