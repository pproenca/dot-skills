---
title: Configure baseURL for Clean Navigation
impact: MEDIUM
impactDescription: cleaner test code, easier environment switching
tags: next, config, baseurl, navigation, environment
---

## Configure baseURL for Clean Navigation

Setting `baseURL` in config eliminates repetitive full URLs in tests and makes switching between environments trivial.

**Incorrect (hardcoded URLs):**

```typescript
// tests/navigation.spec.ts
test('navigate through pages', async ({ page }) => {
  await page.goto('http://localhost:3000/');
  await page.getByRole('link', { name: 'Products' }).click();
  await expect(page).toHaveURL('http://localhost:3000/products');

  await page.goto('http://localhost:3000/about');
  await expect(page).toHaveURL('http://localhost:3000/about');

  // Hard to change for staging/production
});
```

**Correct (baseURL configured):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    baseURL: process.env.BASE_URL || 'http://localhost:3000',
  },

  webServer: {
    command: 'npm run build && npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});

// tests/navigation.spec.ts
test('navigate through pages', async ({ page }) => {
  // Clean relative URLs
  await page.goto('/');
  await page.getByRole('link', { name: 'Products' }).click();
  await expect(page).toHaveURL('/products');

  await page.goto('/about');
  await expect(page).toHaveURL('/about');
});
```

**Environment-specific configuration:**

```typescript
// playwright.config.ts
const environments = {
  local: 'http://localhost:3000',
  staging: 'https://staging.example.com',
  production: 'https://example.com',
};

export default defineConfig({
  use: {
    baseURL: environments[process.env.TEST_ENV || 'local'],
  },

  // Only start local server when testing locally
  webServer: process.env.TEST_ENV === 'local' || !process.env.TEST_ENV
    ? {
        command: 'npm run build && npm run start',
        url: 'http://localhost:3000',
        reuseExistingServer: !process.env.CI,
      }
    : undefined,
});

// Run against different environments:
// TEST_ENV=local npx playwright test
// TEST_ENV=staging npx playwright test
// TEST_ENV=production npx playwright test
```

**Project-specific baseURLs:**

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    {
      name: 'local',
      use: { baseURL: 'http://localhost:3000' },
    },
    {
      name: 'staging',
      use: { baseURL: 'https://staging.example.com' },
    },
  ],
});

// Run specific project:
// npx playwright test --project=staging
```

Reference: [Playwright Configuration](https://playwright.dev/docs/test-configuration)
