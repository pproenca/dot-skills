---
title: Use Separate Storage States for Different Roles
impact: HIGH
impactDescription: test role-specific features efficiently
tags: auth, roles, storage-state, admin, user
---

## Use Separate Storage States for Different Roles

When testing features for different user roles (admin, user, guest), create separate storage states. This avoids re-authentication while testing role-specific functionality.

**Incorrect (single auth state, role switching):**

```typescript
// tests/admin.spec.ts
test('admin can delete users', async ({ page }) => {
  // Logout from default user
  await page.goto('/logout');

  // Login as admin
  await page.goto('/login');
  await page.getByLabel('Email').fill('admin@example.com');
  await page.getByLabel('Password').fill('adminpass');
  await page.getByRole('button', { name: 'Sign in' }).click();

  await page.goto('/admin/users');
  await page.getByTestId('user-row-1').getByRole('button', { name: 'Delete' }).click();
});
```

**Correct (multiple storage states):**

```typescript
// auth.setup.ts
import { test as setup, expect } from '@playwright/test';

setup('authenticate as user', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('userpass');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');
  await page.context().storageState({ path: 'playwright/.auth/user.json' });
});

setup('authenticate as admin', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('admin@example.com');
  await page.getByLabel('Password').fill('adminpass');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/admin');
  await page.context().storageState({ path: 'playwright/.auth/admin.json' });
});

// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },

    {
      name: 'user-tests',
      testDir: './tests/user',
      use: { storageState: 'playwright/.auth/user.json' },
      dependencies: ['setup'],
    },

    {
      name: 'admin-tests',
      testDir: './tests/admin',
      use: { storageState: 'playwright/.auth/admin.json' },
      dependencies: ['setup'],
    },
  ],
});

// tests/user/dashboard.spec.ts
test('user sees limited menu', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page.getByRole('link', { name: 'Admin' })).toBeHidden();
});

// tests/admin/users.spec.ts
test('admin can delete users', async ({ page }) => {
  await page.goto('/admin/users');
  await expect(page.getByRole('button', { name: 'Delete' })).toBeVisible();
});
```

**Test unauthenticated flows:**

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    // No storage state for unauthenticated tests
    {
      name: 'guest-tests',
      testDir: './tests/guest',
      // No storageState - tests run as logged out user
    },
  ],
});

// tests/guest/login.spec.ts
test('redirects to login when not authenticated', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page).toHaveURL('/login');
});
```

Reference: [Playwright Testing Multiple Roles](https://playwright.dev/docs/auth#testing-multiple-roles-together)
