---
title: Abort Unnecessary Requests
impact: MEDIUM
impactDescription: 30-50% faster page loads in tests
tags: mock, abort, block, performance, resources
---

## Abort Unnecessary Requests

Analytics, tracking, ads, and large images slow down tests without adding value. Abort these requests to speed up test execution.

**Incorrect (loading all resources):**

```typescript
test('homepage loads', async ({ page }) => {
  // Loads everything: analytics, fonts, images, third-party scripts
  await page.goto('/');

  // Test waits for all resources including:
  // - Google Analytics
  // - Facebook Pixel
  // - Large hero images
  // - Third-party chat widgets
});
```

**Correct (abort unnecessary resources):**

```typescript
// tests/homepage.spec.ts
test('homepage loads', async ({ page }) => {
  // Block analytics and tracking
  await page.route('**/*', (route) => {
    const url = route.request().url();
    if (
      url.includes('google-analytics.com') ||
      url.includes('googletagmanager.com') ||
      url.includes('facebook.net') ||
      url.includes('hotjar.com') ||
      url.includes('intercom.io')
    ) {
      return route.abort();
    }
    return route.continue();
  });

  await page.goto('/');
  await expect(page.getByRole('heading', { name: 'Welcome' })).toBeVisible();
});
```

**Block by resource type:**

```typescript
test('fast page load', async ({ page }) => {
  // Block images and fonts for faster tests
  await page.route('**/*', (route) => {
    const resourceType = route.request().resourceType();
    if (['image', 'font', 'media'].includes(resourceType)) {
      return route.abort();
    }
    return route.continue();
  });

  await page.goto('/products');
  // Test functionality without waiting for images
});
```

**Global blocking in config:**

```typescript
// fixtures/fast-page.ts
import { test as base } from '@playwright/test';

export const test = base.extend({
  page: async ({ page }, use) => {
    // Block tracking on all pages
    await page.route('**/*', (route) => {
      const url = route.request().url();
      const blocklist = [
        'google-analytics',
        'googletagmanager',
        'facebook',
        'hotjar',
        'segment',
        'mixpanel',
      ];
      if (blocklist.some((domain) => url.includes(domain))) {
        return route.abort();
      }
      return route.continue();
    });

    await use(page);
  },
});

// All tests using this fixture get faster loads
```

**When NOT to block:**
- Testing third-party integrations
- Testing cookie consent flows
- Testing ads functionality

Reference: [Playwright Request Interception](https://playwright.dev/docs/network#abort-requests)
