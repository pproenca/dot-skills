---
title: Use HAR Files for Complex Mock Scenarios
impact: MEDIUM
impactDescription: realistic multi-request mocking
tags: mock, har, recording, replay, api
---

## Use HAR Files for Complex Mock Scenarios

For pages with many API calls, manually mocking each one is tedious. Record a HAR (HTTP Archive) file once, then replay it for consistent test data.

**Incorrect (manually mocking many endpoints):**

```typescript
test('complex dashboard', async ({ page }) => {
  // Tedious: manually mock every endpoint
  await page.route('/api/user', (route) => route.fulfill({ body: '...' }));
  await page.route('/api/stats', (route) => route.fulfill({ body: '...' }));
  await page.route('/api/notifications', (route) => route.fulfill({ body: '...' }));
  await page.route('/api/activity', (route) => route.fulfill({ body: '...' }));
  await page.route('/api/settings', (route) => route.fulfill({ body: '...' }));
  // ... 10 more endpoints

  await page.goto('/dashboard');
});
```

**Correct (record HAR once, replay):**

```typescript
// Step 1: Record HAR file (run once)
// npx playwright codegen --save-har=tests/fixtures/dashboard.har http://localhost:3000/dashboard

// Step 2: Use HAR in tests
test('complex dashboard', async ({ page }) => {
  // Replay all recorded API responses
  await page.routeFromHAR('tests/fixtures/dashboard.har', {
    url: '**/api/**',
    update: false, // Set true to update HAR
  });

  await page.goto('/dashboard');

  await expect(page.getByTestId('stats-panel')).toBeVisible();
  await expect(page.getByTestId('activity-feed')).toBeVisible();
});
```

**Update HAR when API changes:**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Update HAR files when running with --update-snapshots
    // npx playwright test --update-snapshots
  },
});

// test
test('dashboard with updatable HAR', async ({ page }) => {
  await page.routeFromHAR('tests/fixtures/dashboard.har', {
    url: '**/api/**',
    update: process.env.UPDATE_HAR === 'true',
  });

  await page.goto('/dashboard');
});

// Run with: UPDATE_HAR=true npx playwright test dashboard.spec.ts
```

**Selective HAR usage:**

```typescript
test('mixed real and mocked APIs', async ({ page }) => {
  // Use HAR for most APIs
  await page.routeFromHAR('tests/fixtures/dashboard.har', {
    url: '**/api/**',
    notFound: 'fallback', // Unknown routes hit real server
  });

  // Override specific endpoint with custom mock
  await page.route('/api/realtime', async (route) => {
    await route.fulfill({
      body: JSON.stringify({ timestamp: Date.now() }),
    });
  });

  await page.goto('/dashboard');
});
```

**Best practices for HAR files:**
- Store in `tests/fixtures/` directory
- Include in git (sanitize sensitive data first)
- Update periodically when APIs change
- Use descriptive names: `dashboard-logged-in.har`

Reference: [Playwright HAR](https://playwright.dev/docs/mock#mocking-with-har-files)
