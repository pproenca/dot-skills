---
title: Use API Login for Faster Auth Setup
impact: HIGH
impactDescription: 5-10× faster than UI login
tags: auth, api, request, login, performance
---

## Use API Login for Faster Auth Setup

UI-based login requires rendering pages and interacting with forms. API-based login directly calls the auth endpoint, saving significant time.

**Incorrect (slow UI login):**

```typescript
// auth.setup.ts
setup('authenticate', async ({ page }) => {
  // UI login: ~2-5 seconds
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');

  await page.context().storageState({ path: 'playwright/.auth/user.json' });
});
```

**Correct (fast API login):**

```typescript
// auth.setup.ts
import { test as setup } from '@playwright/test';

setup('authenticate', async ({ request }) => {
  // API login: ~100-500ms
  const response = await request.post('/api/auth/login', {
    data: {
      email: 'user@example.com',
      password: 'password',
    },
  });

  // Verify login succeeded
  expect(response.ok()).toBeTruthy();

  // Save auth state from response cookies
  await request.storageState({ path: 'playwright/.auth/user.json' });
});

// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'setup', testMatch: /.*\.setup\.ts/ },
    {
      name: 'tests',
      use: { storageState: 'playwright/.auth/user.json' },
      dependencies: ['setup'],
    },
  ],
});
```

**Combined approach (API + set storage):**

```typescript
// For apps where API sets cookies directly
setup('authenticate via API', async ({ request, browser }) => {
  // Call login API
  await request.post('/api/auth/login', {
    data: { email: 'user@example.com', password: 'password' },
  });

  // If API returns token to be stored client-side
  const context = await browser.newContext();
  const page = await context.newPage();

  // Navigate to set any client-side auth state
  await page.goto('/');
  await page.evaluate((token) => {
    localStorage.setItem('authToken', token);
  }, 'token-from-api');

  await context.storageState({ path: 'playwright/.auth/user.json' });
  await context.close();
});
```

**Benefits:**
- 5-10× faster auth setup
- No UI rendering overhead
- More reliable (no form interaction)
- Tests auth API endpoint as side effect

**When to still use UI login:**
- Testing the login flow itself
- Auth flow has complex multi-step UI
- Third-party OAuth that can't be bypassed

Reference: [Playwright API Request Context](https://playwright.dev/docs/api-testing)
