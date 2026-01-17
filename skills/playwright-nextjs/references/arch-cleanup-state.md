---
title: Clean Up Test State After Each Test
impact: CRITICAL
impactDescription: prevents cascading failures from leftover data
tags: arch, cleanup, teardown, state, afterEach
---

## Clean Up Test State After Each Test

Leftover state from tests can cause subsequent tests to fail. Clean up any data created during tests, especially when using shared databases or external services.

**Incorrect (no cleanup, state accumulates):**

```typescript
// tests/posts.spec.ts
test('create new post', async ({ page }) => {
  await page.goto('/posts/new');
  await page.getByLabel('Title').fill('Test Post');
  await page.getByLabel('Content').fill('Test content');
  await page.getByRole('button', { name: 'Publish' }).click();
  await expect(page.getByText('Post published')).toBeVisible();
  // Post remains in database, affects other tests
});

test('list shows no posts for new user', async ({ page }) => {
  await page.goto('/posts');
  // Fails because previous test created a post
  await expect(page.getByText('No posts yet')).toBeVisible();
});
```

**Correct (cleanup after each test):**

```typescript
// tests/posts.spec.ts
import { test, expect } from '@playwright/test';

let createdPostIds: string[] = [];

test.afterEach(async ({ request }) => {
  // Clean up any posts created during the test
  for (const postId of createdPostIds) {
    await request.delete(`/api/posts/${postId}`);
  }
  createdPostIds = [];
});

test('create new post', async ({ page, request }) => {
  await page.goto('/posts/new');
  await page.getByLabel('Title').fill('Test Post');
  await page.getByLabel('Content').fill('Test content');
  await page.getByRole('button', { name: 'Publish' }).click();

  // Track created post for cleanup
  const postId = await page.getByTestId('post-id').textContent();
  createdPostIds.push(postId!);

  await expect(page.getByText('Post published')).toBeVisible();
});

test('list shows no posts for new user', async ({ page }) => {
  await page.goto('/posts');
  // Clean state - no posts from previous test
  await expect(page.getByText('No posts yet')).toBeVisible();
});
```

**Alternative (use test database reset):**

```typescript
// global-setup.ts
export default async function globalSetup() {
  // Reset test database before test run
  await resetTestDatabase();
}

// playwright.config.ts
export default defineConfig({
  globalSetup: require.resolve('./global-setup'),
});
```

Reference: [Playwright Test Hooks](https://playwright.dev/docs/test-fixtures#automatic-fixtures)
