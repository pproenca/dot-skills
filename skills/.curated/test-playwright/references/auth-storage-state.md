---
title: Reuse Authentication with Storage State
impact: HIGH
impactDescription: 60-80% reduction in test execution time
tags: auth, storage-state, session, cookies, login
---

## Reuse Authentication with Storage State

Logging in for every test wastes time. Playwright can save and reuse authentication state (cookies, localStorage), eliminating repeated logins.

**Incorrect (login in every test):**

```typescript
// tests/dashboard.spec.ts
test('view user stats', async ({ page }) => {
  // Login repeated in every single test
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');

  await expect(page.getByTestId('stats')).toBeVisible();
});

test('view notifications', async ({ page }) => {
  // Same login code repeated
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');

  await page.goto('/notifications');
  await expect(page.getByTestId('notification-list')).toBeVisible();
});
```

**Correct (storage state reuse):**

```typescript
// auth.setup.ts
import { test as setup, expect } from '@playwright/test';

const authFile = 'playwright/.auth/user.json';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password123');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');

  // Save authentication state
  await page.context().storageState({ path: authFile });
});

// playwright.config.ts
export default defineConfig({
  projects: [
    // Setup project runs first
    { name: 'setup', testMatch: /.*\.setup\.ts/ },

    // Tests use saved auth state
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        storageState: 'playwright/.auth/user.json',
      },
      dependencies: ['setup'],
    },
  ],
});

// tests/dashboard.spec.ts
test('view user stats', async ({ page }) => {
  // Already logged in via storage state!
  await page.goto('/dashboard');
  await expect(page.getByTestId('stats')).toBeVisible();
});

test('view notifications', async ({ page }) => {
  await page.goto('/notifications');
  await expect(page.getByTestId('notification-list')).toBeVisible();
});
```

**Add `.auth` to `.gitignore`:**

```gitignore
# playwright/.auth contains sensitive session data
playwright/.auth/
```

Reference: [Playwright Authentication](https://playwright.dev/docs/auth)
