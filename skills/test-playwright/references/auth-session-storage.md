---
title: Handle Session Storage for Auth
impact: HIGH
impactDescription: preserves auth state that uses sessionStorage
tags: auth, session-storage, storage-state, workaround, tokens
---

## Handle Session Storage for Auth

Playwright's `storageState` saves cookies and localStorage, but NOT sessionStorage (which is tab-specific). For apps using sessionStorage for auth tokens, use workarounds to preserve state.

**Incorrect (sessionStorage not persisted):**

```typescript
// Your app stores JWT in sessionStorage
sessionStorage.setItem('authToken', 'jwt-token-here');

// auth.setup.ts
setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password');
  await page.getByRole('button', { name: 'Sign in' }).click();

  // This ONLY saves cookies and localStorage, NOT sessionStorage!
  await page.context().storageState({ path: 'playwright/.auth/user.json' });
});

// Tests fail because sessionStorage auth token is lost
```

**Correct (save and restore sessionStorage manually):**

```typescript
// auth.setup.ts
import { test as setup } from '@playwright/test';
import fs from 'fs';

setup('authenticate', async ({ page }) => {
  await page.goto('/login');
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('password');
  await page.getByRole('button', { name: 'Sign in' }).click();
  await page.waitForURL('/dashboard');

  // Save regular storage state
  await page.context().storageState({ path: 'playwright/.auth/user.json' });

  // Save sessionStorage separately
  const sessionStorage = await page.evaluate(() =>
    JSON.stringify(sessionStorage)
  );
  fs.writeFileSync('playwright/.auth/session.json', sessionStorage);
});

// fixtures/auth.ts
import { test as base } from '@playwright/test';
import fs from 'fs';

export const test = base.extend({
  page: async ({ page }, use) => {
    // Restore sessionStorage before each test
    const sessionStorageData = fs.readFileSync(
      'playwright/.auth/session.json',
      'utf-8'
    );

    await page.addInitScript((data) => {
      const entries = JSON.parse(data);
      for (const [key, value] of Object.entries(entries)) {
        window.sessionStorage.setItem(key, value as string);
      }
    }, sessionStorageData);

    await use(page);
  },
});

// tests/dashboard.spec.ts
import { test } from '../fixtures/auth';

test('dashboard loads with session token', async ({ page }) => {
  await page.goto('/dashboard');
  await expect(page.getByTestId('user-profile')).toBeVisible();
});
```

**Alternative: use API to set auth:**

```typescript
// If your app accepts auth via API
test.beforeEach(async ({ page, request }) => {
  // Get token via API
  const response = await request.post('/api/auth/login', {
    data: { email: 'user@example.com', password: 'password' },
  });
  const { token } = await response.json();

  // Set token in sessionStorage before navigating
  await page.addInitScript((authToken) => {
    window.sessionStorage.setItem('authToken', authToken);
  }, token);
});
```

Reference: [Playwright Session Storage](https://playwright.dev/docs/auth#session-storage)
