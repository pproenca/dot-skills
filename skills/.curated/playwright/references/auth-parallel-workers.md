---
title: Use Worker-Scoped Auth for Parallel Tests
impact: MEDIUM-HIGH
impactDescription: enables parallel testing with unique sessions
tags: auth, parallel, workers, fixtures, isolation
---

## Use Worker-Scoped Auth for Parallel Tests

When running tests in parallel, each worker needs its own authentication to avoid conflicts. Use worker-scoped fixtures to authenticate once per worker with unique test accounts.

**Incorrect (shared auth in parallel):**

```typescript
// All parallel workers use same auth state
// Causes conflicts when tests modify user data
export default defineConfig({
  workers: 4,
  use: {
    storageState: 'playwright/.auth/user.json', // Same for all workers!
  },
});
```

**Correct (worker-scoped auth fixtures):**

```typescript
// fixtures/auth.ts
import { test as base } from '@playwright/test';

// Test users - one per potential parallel worker
const testUsers = [
  { email: 'test1@example.com', password: 'pass1' },
  { email: 'test2@example.com', password: 'pass2' },
  { email: 'test3@example.com', password: 'pass3' },
  { email: 'test4@example.com', password: 'pass4' },
];

export const test = base.extend<{}, { workerStorageState: string }>({
  // Worker-scoped fixture - runs once per worker
  workerStorageState: [
    async ({ browser }, use, workerInfo) => {
      // Each worker gets unique user based on parallelIndex
      const user = testUsers[workerInfo.parallelIndex % testUsers.length];

      const fileName = `playwright/.auth/worker-${workerInfo.parallelIndex}.json`;

      // Authenticate this worker's user
      const context = await browser.newContext();
      const page = await context.newPage();

      await page.goto('/login');
      await page.getByLabel('Email').fill(user.email);
      await page.getByLabel('Password').fill(user.password);
      await page.getByRole('button', { name: 'Sign in' }).click();
      await page.waitForURL('/dashboard');

      await context.storageState({ path: fileName });
      await context.close();

      await use(fileName);
    },
    { scope: 'worker' },
  ],

  // Override storageState to use worker-specific auth
  storageState: async ({ workerStorageState }, use) => {
    await use(workerStorageState);
  },
});

export { expect } from '@playwright/test';

// tests/dashboard.spec.ts
import { test, expect } from '../fixtures/auth';

test('user can update profile', async ({ page }) => {
  // Each worker has isolated user - no conflicts
  await page.goto('/profile');
  await page.getByLabel('Bio').fill('Updated bio');
  await page.getByRole('button', { name: 'Save' }).click();
  await expect(page.getByText('Profile updated')).toBeVisible();
});
```

**Create test users in setup:**

```typescript
// global-setup.ts
export default async function globalSetup() {
  // Ensure test users exist before tests run
  for (let i = 0; i < 4; i++) {
    await createTestUser({
      email: `test${i + 1}@example.com`,
      password: `pass${i + 1}`,
    });
  }
}
```

Reference: [Playwright Worker-Scoped Fixtures](https://playwright.dev/docs/auth#authenticating-in-ui-mode)
