# Playwright + Next.js

**Version 0.1.0**  
Community  
January 2026

> **Note:**  
> This document is mainly for agents and LLMs to follow when maintaining,  
> generating, or refactoring codebases. Humans may also find it useful,  
> but guidance here is optimized for automation and consistency by AI-assisted workflows.

---

## Abstract

Comprehensive testing best practices guide for Playwright with Next.js applications, designed for AI agents and LLMs. Contains 43 rules across 8 categories, prioritized by impact from critical (test architecture, stable selectors) to incremental (debugging, CI integration). Each rule includes detailed explanations, real-world examples comparing incorrect vs. correct implementations, and specific impact metrics to guide reliable, fast, and maintainable E2E test development.

---

## Table of Contents

1. [Test Architecture](#1-test-architecture) — **CRITICAL**
   - 1.1 [Clean Up Test State After Each Test](#11-clean-up-test-state-after-each-test)
   - 1.2 [Enable Parallel Test Execution](#12-enable-parallel-test-execution)
   - 1.3 [Test Against Production Builds](#13-test-against-production-builds)
   - 1.4 [Use Fixtures for Shared Setup](#14-use-fixtures-for-shared-setup)
   - 1.5 [Use Fresh Browser Context for Each Test](#15-use-fresh-browser-context-for-each-test)
   - 1.6 [Use Page Object Model for Complex Pages](#16-use-page-object-model-for-complex-pages)
2. [Selectors & Locators](#2-selectors-locators) — **CRITICAL**
   - 2.1 [Avoid XPath Selectors](#21-avoid-xpath-selectors)
   - 2.2 [Chain Locators for Specificity](#22-chain-locators-for-specificity)
   - 2.3 [Use data-testid for Dynamic Elements](#23-use-data-testid-for-dynamic-elements)
   - 2.4 [Use getByLabel for Form Inputs](#24-use-getbylabel-for-form-inputs)
   - 2.5 [Use getByPlaceholder Sparingly](#25-use-getbyplaceholder-sparingly)
   - 2.6 [Use getByText for Static Content](#26-use-getbytext-for-static-content)
   - 2.7 [Use Role-Based Selectors Over CSS](#27-use-role-based-selectors-over-css)
3. [Waiting & Assertions](#3-waiting-assertions) — **HIGH**
   - 3.1 [Avoid Hard Waits](#31-avoid-hard-waits)
   - 3.2 [Configure Timeouts Appropriately](#32-configure-timeouts-appropriately)
   - 3.3 [Let Actions Auto-Wait Before Interacting](#33-let-actions-auto-wait-before-interacting)
   - 3.4 [Use Network Idle for Complex Pages](#34-use-network-idle-for-complex-pages)
   - 3.5 [Use Soft Assertions for Non-Critical Checks](#35-use-soft-assertions-for-non-critical-checks)
   - 3.6 [Use Web-First Assertions](#36-use-web-first-assertions)
4. [Authentication & State](#4-authentication-state) — **HIGH**
   - 4.1 [Handle Session Storage for Auth](#41-handle-session-storage-for-auth)
   - 4.2 [Reuse Authentication with Storage State](#42-reuse-authentication-with-storage-state)
   - 4.3 [Use API Login for Faster Auth Setup](#43-use-api-login-for-faster-auth-setup)
   - 4.4 [Use Separate Storage States for Different Roles](#44-use-separate-storage-states-for-different-roles)
   - 4.5 [Use Worker-Scoped Auth for Parallel Tests](#45-use-worker-scoped-auth-for-parallel-tests)
5. [Mocking & Network](#5-mocking-network) — **MEDIUM-HIGH**
   - 5.1 [Abort Unnecessary Requests](#51-abort-unnecessary-requests)
   - 5.2 [Intercept and Modify Real Responses](#52-intercept-and-modify-real-responses)
   - 5.3 [Mock API Responses for Deterministic Tests](#53-mock-api-responses-for-deterministic-tests)
   - 5.4 [Simulate Network Conditions](#54-simulate-network-conditions)
   - 5.5 [Use HAR Files for Complex Mock Scenarios](#55-use-har-files-for-complex-mock-scenarios)
6. [Next.js Integration](#6-nextjs-integration) — **MEDIUM**
   - 6.1 [Configure baseURL for Clean Navigation](#61-configure-baseurl-for-clean-navigation)
   - 6.2 [Test App Router Navigation Patterns](#62-test-app-router-navigation-patterns)
   - 6.3 [Test Server Actions End-to-End](#63-test-server-actions-end-to-end)
   - 6.4 [Test Server Components Correctly](#64-test-server-components-correctly)
   - 6.5 [Wait for Hydration Before Interacting](#65-wait-for-hydration-before-interacting)
7. [Performance & Speed](#7-performance-speed) — **MEDIUM**
   - 7.1 [Configure Retries for Flaky Test Recovery](#71-configure-retries-for-flaky-test-recovery)
   - 7.2 [Reuse Development Server When Possible](#72-reuse-development-server-when-possible)
   - 7.3 [Select Browsers Strategically](#73-select-browsers-strategically)
   - 7.4 [Use Headless Mode in CI](#74-use-headless-mode-in-ci)
   - 7.5 [Use Sharding for Large Test Suites](#75-use-sharding-for-large-test-suites)
8. [Debugging & CI](#8-debugging-ci) — **LOW-MEDIUM**
   - 8.1 [Capture Screenshots and Videos on Failure](#81-capture-screenshots-and-videos-on-failure)
   - 8.2 [Configure Reporters for CI Integration](#82-configure-reporters-for-ci-integration)
   - 8.3 [Use Playwright Inspector for Interactive Debugging](#83-use-playwright-inspector-for-interactive-debugging)
   - 8.4 [Use Trace Viewer for Failed Tests](#84-use-trace-viewer-for-failed-tests)

---

## 1. Test Architecture

**Impact: CRITICAL**

Test isolation and parallel execution patterns affect all subsequent tests; poor architecture creates cascading failures across the entire test suite.

### 1.1 Clean Up Test State After Each Test

**Impact: CRITICAL (prevents cascading failures from leftover data)**

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

### 1.2 Enable Parallel Test Execution

**Impact: CRITICAL (2-10× faster test suites)**

Running tests sequentially wastes CI time. Playwright supports parallel execution at both file and test level—configure workers based on your CI resources.

**Incorrect (sequential execution):**

```typescript
// playwright.config.ts
export default defineConfig({
  workers: 1, // Forces sequential execution
  fullyParallel: false,
});

// Test suite takes 10 minutes
```

**Correct (parallel execution):**

```typescript
// playwright.config.ts
export default defineConfig({
  // Use 50% of available CPUs, minimum 1
  workers: process.env.CI ? 4 : undefined,
  fullyParallel: true,
});

// tests/dashboard.spec.ts
import { test } from '@playwright/test';

test.describe.configure({ mode: 'parallel' });

test('loads user stats', async ({ page }) => {
  await page.goto('/dashboard/stats');
  await expect(page.getByTestId('stats-panel')).toBeVisible();
});

test('loads notifications', async ({ page }) => {
  await page.goto('/dashboard/notifications');
  await expect(page.getByTestId('notification-list')).toBeVisible();
});

test('loads settings', async ({ page }) => {
  await page.goto('/dashboard/settings');
  await expect(page.getByTestId('settings-form')).toBeVisible();
});
```

**When NOT to use parallel execution:**
- Tests that modify shared database state
- Tests that use the same external service account
- Tests with intentional sequential dependencies

Reference: [Playwright Parallelism](https://playwright.dev/docs/test-parallel)

### 1.3 Test Against Production Builds

**Impact: CRITICAL (catches build-only bugs, matches real behavior)**

Testing against `next dev` misses production-only issues like minification bugs, missing environment variables, and hydration mismatches. Always run E2E tests against `next build && next start`.

**Incorrect (testing dev server):**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: 'npm run dev', // Dev server has different behavior
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});

// Tests pass in dev but fail in production due to:
// - Hot reload interference
// - Unminified code paths
// - Development-only error boundaries
```

**Correct (testing production build):**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: 'npm run build && npm run start',
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
    timeout: 120000, // Build can take time
  },
});

// package.json
{
  "scripts": {
    "build": "next build",
    "start": "next start",
    "test:e2e": "playwright test",
    "test:e2e:ci": "npm run build && playwright test"
  }
}
```

**Alternative (pre-built for faster local iteration):**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: process.env.CI
      ? 'npm run build && npm run start'
      : 'npm run start', // Assumes build exists locally
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

**Benefits:**
- Tests match production behavior exactly
- Catches minification and tree-shaking bugs
- Validates environment variable handling

Reference: [Next.js Testing with Playwright](https://nextjs.org/docs/pages/guides/testing/playwright)

### 1.4 Use Fixtures for Shared Setup

**Impact: CRITICAL (eliminates setup duplication across tests)**

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

### 1.5 Use Fresh Browser Context for Each Test

**Impact: CRITICAL (eliminates cross-test state pollution)**

Tests that share browser state can pass or fail unpredictably based on execution order. Playwright creates a fresh context per test by default—never disable this behavior.

**Incorrect (shared state between tests):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Reusing context causes state leakage
    launchOptions: {
      args: ['--disable-web-security'],
    },
  },
});

// tests/checkout.spec.ts
test('add to cart', async ({ page }) => {
  await page.goto('/product/1');
  await page.getByRole('button', { name: 'Add to Cart' }).click();
  // Cart state persists to next test!
});

test('checkout empty cart', async ({ page }) => {
  await page.goto('/checkout');
  // Fails because cart has items from previous test
  await expect(page.getByText('Your cart is empty')).toBeVisible();
});
```

**Correct (isolated context per test):**

```typescript
// tests/checkout.spec.ts
test('add to cart', async ({ page }) => {
  await page.goto('/product/1');
  await page.getByRole('button', { name: 'Add to Cart' }).click();
  await expect(page.getByTestId('cart-count')).toHaveText('1');
});

test('checkout empty cart', async ({ page }) => {
  // Fresh context - no cart items from previous test
  await page.goto('/checkout');
  await expect(page.getByText('Your cart is empty')).toBeVisible();
});
```

**Benefits:**
- Tests can run in any order
- Failures are isolated and easier to debug
- Parallel execution becomes safe

Reference: [Playwright Test Isolation](https://playwright.dev/docs/browser-contexts)

### 1.6 Use Page Object Model for Complex Pages

**Impact: CRITICAL (reduces selector maintenance by 70%)**

Duplicating selectors across tests creates a maintenance burden. Page objects centralize selectors and actions, so UI changes require updates in one place.

**Incorrect (selectors scattered across tests):**

```typescript
// tests/login.spec.ts
test('successful login', async ({ page }) => {
  await page.goto('/login');
  await page.locator('input[name="email"]').fill('user@example.com');
  await page.locator('input[name="password"]').fill('password123');
  await page.locator('button[type="submit"]').click();
  await expect(page.locator('.dashboard-header')).toBeVisible();
});

// tests/logout.spec.ts
test('logout from dashboard', async ({ page }) => {
  // Same selectors duplicated
  await page.locator('input[name="email"]').fill('user@example.com');
  await page.locator('input[name="password"]').fill('password123');
  await page.locator('button[type="submit"]').click();
  // If selector changes, both files need updates
});
```

**Correct (Page Object Model):**

```typescript
// pages/LoginPage.ts
import { Page, Locator, expect } from '@playwright/test';

export class LoginPage {
  readonly page: Page;
  readonly emailInput: Locator;
  readonly passwordInput: Locator;
  readonly submitButton: Locator;

  constructor(page: Page) {
    this.page = page;
    this.emailInput = page.getByLabel('Email');
    this.passwordInput = page.getByLabel('Password');
    this.submitButton = page.getByRole('button', { name: 'Sign in' });
  }

  async goto() {
    await this.page.goto('/login');
  }

  async login(email: string, password: string) {
    await this.emailInput.fill(email);
    await this.passwordInput.fill(password);
    await this.submitButton.click();
  }
}

// tests/login.spec.ts
import { LoginPage } from '../pages/LoginPage';

test('successful login', async ({ page }) => {
  const loginPage = new LoginPage(page);
  await loginPage.goto();
  await loginPage.login('user@example.com', 'password123');
  await expect(page.getByTestId('dashboard-header')).toBeVisible();
});
```

**Benefits:**
- Single source of truth for selectors
- Readable, domain-specific test code
- Easy to update when UI changes

Reference: [Playwright Page Object Models](https://playwright.dev/docs/pom)

---

## 2. Selectors & Locators

**Impact: CRITICAL**

Unstable selectors are the #1 cause of flaky tests; using role-based and accessibility-first locators eliminates 80% of selector-related failures.

### 2.1 Avoid XPath Selectors

**Impact: HIGH (XPath is 3-5× slower and more brittle)**

XPath selectors require full DOM traversal and are significantly slower than CSS or role-based selectors. They also break easily when DOM structure changes.

**Incorrect (XPath selectors):**

```typescript
// tests/table.spec.ts
test('edit user in table', async ({ page }) => {
  await page.goto('/admin/users');

  // Slow: full DOM traversal
  await page.locator('//table//tr[contains(.,"john@example.com")]//button[text()="Edit"]').click();

  // Brittle: breaks if table structure changes
  await page.locator('//div[@class="container"]/div[2]/table/tbody/tr[3]/td[4]/button').click();

  // Hard to read and maintain
  await page.locator('//button[ancestor::tr[descendant::td[text()="Active"]]]').click();
});
```

**Correct (role-based and CSS alternatives):**

```typescript
// tests/table.spec.ts
test('edit user in table', async ({ page }) => {
  await page.goto('/admin/users');

  // Find row by content, then action button
  const userRow = page.getByRole('row', { name: /john@example.com/ });
  await userRow.getByRole('button', { name: 'Edit' }).click();

  // Or use data-testid for complex tables
  await page.getByTestId('user-row-john').getByRole('button', { name: 'Edit' }).click();
});
```

**Alternative approaches for complex queries:**

```typescript
// Filter locators instead of XPath
const activeUsers = page.getByRole('row').filter({
  has: page.getByText('Active'),
});
await activeUsers.first().getByRole('button', { name: 'Edit' }).click();

// Chain locators for specificity
await page
  .getByRole('table', { name: 'Users' })
  .getByRole('row')
  .filter({ hasText: 'john@example.com' })
  .getByRole('button', { name: 'Edit' })
  .click();
```

**Performance comparison:**

| Selector Type | Relative Speed |
|--------------|----------------|
| getByRole | 1× (fastest) |
| getByTestId | 1.1× |
| CSS | 1.2× |
| XPath | 3-5× (slowest) |

Reference: [Playwright Locator Best Practices](https://playwright.dev/docs/best-practices#use-locators)

### 2.2 Chain Locators for Specificity

**Impact: HIGH (reduces ambiguity without brittle selectors)**

When a single locator matches multiple elements, chain locators to narrow scope. This is more maintainable than complex CSS or XPath selectors.

**Incorrect (overly specific single selector):**

```typescript
// tests/products.spec.ts
test('add featured product to cart', async ({ page }) => {
  await page.goto('/products');

  // Brittle: depends on exact DOM structure
  await page.locator('section.featured-products div.product-card:first-child button.add-to-cart').click();

  // Ambiguous: might match wrong element
  await page.getByRole('button', { name: 'Add to Cart' }).click();
});
```

**Correct (chained locators):**

```typescript
// tests/products.spec.ts
test('add featured product to cart', async ({ page }) => {
  await page.goto('/products');

  // Chain from container to specific element
  const featuredSection = page.getByRole('region', { name: 'Featured Products' });
  const firstProduct = featuredSection.getByTestId('product-card').first();
  await firstProduct.getByRole('button', { name: 'Add to Cart' }).click();
});
```

**Using filter for conditional matching:**

```typescript
// Find product by name, then interact with it
const productCard = page
  .getByTestId('product-card')
  .filter({ hasText: 'Wireless Headphones' });

await productCard.getByRole('button', { name: 'Add to Cart' }).click();

// Filter by child element
const discountedProducts = page
  .getByTestId('product-card')
  .filter({ has: page.getByText('Sale') });

await expect(discountedProducts).toHaveCount(3);
```

**Combining multiple filters:**

```typescript
// Products that are both in-stock AND discounted
const availableDeals = page
  .getByTestId('product-card')
  .filter({ has: page.getByText('In Stock') })
  .filter({ has: page.getByTestId('discount-badge') });

await availableDeals.first().click();
```

**Benefits:**
- Each step is readable and debuggable
- Survives partial DOM changes
- Self-documenting test intent

Reference: [Playwright Filtering Locators](https://playwright.dev/docs/locators#filtering-locators)

### 2.3 Use data-testid for Dynamic Elements

**Impact: CRITICAL (stable selectors for dynamic content)**

When elements lack accessible names or roles, use `data-testid` attributes. These are explicitly for testing and won't change during normal development.

**Incorrect (fragile selectors for dynamic content):**

```typescript
// tests/dashboard.spec.ts
test('shows user stats', async ({ page }) => {
  await page.goto('/dashboard');

  // Breaks when text formatting changes
  await expect(page.locator('text=Active Users: 42')).toBeVisible();

  // Breaks when CSS class changes
  await expect(page.locator('.stat-card:first-child .value')).toHaveText('42');

  // Breaks when order changes
  await expect(page.locator('div:nth-child(3)')).toContainText('Revenue');
});
```

**Correct (data-testid for dynamic elements):**

```typescript
// components/StatsCard.tsx
export function StatsCard({ label, value }: Props) {
  return (
    <div className="stat-card" data-testid={`stat-${label.toLowerCase()}`}>
      <span className="label">{label}</span>
      <span className="value" data-testid={`stat-${label.toLowerCase()}-value`}>
        {value}
      </span>
    </div>
  );
}

// tests/dashboard.spec.ts
test('shows user stats', async ({ page }) => {
  await page.goto('/dashboard');

  // Stable selectors using data-testid
  await expect(page.getByTestId('stat-active-users')).toBeVisible();
  await expect(page.getByTestId('stat-active-users-value')).toHaveText('42');
  await expect(page.getByTestId('stat-revenue')).toBeVisible();
});
```

**Custom test ID attribute:**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Use custom attribute if data-testid conflicts with existing code
    testIdAttribute: 'data-pw',
  },
});

// component.tsx
<button data-pw="submit-button">Submit</button>

// test.spec.ts
await page.getByTestId('submit-button').click();
```

**When to use data-testid:**
- Dynamic content without stable text
- Multiple similar elements (list items, cards)
- Elements generated by third-party libraries
- Complex interactive components

Reference: [Playwright Test ID](https://playwright.dev/docs/locators#locate-by-test-id)

### 2.4 Use getByLabel for Form Inputs

**Impact: CRITICAL (matches user behavior, encourages accessible forms)**

Form inputs should be selected by their label text, which matches how users identify them. This approach also validates that forms are properly labeled for accessibility.

**Incorrect (selecting by input attributes):**

```typescript
// tests/registration.spec.ts
test('submit registration form', async ({ page }) => {
  await page.goto('/register');

  // Breaks when name attribute changes
  await page.locator('input[name="email"]').fill('user@example.com');

  // Breaks when placeholder changes
  await page.locator('input[placeholder="Enter password"]').fill('secret123');

  // Breaks when ID changes
  await page.locator('#confirm-password').fill('secret123');

  // Breaks when type is used elsewhere
  await page.locator('input[type="tel"]').fill('555-1234');
});
```

**Correct (selecting by label):**

```typescript
// tests/registration.spec.ts
test('submit registration form', async ({ page }) => {
  await page.goto('/register');

  // Matches visible label text - stable and accessible
  await page.getByLabel('Email').fill('user@example.com');
  await page.getByLabel('Password').fill('secret123');
  await page.getByLabel('Confirm Password').fill('secret123');
  await page.getByLabel('Phone Number').fill('555-1234');

  await page.getByRole('button', { name: 'Register' }).click();
});
```

**Handling multiple matches:**

```typescript
// When labels are ambiguous, use exact matching
await page.getByLabel('Email', { exact: true }).fill('user@example.com');

// Or scope to a specific form section
await page
  .getByRole('group', { name: 'Contact Information' })
  .getByLabel('Email')
  .fill('contact@example.com');

await page
  .getByRole('group', { name: 'Billing Information' })
  .getByLabel('Email')
  .fill('billing@example.com');
```

**For inputs without visible labels:**

```typescript
// Use aria-label when visual label isn't present
<input type="search" aria-label="Search products" />

// Test can still use getByLabel
await page.getByLabel('Search products').fill('shoes');
```

Reference: [Playwright getByLabel](https://playwright.dev/docs/locators#locate-by-label)

### 2.5 Use getByPlaceholder Sparingly

**Impact: MEDIUM (fallback when labels unavailable)**

Placeholder text is not a substitute for labels and may change with design updates. Prefer `getByLabel` when possible; use `getByPlaceholder` only when labels are unavailable.

**Incorrect (placeholder as primary selector):**

```typescript
// tests/search.spec.ts
test('search for products', async ({ page }) => {
  await page.goto('/');

  // Placeholders often change with design updates
  await page.getByPlaceholder('Search for anything...').fill('shoes');
  await page.getByPlaceholder('Enter your query').fill('shoes');
});
```

**Correct (prefer label, fallback to placeholder):**

```typescript
// Best: input has a proper label
<label>
  Search
  <input type="search" placeholder="e.g., shoes, bags" />
</label>

// Test uses label
await page.getByLabel('Search').fill('shoes');

// Alternative: input has aria-label
<input
  type="search"
  aria-label="Search products"
  placeholder="e.g., shoes, bags"
/>

// Test still uses getByLabel (aria-label works)
await page.getByLabel('Search products').fill('shoes');
```

**When getByPlaceholder is acceptable:**

```typescript
// Third-party components without label access
// Legacy code that can't be modified
// Truly unlabeled search inputs (still should fix accessibility)

test('search with legacy input', async ({ page }) => {
  // Document why placeholder is used
  // This input lacks proper labeling - tracked in ISSUE-123
  await page.getByPlaceholder('Search...').fill('shoes');
  await page.keyboard.press('Enter');
});
```

**Encourage accessible markup in component:**

```typescript
// components/SearchInput.tsx
export function SearchInput({ placeholder = 'Search...' }: Props) {
  return (
    <div className="search-container">
      <label htmlFor="search" className="sr-only">
        Search
      </label>
      <input
        id="search"
        type="search"
        placeholder={placeholder}
        aria-label="Search"
      />
    </div>
  );
}

// Test can use stable label
await page.getByLabel('Search').fill('shoes');
```

Reference: [Playwright getByPlaceholder](https://playwright.dev/docs/locators#locate-by-placeholder)

### 2.6 Use getByText for Static Content

**Impact: HIGH (matches user perception of the page)**

For static text content like headings, paragraphs, and labels, use `getByText` to select elements the way users see them.

**Incorrect (selecting by structure):**

```typescript
// tests/homepage.spec.ts
test('displays welcome message', async ({ page }) => {
  await page.goto('/');

  // Breaks when HTML structure changes
  await expect(page.locator('main > div > h1')).toHaveText('Welcome');

  // Breaks when class name changes
  await expect(page.locator('.hero-subtitle')).toBeVisible();

  // Too broad - may match unintended elements
  await expect(page.locator('p')).toContainText('Get started');
});
```

**Correct (selecting by text content):**

```typescript
// tests/homepage.spec.ts
test('displays welcome message', async ({ page }) => {
  await page.goto('/');

  // Direct text matching
  await expect(page.getByText('Welcome to our platform')).toBeVisible();

  // Exact text matching when needed
  await expect(page.getByText('Welcome', { exact: true })).toBeVisible();

  // Combine with role for specificity
  await expect(
    page.getByRole('heading', { name: 'Welcome to our platform' })
  ).toBeVisible();
});
```

**Handling partial text:**

```typescript
// Contains text (default behavior)
await expect(page.getByText('Sign up today')).toBeVisible();

// Matches "Sign up today and get 20% off"

// Exact text matching
await expect(page.getByText('Sign up today', { exact: true })).toBeVisible();
// Only matches exactly "Sign up today"

// Regex for flexible matching
await expect(page.getByText(/Sign up/i)).toBeVisible();
// Case-insensitive matching
```

**When NOT to use getByText:**
- Dynamic content that changes frequently
- Numbers or dates that vary
- User-generated content

```typescript
// For dynamic content, use data-testid instead
await expect(page.getByTestId('user-count')).toHaveText('42 users');
```

Reference: [Playwright getByText](https://playwright.dev/docs/locators#locate-by-text)

### 2.7 Use Role-Based Selectors Over CSS

**Impact: CRITICAL (80% reduction in selector-related flakiness)**

CSS selectors break when class names change or DOM structure shifts. Role-based selectors use accessibility attributes that reflect user perception and are more stable.

**Incorrect (brittle CSS selectors):**

```typescript
// tests/navigation.spec.ts
test('navigate to about page', async ({ page }) => {
  await page.goto('/');
  // Breaks when class name changes
  await page.click('.nav-link.about-link');
  // Breaks when nesting changes
  await page.click('div > ul > li:nth-child(2) > a');
  // Breaks when ID changes
  await page.click('#about-nav-item');
});
```

**Correct (role-based selectors):**

```typescript
// tests/navigation.spec.ts
test('navigate to about page', async ({ page }) => {
  await page.goto('/');

  // Uses ARIA role - stable across CSS/DOM changes
  await page.getByRole('link', { name: 'About' }).click();

  // For navigation elements
  await page.getByRole('navigation').getByRole('link', { name: 'About' }).click();

  // For buttons (even if styled as links)
  await page.getByRole('button', { name: 'Submit' }).click();
});
```

**Common role mappings:**

```typescript
// Buttons
page.getByRole('button', { name: 'Save' })

// Links
page.getByRole('link', { name: 'Home' })

// Headings
page.getByRole('heading', { name: 'Welcome', level: 1 })

// Form elements
page.getByRole('textbox', { name: 'Email' })
page.getByRole('checkbox', { name: 'Remember me' })
page.getByRole('combobox', { name: 'Country' })

// Lists
page.getByRole('list').getByRole('listitem')

// Dialogs
page.getByRole('dialog', { name: 'Confirm' })
```

**Benefits:**
- Selectors match how users perceive the page
- Encourages accessible markup
- Survives CSS refactors

Reference: [Playwright Locators](https://playwright.dev/docs/locators#locate-by-role)

---

## 3. Waiting & Assertions

**Impact: HIGH**

Auto-waiting and web-first assertions prevent timing-related failures; hard waits and manual checks are the second most common cause of flakiness.

### 3.1 Avoid Hard Waits

**Impact: HIGH (hard waits waste time or cause flakiness)**

`waitForTimeout` pauses for a fixed duration regardless of actual state. If the app is faster, you waste time. If slower, tests fail. Use auto-waiting or specific wait conditions instead.

**Incorrect (hard waits):**

```typescript
// tests/dashboard.spec.ts
test('loads dashboard data', async ({ page }) => {
  await page.goto('/dashboard');

  // WRONG: arbitrary wait, might be too short or too long
  await page.waitForTimeout(3000);
  await expect(page.getByTestId('stats-panel')).toBeVisible();

  await page.getByRole('button', { name: 'Refresh' }).click();

  // WRONG: guessing how long refresh takes
  await page.waitForTimeout(2000);
  await expect(page.getByText('Updated')).toBeVisible();
});
```

**Correct (specific wait conditions):**

```typescript
// tests/dashboard.spec.ts
test('loads dashboard data', async ({ page }) => {
  await page.goto('/dashboard');

  // Wait for specific element to appear
  await expect(page.getByTestId('stats-panel')).toBeVisible();

  await page.getByRole('button', { name: 'Refresh' }).click();

  // Wait for network request to complete
  await page.waitForResponse(
    (response) =>
      response.url().includes('/api/stats') && response.status() === 200
  );

  await expect(page.getByText('Updated')).toBeVisible();
});
```

**Alternative wait strategies:**

```typescript
// Wait for loading indicator to disappear
await expect(page.getByTestId('loading-spinner')).toBeHidden();

// Wait for specific network request
await page.waitForResponse('/api/users');

// Wait for navigation to complete
await Promise.all([
  page.waitForNavigation(),
  page.getByRole('link', { name: 'Profile' }).click(),
]);

// Wait for element state
await page.getByRole('button', { name: 'Submit' }).waitFor({ state: 'visible' });

// Wait for function condition
await page.waitForFunction(() => {
  return document.querySelector('.data-table')?.children.length > 0;
});
```

**When hard waits are acceptable (rare):**

```typescript
// Testing debounce behavior (intentional delay)
test('search debounces input', async ({ page }) => {
  await page.getByLabel('Search').fill('test');
  // Intentional: testing that search doesn't trigger immediately
  await page.waitForTimeout(100);
  await expect(page.getByTestId('search-results')).toBeHidden();

  // After debounce period, results appear
  await expect(page.getByTestId('search-results')).toBeVisible();
});
```

Reference: [Playwright Auto-Waiting](https://playwright.dev/docs/actionability)

### 3.2 Configure Timeouts Appropriately

**Impact: MEDIUM (balance between flakiness and fast feedback)**

Default timeouts may be too short for slow pages or too long for fast feedback. Configure timeouts based on your application's actual performance characteristics.

**Incorrect (default timeouts causing issues):**

```typescript
// playwright.config.ts
export default defineConfig({
  // Default: 30s test timeout might be too short for slow CI
  // Default: 5s assertion timeout might miss slow API responses
});

// tests/heavy-page.spec.ts
test('loads data visualization', async ({ page }) => {
  await page.goto('/analytics'); // Times out on slow networks
  await expect(page.getByTestId('chart')).toBeVisible(); // Times out waiting for data
});
```

**Correct (tuned timeouts):**

```typescript
// playwright.config.ts
export default defineConfig({
  // Global test timeout
  timeout: 60000, // 60s for tests

  // Assertion timeout
  expect: {
    timeout: 10000, // 10s for assertions
  },

  // Navigation timeout
  use: {
    navigationTimeout: 30000, // 30s for page loads
    actionTimeout: 15000, // 15s for actions like click
  },
});
```

**Per-test timeout overrides:**

```typescript
// For a single slow test
test('generates large report', async ({ page }) => {
  test.setTimeout(120000); // 2 minutes for this test only

  await page.goto('/reports/generate');
  await page.getByRole('button', { name: 'Generate Full Report' }).click();

  // This assertion gets extra time
  await expect(page.getByText('Report ready')).toBeVisible({
    timeout: 60000,
  });
});
```

**Environment-specific timeouts:**

```typescript
// playwright.config.ts
export default defineConfig({
  timeout: process.env.CI ? 60000 : 30000,

  expect: {
    timeout: process.env.CI ? 15000 : 5000,
  },

  use: {
    navigationTimeout: process.env.CI ? 45000 : 15000,
  },
});
```

**Timeout debugging:**

```typescript
// Add test info to understand where time is spent
test('slow page investigation', async ({ page }) => {
  const start = Date.now();

  await page.goto('/dashboard');
  console.log(`Navigation: ${Date.now() - start}ms`);

  await expect(page.getByTestId('content')).toBeVisible();
  console.log(`Content visible: ${Date.now() - start}ms`);
});
```

Reference: [Playwright Timeouts](https://playwright.dev/docs/test-timeouts)

### 3.3 Let Actions Auto-Wait Before Interacting

**Impact: HIGH (Playwright auto-waits for actionability)**

Playwright actions like `click()` and `fill()` automatically wait for elements to be visible, enabled, and stable. Don't add manual waits before actions.

**Incorrect (redundant manual waits):**

```typescript
// tests/form.spec.ts
test('submit contact form', async ({ page }) => {
  await page.goto('/contact');

  // WRONG: unnecessary waits before actions
  await page.waitForSelector('input[name="name"]');
  await page.getByLabel('Name').fill('John Doe');

  await page.waitForSelector('input[name="email"]', { state: 'visible' });
  await page.getByLabel('Email').fill('john@example.com');

  await page.waitForSelector('button[type="submit"]', { state: 'attached' });
  await page.getByRole('button', { name: 'Submit' }).click();
});
```

**Correct (rely on auto-waiting):**

```typescript
// tests/form.spec.ts
test('submit contact form', async ({ page }) => {
  await page.goto('/contact');

  // Actions auto-wait for elements to be actionable
  await page.getByLabel('Name').fill('John Doe');
  await page.getByLabel('Email').fill('john@example.com');
  await page.getByRole('button', { name: 'Submit' }).click();

  await expect(page.getByText('Message sent')).toBeVisible();
});
```

**What Playwright checks before actions:**

```typescript
// Before click(), Playwright verifies:
// - Element is attached to DOM
// - Element is visible
// - Element is stable (not animating)
// - Element receives events (not obscured)
// - Element is enabled

// Before fill(), Playwright also verifies:
// - Element is editable

// This all happens automatically - no manual waits needed
await page.getByRole('button', { name: 'Submit' }).click();
```

**When manual waits ARE needed:**

```typescript
// When waiting for element to disappear
await page.getByRole('button', { name: 'Submit' }).click();
await expect(page.getByTestId('loading')).toBeHidden();

// When element state determines test flow
const submitButton = page.getByRole('button', { name: 'Submit' });
await submitButton.waitFor({ state: 'visible' });
const isDisabled = await submitButton.isDisabled();
if (isDisabled) {
  // Handle disabled state
}

// When waiting for element to be removed from DOM entirely
await expect(page.getByTestId('modal')).not.toBeAttached();
```

Reference: [Playwright Auto-Waiting](https://playwright.dev/docs/actionability)

### 3.4 Use Network Idle for Complex Pages

**Impact: HIGH (waits for all resources to load)**

For pages with multiple API calls or lazy-loaded resources, `waitUntil: 'networkidle'` ensures all requests complete before assertions. Use judiciously—it can slow tests on pages with continuous polling.

**Incorrect (default navigation may finish too early):**

```typescript
// tests/analytics.spec.ts
test('shows complete analytics dashboard', async ({ page }) => {
  // Default 'load' event fires before all XHR requests complete
  await page.goto('/analytics');

  // May fail because chart data isn't loaded yet
  await expect(page.getByTestId('revenue-chart')).toBeVisible();
  await expect(page.getByTestId('users-chart')).toBeVisible();
  await expect(page.getByTestId('conversion-chart')).toBeVisible();
});
```

**Correct (wait for network idle):**

```typescript
// tests/analytics.spec.ts
test('shows complete analytics dashboard', async ({ page }) => {
  // Wait until no network requests for 500ms
  await page.goto('/analytics', { waitUntil: 'networkidle' });

  // All data loaded, charts rendered
  await expect(page.getByTestId('revenue-chart')).toBeVisible();
  await expect(page.getByTestId('users-chart')).toBeVisible();
  await expect(page.getByTestId('conversion-chart')).toBeVisible();
});
```

**Wait until options explained:**

```typescript
// 'domcontentloaded' - DOM is ready (fastest)
await page.goto('/page', { waitUntil: 'domcontentloaded' });

// 'load' - page fully loaded including images (default)
await page.goto('/page', { waitUntil: 'load' });

// 'networkidle' - no network requests for 500ms (slowest but most complete)
await page.goto('/page', { waitUntil: 'networkidle' });

// 'commit' - network response received (fastest, for SPAs)
await page.goto('/page', { waitUntil: 'commit' });
```

**When NOT to use networkidle:**

```typescript
// Pages with WebSocket connections or polling
// These never become truly "idle"

test('chat page loads', async ({ page }) => {
  // Don't use networkidle - WebSocket keeps connection open
  await page.goto('/chat', { waitUntil: 'domcontentloaded' });

  // Wait for specific content instead
  await expect(page.getByTestId('chat-messages')).toBeVisible();
});
```

**Alternative: wait for specific requests:**

```typescript
test('dashboard loads with data', async ({ page }) => {
  // More precise than networkidle
  const responsePromise = page.waitForResponse('/api/dashboard-data');
  await page.goto('/dashboard');
  await responsePromise;

  await expect(page.getByTestId('dashboard-content')).toBeVisible();
});
```

Reference: [Playwright Navigation](https://playwright.dev/docs/navigations)

### 3.5 Use Soft Assertions for Non-Critical Checks

**Impact: MEDIUM (collect multiple failures without stopping test)**

Soft assertions continue test execution even when they fail, collecting all failures for review. Use them for non-blocking checks where you want to see all issues at once.

**Incorrect (test stops at first failure):**

```typescript
// tests/profile.spec.ts
test('profile page displays all user info', async ({ page }) => {
  await page.goto('/profile');

  // Test stops at first failure - you don't see other issues
  await expect(page.getByTestId('username')).toHaveText('johndoe');
  await expect(page.getByTestId('email')).toHaveText('john@example.com');
  await expect(page.getByTestId('avatar')).toBeVisible();
  await expect(page.getByTestId('bio')).toContainText('Developer');
  await expect(page.getByTestId('join-date')).toBeVisible();
});
```

**Correct (soft assertions for comprehensive feedback):**

```typescript
// tests/profile.spec.ts
test('profile page displays all user info', async ({ page }) => {
  await page.goto('/profile');

  // Collect all failures - test continues after each failure
  await expect.soft(page.getByTestId('username')).toHaveText('johndoe');
  await expect.soft(page.getByTestId('email')).toHaveText('john@example.com');
  await expect.soft(page.getByTestId('avatar')).toBeVisible();
  await expect.soft(page.getByTestId('bio')).toContainText('Developer');
  await expect.soft(page.getByTestId('join-date')).toBeVisible();

  // At end, if any soft assertion failed, test fails with all errors
});
```

**Mix soft and hard assertions:**

```typescript
test('complete checkout flow', async ({ page }) => {
  await page.goto('/cart');

  // Hard assertion: test can't continue without this
  await expect(page.getByTestId('cart-items')).toHaveCount(3);

  // Soft assertions: check all details, report all issues
  await expect.soft(page.getByTestId('item-1-name')).toHaveText('Widget');
  await expect.soft(page.getByTestId('item-1-price')).toHaveText('$9.99');
  await expect.soft(page.getByTestId('item-2-name')).toHaveText('Gadget');
  await expect.soft(page.getByTestId('subtotal')).toHaveText('$29.97');

  // Hard assertion: critical for next step
  await page.getByRole('button', { name: 'Checkout' }).click();
  await expect(page).toHaveURL('/checkout');
});
```

**When to use soft assertions:**
- Checking multiple independent UI elements
- Validating form field values
- Verifying list contents
- Visual regression checks

**When NOT to use soft assertions:**
- Critical preconditions for next steps
- Navigation that affects subsequent tests
- State changes that must succeed

Reference: [Playwright Soft Assertions](https://playwright.dev/docs/test-assertions#soft-assertions)

### 3.6 Use Web-First Assertions

**Impact: HIGH (auto-retry eliminates timing failures)**

Web-first assertions automatically retry until conditions are met or timeout is reached. Manual assertions check once and fail immediately, causing flakiness.

**Incorrect (manual assertions):**

```typescript
// tests/loading.spec.ts
test('shows success message after save', async ({ page }) => {
  await page.goto('/settings');
  await page.getByLabel('Name').fill('John Doe');
  await page.getByRole('button', { name: 'Save' }).click();

  // WRONG: checks once, fails if element isn't immediately visible
  const isVisible = await page.getByText('Settings saved').isVisible();
  expect(isVisible).toBe(true);

  // WRONG: same problem with getAttribute
  const text = await page.locator('.status').textContent();
  expect(text).toBe('Success');
});
```

**Correct (web-first assertions):**

```typescript
// tests/loading.spec.ts
test('shows success message after save', async ({ page }) => {
  await page.goto('/settings');
  await page.getByLabel('Name').fill('John Doe');
  await page.getByRole('button', { name: 'Save' }).click();

  // Auto-retries until visible or timeout
  await expect(page.getByText('Settings saved')).toBeVisible();

  // Auto-retries text content check
  await expect(page.locator('.status')).toHaveText('Success');
});
```

**Common web-first assertions:**

```typescript
// Visibility
await expect(locator).toBeVisible();
await expect(locator).toBeHidden();

// Text content
await expect(locator).toHaveText('Expected');
await expect(locator).toContainText('partial');

// Attributes
await expect(locator).toHaveAttribute('href', '/home');
await expect(locator).toHaveClass(/active/);

// Form state
await expect(locator).toBeEnabled();
await expect(locator).toBeDisabled();
await expect(locator).toBeChecked();
await expect(locator).toHaveValue('input value');

// Count
await expect(locator).toHaveCount(5);

// URL
await expect(page).toHaveURL('/dashboard');
await expect(page).toHaveTitle('Dashboard');
```

**Configuring assertion timeout:**

```typescript
// playwright.config.ts
export default defineConfig({
  expect: {
    timeout: 10000, // 10 seconds for slow pages
  },
});

// Or per-assertion
await expect(locator).toBeVisible({ timeout: 15000 });
```

Reference: [Playwright Assertions](https://playwright.dev/docs/test-assertions)

---

## 4. Authentication & State

**Impact: HIGH**

Session reuse and storage state patterns reduce test execution time by 60-80% while eliminating login-related flakiness.

### 4.1 Handle Session Storage for Auth

**Impact: HIGH (preserves auth state that uses sessionStorage)**

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

### 4.2 Reuse Authentication with Storage State

**Impact: HIGH (60-80% reduction in test execution time)**

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

### 4.3 Use API Login for Faster Auth Setup

**Impact: HIGH (5-10× faster than UI login)**

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

### 4.4 Use Separate Storage States for Different Roles

**Impact: HIGH (test role-specific features efficiently)**

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

### 4.5 Use Worker-Scoped Auth for Parallel Tests

**Impact: MEDIUM-HIGH (enables parallel testing with unique sessions)**

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

---

## 5. Mocking & Network

**Impact: MEDIUM-HIGH**

API mocking and network interception eliminate external dependencies, making tests deterministic and independent of backend state.

### 5.1 Abort Unnecessary Requests

**Impact: MEDIUM (30-50% faster page loads in tests)**

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

### 5.2 Intercept and Modify Real Responses

**Impact: MEDIUM-HIGH (test edge cases with real data structure)**

Sometimes you need real API response structure but want to modify specific values. Intercept the response, modify it, and return the altered version.

**Incorrect (fully mocked response may miss fields):**

```typescript
test('handles zero inventory', async ({ page }) => {
  // May miss required fields that real API returns
  await page.route('/api/product/1', async (route) => {
    await route.fulfill({
      body: JSON.stringify({
        id: 1,
        name: 'Widget',
        inventory: 0, // Testing this
        // Missing: price, description, images, reviews, etc.
      }),
    });
  });

  await page.goto('/product/1');
  // Test may fail due to missing fields
});
```

**Correct (intercept and modify real response):**

```typescript
test('handles zero inventory', async ({ page }) => {
  await page.route('/api/product/1', async (route) => {
    // Get real response
    const response = await route.fetch();
    const json = await response.json();

    // Modify only what we need to test
    json.inventory = 0;
    json.inStock = false;

    await route.fulfill({
      response,
      body: JSON.stringify(json),
    });
  });

  await page.goto('/product/1');

  await expect(page.getByText('Out of Stock')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Add to Cart' })).toBeDisabled();
});
```

**Modify response headers:**

```typescript
test('handles expired cache', async ({ page }) => {
  await page.route('/api/data', async (route) => {
    const response = await route.fetch();

    await route.fulfill({
      response,
      headers: {
        ...response.headers(),
        'cache-control': 'no-cache', // Force fresh data
        'x-cache': 'MISS',
      },
    });
  });

  await page.goto('/dashboard');
  // Verify app handles cache miss correctly
});
```

**Add delay to real response:**

```typescript
test('shows loading state', async ({ page }) => {
  await page.route('/api/slow-data', async (route) => {
    // Add artificial delay to test loading UI
    await new Promise((resolve) => setTimeout(resolve, 2000));
    await route.continue();
  });

  await page.goto('/dashboard');

  // Loading state should be visible during delay
  await expect(page.getByTestId('loading-spinner')).toBeVisible();

  // Then data appears
  await expect(page.getByTestId('data-content')).toBeVisible();
});
```

Reference: [Playwright Route Fetch](https://playwright.dev/docs/mock#mocking-with-har-files)

### 5.3 Mock API Responses for Deterministic Tests

**Impact: MEDIUM-HIGH (eliminates external dependencies)**

Real API calls make tests slow and flaky due to network variability, rate limits, and data changes. Mock responses to control exactly what your app receives.

**Incorrect (real API calls):**

```typescript
// tests/products.spec.ts
test('displays product list', async ({ page }) => {
  await page.goto('/products');

  // Depends on real API state - could change anytime
  // Slow due to network latency
  // May fail due to rate limits
  await expect(page.getByTestId('product-card')).toHaveCount(10);
});
```

**Correct (mocked API responses):**

```typescript
// tests/products.spec.ts
test('displays product list', async ({ page }) => {
  // Intercept API calls and return mock data
  await page.route('/api/products', async (route) => {
    await route.fulfill({
      status: 200,
      contentType: 'application/json',
      body: JSON.stringify({
        products: [
          { id: 1, name: 'Widget', price: 9.99 },
          { id: 2, name: 'Gadget', price: 19.99 },
          { id: 3, name: 'Gizmo', price: 29.99 },
        ],
      }),
    });
  });

  await page.goto('/products');

  // Test against controlled data
  await expect(page.getByTestId('product-card')).toHaveCount(3);
  await expect(page.getByText('Widget')).toBeVisible();
  await expect(page.getByText('$9.99')).toBeVisible();
});
```

**Mock error responses:**

```typescript
test('shows error message on API failure', async ({ page }) => {
  await page.route('/api/products', async (route) => {
    await route.fulfill({
      status: 500,
      contentType: 'application/json',
      body: JSON.stringify({ error: 'Internal Server Error' }),
    });
  });

  await page.goto('/products');

  await expect(page.getByText('Failed to load products')).toBeVisible();
  await expect(page.getByRole('button', { name: 'Retry' })).toBeVisible();
});
```

**Mock with pattern matching:**

```typescript
// Mock all API routes
await page.route('/api/**', async (route) => {
  const url = route.request().url();

  if (url.includes('/api/user')) {
    await route.fulfill({ body: JSON.stringify({ name: 'John' }) });
  } else if (url.includes('/api/products')) {
    await route.fulfill({ body: JSON.stringify({ products: [] }) });
  } else {
    await route.continue(); // Let unmatched requests through
  }
});
```

Reference: [Playwright Network Mocking](https://playwright.dev/docs/mock)

### 5.4 Simulate Network Conditions

**Impact: MEDIUM (validates offline and slow network behavior)**

Test how your app behaves under poor network conditions. Playwright can simulate slow networks, offline mode, and connection changes.

**Incorrect (no network condition testing):**

```typescript
// tests/dashboard.spec.ts
test('dashboard works', async ({ page }) => {
  // Only tests happy path with good network
  await page.goto('/dashboard');
  await expect(page.getByTestId('content')).toBeVisible();

  // Never tests:
  // - What happens when user goes offline?
  // - Does loading state appear on slow networks?
  // - Does the app recover after network failures?
});
```

**Correct (test network conditions):**

```typescript
// tests/dashboard.spec.ts
test('shows offline message when disconnected', async ({ page, context }) => {
  await page.goto('/dashboard');

  // Go offline
  await context.setOffline(true);

  // Trigger a network request
  await page.getByRole('button', { name: 'Refresh' }).click();

  // Should show offline message
  await expect(page.getByText('You are offline')).toBeVisible();

  // Go back online
  await context.setOffline(false);
  await page.getByRole('button', { name: 'Retry' }).click();

  // Should recover
  await expect(page.getByTestId('data-content')).toBeVisible();
});
```

**Simulating slow network:**

```typescript
test('shows loading states on slow network', async ({ page }) => {
  // Throttle network requests
  const client = await page.context().newCDPSession(page);
  await client.send('Network.emulateNetworkConditions', {
    offline: false,
    downloadThroughput: (50 * 1024) / 8, // 50kb/s
    uploadThroughput: (20 * 1024) / 8, // 20kb/s
    latency: 500, // 500ms latency
  });

  await page.goto('/dashboard');

  // Loading state should be visible due to slow network
  await expect(page.getByTestId('loading-skeleton')).toBeVisible();

  // Eventually content loads
  await expect(page.getByTestId('dashboard-content')).toBeVisible({
    timeout: 30000,
  });
});
```

**Simulate network failure mid-request:**

```typescript
test('recovers from network failure', async ({ page }) => {
  let requestCount = 0;

  await page.route('/api/data', async (route) => {
    requestCount++;
    if (requestCount === 1) {
      await route.abort('failed'); // First request fails
    } else {
      await route.fulfill({ body: JSON.stringify({ data: 'success' }) });
    }
  });

  await page.goto('/dashboard');
  await expect(page.getByText('success')).toBeVisible();
});
```

Reference: [Playwright Network Emulation](https://playwright.dev/docs/api/class-browsercontext#browser-context-set-offline)

### 5.5 Use HAR Files for Complex Mock Scenarios

**Impact: MEDIUM (realistic multi-request mocking)**

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

---

## 6. Next.js Integration

**Impact: MEDIUM**

App Router, Server Components, and hydration-specific patterns address Next.js-specific testing challenges that cause subtle failures.

### 6.1 Configure baseURL for Clean Navigation

**Impact: MEDIUM (cleaner test code, easier environment switching)**

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

### 6.2 Test App Router Navigation Patterns

**Impact: MEDIUM (validates soft navigation preserves state)**

App Router uses soft navigation (client-side) between routes. Test that layouts persist, loading states work, and navigation doesn't cause unnecessary re-renders.

**Incorrect (no layout state testing):**

```typescript
// tests/navigation.spec.ts
test('navigation works', async ({ page }) => {
  await page.goto('/dashboard');
  await page.getByRole('link', { name: 'Settings' }).click();
  await expect(page).toHaveURL('/dashboard/settings');
  // Only tests URL changed - doesn't verify:
  // - Layout state persisted
  // - Loading UI appeared
  // - No full page reload
});
```

**Correct (verify soft navigation behavior):**

```typescript
// tests/navigation.spec.ts
test('soft navigation preserves layout state', async ({ page }) => {
  await page.goto('/dashboard');

  // Set some state in the layout (e.g., sidebar collapsed)
  await page.getByRole('button', { name: 'Collapse Sidebar' }).click();
  await expect(page.getByTestId('sidebar')).toHaveClass(/collapsed/);

  // Navigate to nested route
  await page.getByRole('link', { name: 'Settings' }).click();
  await expect(page).toHaveURL('/dashboard/settings');

  // Layout state should persist (sidebar still collapsed)
  await expect(page.getByTestId('sidebar')).toHaveClass(/collapsed/);
});
```

**Test loading UI during navigation:**

```typescript
test('shows loading state during navigation', async ({ page }) => {
  await page.goto('/products');

  // Slow down the navigation target
  await page.route('/api/product/*', async (route) => {
    await new Promise((r) => setTimeout(r, 1000));
    await route.fulfill({ body: JSON.stringify({ name: 'Widget' }) });
  });

  // Click to navigate
  await page.getByRole('link', { name: 'View Widget' }).click();

  // loading.tsx should render
  await expect(page.getByTestId('product-loading')).toBeVisible();

  // Then actual content
  await expect(page.getByTestId('product-details')).toBeVisible();
});
```

**Test parallel routes:**

```typescript
test('parallel routes render independently', async ({ page }) => {
  await page.goto('/dashboard');

  // Both parallel route slots should render
  await expect(page.getByTestId('stats-slot')).toBeVisible();
  await expect(page.getByTestId('activity-slot')).toBeVisible();

  // Opening modal keeps background content
  await page.getByRole('button', { name: 'View Details' }).click();
  await expect(page.getByRole('dialog')).toBeVisible();
  await expect(page.getByTestId('stats-slot')).toBeVisible();
});
```

Reference: [Next.js App Router](https://nextjs.org/docs/app)

### 6.3 Test Server Actions End-to-End

**Impact: MEDIUM (validates complete form-to-server flow)**

Server Actions handle form submissions and mutations. Test them through the UI to verify the complete flow from form to server and back.

**Incorrect (incomplete server action testing):**

```typescript
// tests/contact.spec.ts
test('submit form', async ({ page }) => {
  await page.goto('/contact');
  await page.getByLabel('Name').fill('John');
  await page.getByRole('button', { name: 'Submit' }).click();
  // Only checks button was clicked - doesn't verify:
  // - Server action completed
  // - Success/error feedback appeared
  // - Form state reset properly
});
```

**Correct (complete server action testing):**

```typescript
// tests/contact.spec.ts
test('submit contact form via server action', async ({ page }) => {
  await page.goto('/contact');

  // Fill out form
  await page.getByLabel('Name').fill('John Doe');
  await page.getByLabel('Email').fill('john@example.com');
  await page.getByLabel('Message').fill('Hello, this is a test message.');

  // Submit triggers server action
  await page.getByRole('button', { name: 'Send Message' }).click();

  // Verify success feedback (server action completed)
  await expect(page.getByText('Message sent successfully')).toBeVisible();

  // Form should reset
  await expect(page.getByLabel('Name')).toHaveValue('');
});
```

**Test Server Action error handling:**

```typescript
test('server action validation errors', async ({ page }) => {
  await page.goto('/contact');

  // Submit without required fields
  await page.getByRole('button', { name: 'Send Message' }).click();

  // Server action returns validation errors
  await expect(page.getByText('Name is required')).toBeVisible();
  await expect(page.getByText('Email is required')).toBeVisible();
});
```

**Test useFormStatus integration:**

```typescript
test('shows pending state during server action', async ({ page }) => {
  // Slow down the server action
  await page.route('/contact', async (route) => {
    if (route.request().method() === 'POST') {
      await new Promise((r) => setTimeout(r, 2000));
    }
    await route.continue();
  });

  await page.goto('/contact');
  await page.getByLabel('Name').fill('John Doe');
  await page.getByLabel('Email').fill('john@example.com');
  await page.getByLabel('Message').fill('Test');

  await page.getByRole('button', { name: 'Send Message' }).click();

  // Button should show pending state
  await expect(page.getByRole('button', { name: 'Sending...' })).toBeVisible();
  await expect(page.getByRole('button', { name: 'Sending...' })).toBeDisabled();
});
```

Reference: [Next.js Server Actions](https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations)

### 6.4 Test Server Components Correctly

**Impact: MEDIUM (validates RSC behavior end-to-end)**

React Server Components (RSC) render on the server and stream HTML to the client. Test them through E2E tests that verify the final rendered output, not unit tests.

**Incorrect (trying to unit test RSC):**

```typescript
// This won't work - RSC can't be tested with React Testing Library
import { render } from '@testing-library/react';
import { UserProfile } from './UserProfile'; // Server Component

test('renders user profile', () => {
  // Error: async Server Components can't render client-side
  render(<UserProfile userId="123" />);
});
```

**Correct (E2E test for RSC):**

```typescript
// tests/user-profile.spec.ts
test('server component renders user data', async ({ page }) => {
  await page.goto('/user/123');

  // RSC has rendered and streamed to client
  await expect(page.getByTestId('user-name')).toHaveText('John Doe');
  await expect(page.getByTestId('user-email')).toHaveText('john@example.com');

  // Server-fetched data is present
  await expect(page.getByTestId('user-posts')).toHaveCount(5);
});
```

**Mock server data with MSW for RSC:**

```typescript
// For testing RSC with mocked data, use Mock Service Worker
// This intercepts server-side fetch calls

// tests/user-profile.spec.ts
import { setupServer } from 'msw/node';
import { http, HttpResponse } from 'msw';

test('RSC with mocked data', async ({ page }) => {
  // Playwright can't mock RSC's server-side fetches directly
  // Instead, mock at the API level

  await page.route('/api/user/*', async (route) => {
    await route.fulfill({
      body: JSON.stringify({
        id: '123',
        name: 'Test User',
        email: 'test@example.com',
      }),
    });
  });

  await page.goto('/user/123');

  await expect(page.getByTestId('user-name')).toHaveText('Test User');
});
```

**Test Suspense boundaries:**

```typescript
test('shows loading state then content', async ({ page }) => {
  // Slow down API to see loading state
  await page.route('/api/slow-data', async (route) => {
    await new Promise((r) => setTimeout(r, 2000));
    await route.fulfill({ body: JSON.stringify({ data: 'loaded' }) });
  });

  await page.goto('/dashboard');

  // Suspense fallback should show first
  await expect(page.getByTestId('loading-skeleton')).toBeVisible();

  // Then real content streams in
  await expect(page.getByTestId('dashboard-content')).toBeVisible();
  await expect(page.getByTestId('loading-skeleton')).toBeHidden();
});
```

Reference: [Testing Next.js](https://nextjs.org/docs/app/guides/testing)

### 6.5 Wait for Hydration Before Interacting

**Impact: MEDIUM (prevents hydration mismatch errors)**

Next.js renders HTML on the server, then hydrates it with JavaScript. Interacting before hydration completes can cause errors or unresponsive elements.

**Incorrect (interact before hydration):**

```typescript
test('submit form', async ({ page }) => {
  await page.goto('/contact');

  // May interact with server-rendered HTML before JS loads
  // Button might not have click handler attached yet
  await page.getByRole('button', { name: 'Submit' }).click();

  // Nothing happens - JS wasn't ready
});
```

**Correct (wait for hydration indicators):**

```typescript
test('submit form', async ({ page }) => {
  await page.goto('/contact');

  // Wait for hydration - JavaScript has loaded and attached handlers
  // Option 1: Wait for client-only element to appear
  await expect(page.getByTestId('hydration-complete')).toBeVisible();

  // Option 2: Wait for interactive element state
  await expect(page.getByRole('button', { name: 'Submit' })).toBeEnabled();

  // Now safe to interact
  await page.getByRole('button', { name: 'Submit' }).click();
});
```

**Add hydration marker in your app:**

```tsx
// components/HydrationMarker.tsx
'use client';

import { useEffect, useState } from 'react';

export function HydrationMarker() {
  const [hydrated, setHydrated] = useState(false);

  useEffect(() => {
    setHydrated(true);
  }, []);

  if (!hydrated) return null;

  return <div data-testid="hydration-complete" style={{ display: 'none' }} />;
}

// app/layout.tsx
export default function RootLayout({ children }) {
  return (
    <html>
      <body>
        {children}
        <HydrationMarker />
      </body>
    </html>
  );
}
```

**Wait for specific interactive behavior:**

```typescript
test('interactive dropdown works', async ({ page }) => {
  await page.goto('/settings');

  const dropdown = page.getByRole('combobox', { name: 'Language' });

  // Wait for dropdown to be interactive (hydrated)
  await dropdown.waitFor({ state: 'visible' });

  // Verify it responds to click (JS attached)
  await dropdown.click();
  await expect(page.getByRole('option', { name: 'English' })).toBeVisible();
});
```

**Alternative: networkidle for full hydration:**

```typescript
test('fully hydrated page', async ({ page }) => {
  // networkidle waits for all JS to load and execute
  await page.goto('/dashboard', { waitUntil: 'networkidle' });

  // Page is fully hydrated
  await page.getByRole('button', { name: 'Action' }).click();
});
```

Reference: [Next.js Hydration](https://nextjs.org/docs/messages/react-hydration-error)

---

## 7. Performance & Speed

**Impact: MEDIUM**

Parallel execution, sharding, and resource optimization reduce test suite runtime from minutes to seconds.

### 7.1 Configure Retries for Flaky Test Recovery

**Impact: MEDIUM (reduces false negatives from intermittent failures)**

Some test flakiness is unavoidable (network, timing). Configure retries to automatically recover from intermittent failures, especially in CI.

**Incorrect (no retries, tests fail on first flake):**

```typescript
// playwright.config.ts
export default defineConfig({
  // No retries configured
  // Any flaky test fails the entire CI run
});
```

**Correct (strategic retries):**

```typescript
// playwright.config.ts
export default defineConfig({
  // More retries in CI where flakiness is more common
  retries: process.env.CI ? 2 : 0,

  // Use reporter to track which tests needed retries
  reporter: [
    ['html', { open: 'never' }],
    ['list'],
  ],
});
```

**Retry configuration options:**

```typescript
// playwright.config.ts
export default defineConfig({
  retries: 2,

  // Only rerun failed tests, not entire file
  use: {
    trace: 'on-first-retry', // Capture trace on retry for debugging
    video: 'on-first-retry',
    screenshot: 'only-on-failure',
  },
});
```

**Per-test retry configuration:**

```typescript
// tests/critical.spec.ts
import { test } from '@playwright/test';

// Critical tests get extra retries
test.describe('payment flow', () => {
  test.describe.configure({ retries: 3 });

  test('complete checkout', async ({ page }) => {
    // This test gets 3 retries
  });
});

// Unstable third-party integration
test('external API test', async ({ page }) => {
  test.info().annotations.push({ type: 'flaky', description: 'External API' });
  // ...
});
```

**Identify and fix flaky tests:**

```typescript
// Instead of relying on retries, fix the root cause

// BAD: Flaky due to timing
test('shows notification', async ({ page }) => {
  await page.click('#trigger');
  await page.waitForTimeout(1000); // Hoping it's enough
  await expect(page.getByText('Done')).toBeVisible();
});

// GOOD: Deterministic wait
test('shows notification', async ({ page }) => {
  await page.click('#trigger');
  await expect(page.getByText('Done')).toBeVisible(); // Auto-retries
});
```

**Monitor retry rate:**

```bash
# See which tests are flaky
npx playwright test --reporter=list

# Output shows:
# ✓ [1/2] test name (1.2s) [retry #1]
# Investigate tests that consistently need retries
```

Reference: [Playwright Retries](https://playwright.dev/docs/test-retries)

### 7.2 Reuse Development Server When Possible

**Impact: MEDIUM (eliminates 30-60s server startup per test run)**

Starting a new server for each test run wastes time during local development. Reuse an existing server when available.

**Incorrect (always starts new server):**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: 'npm run build && npm run start',
    url: 'http://localhost:3000',
    // Always starts new server, even if one is running
    reuseExistingServer: false,
  },
});
```

**Correct (reuse locally, fresh in CI):**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: 'npm run build && npm run start',
    url: 'http://localhost:3000',
    // Reuse existing server locally, start fresh in CI
    reuseExistingServer: !process.env.CI,
    timeout: 120000, // Build can take time
  },
});
```

**Local development workflow:**

```bash
# Terminal 1: Start dev server once
npm run dev

# Terminal 2: Run tests repeatedly (reuses server)
npx playwright test
npx playwright test --watch
```

**Multiple servers for different apps:**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: [
    {
      command: 'npm run start:frontend',
      url: 'http://localhost:3000',
      reuseExistingServer: !process.env.CI,
    },
    {
      command: 'npm run start:api',
      url: 'http://localhost:4000',
      reuseExistingServer: !process.env.CI,
    },
  ],
});
```

**Environment-specific server commands:**

```typescript
// playwright.config.ts
export default defineConfig({
  webServer: {
    command: process.env.CI
      ? 'npm run build && npm run start' // Production build in CI
      : 'npm run dev', // Dev server locally
    url: 'http://localhost:3000',
    reuseExistingServer: !process.env.CI,
  },
});
```

**Benefits of reuse:**

| Scenario | New Server | Reuse Server |
|----------|------------|--------------|
| Local test run | 30-60s startup | Instant |
| Watch mode | New server per run | Same server |
| CI | Fresh server (correct) | N/A |

Reference: [Playwright Web Server](https://playwright.dev/docs/test-webserver)

### 7.3 Select Browsers Strategically

**Impact: MEDIUM (balance coverage vs execution time)**

Testing all browsers on every commit is slow. Run quick Chromium tests on PRs, full cross-browser testing on main branch or nightly.

**Incorrect (all browsers on every run):**

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
    { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
    { name: 'webkit', use: { ...devices['Desktop Safari'] } },
    { name: 'mobile-chrome', use: { ...devices['Pixel 5'] } },
    { name: 'mobile-safari', use: { ...devices['iPhone 12'] } },
  ],
  // All 5 browsers run on every commit - 5× the time
});
```

**Correct (tiered browser testing):**

```typescript
// playwright.config.ts
const isCI = process.env.CI;
const isMainBranch = process.env.GITHUB_REF === 'refs/heads/main';

export default defineConfig({
  projects: [
    // Always run Chromium - fastest feedback
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },

    // Cross-browser only on main or scheduled
    ...(isMainBranch || process.env.FULL_TEST
      ? [
          { name: 'firefox', use: { ...devices['Desktop Firefox'] } },
          { name: 'webkit', use: { ...devices['Desktop Safari'] } },
        ]
      : []),
  ],
});
```

**CI workflow with conditional browsers:**

```yaml
# .github/workflows/test.yml
name: Tests

on:
  pull_request:
  push:
    branches: [main]
  schedule:
    - cron: '0 0 * * *' # Nightly

jobs:
  test-quick:
    if: github.event_name == 'pull_request'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright test --project=chromium

  test-full:
    if: github.ref == 'refs/heads/main' || github.event_name == 'schedule'
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright test
        env:
          FULL_TEST: true
```

**Run specific browser locally:**

```bash
# Quick test on Chromium only
npx playwright test --project=chromium

# Full cross-browser test
npx playwright test

# Test specific browser
npx playwright test --project=firefox
```

**Speed comparison:**

| Strategy | Time | Coverage |
|----------|------|----------|
| Chromium only | 1× | 70% of issues |
| Chromium + Firefox | 2× | 90% of issues |
| All 5 browsers | 5× | 99% of issues |

Reference: [Playwright Projects](https://playwright.dev/docs/test-projects)

### 7.4 Use Headless Mode in CI

**Impact: MEDIUM (30-40% faster execution, less resource usage)**

Running browsers in headless mode (no visible UI) is faster and uses less memory. Enable it in CI environments.

**Incorrect (headed mode in CI):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    headless: false, // Shows browser UI - slow and resource-intensive
  },
});
```

**Correct (headless in CI, headed locally for debugging):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Headless in CI, headed when debugging locally
    headless: process.env.CI ? true : false,
  },
});
```

**Or use CLI flag:**

```bash
# CI: headless by default
npx playwright test

# Local debugging: headed
npx playwright test --headed

# Debug with Playwright Inspector
npx playwright test --debug
```

**Project-specific headless config:**

```typescript
// playwright.config.ts
export default defineConfig({
  projects: [
    {
      name: 'chromium',
      use: {
        ...devices['Desktop Chrome'],
        headless: true,
      },
    },
    {
      name: 'debug',
      use: {
        ...devices['Desktop Chrome'],
        headless: false,
        launchOptions: {
          slowMo: 100, // Slow down for visual debugging
        },
      },
    },
  ],
});

// Run headless
// npx playwright test --project=chromium

// Run headed for debugging
// npx playwright test --project=debug
```

**Performance comparison:**

| Mode | Speed | Memory | Use Case |
|------|-------|--------|----------|
| Headless | 100% | ~100MB | CI, automated runs |
| Headed | 60-70% | ~300MB | Debugging, demos |
| Headed + slowMo | 30-50% | ~300MB | Step-by-step debugging |

**CI configuration example:**

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: npx playwright test
  env:
    CI: true
    # Playwright automatically runs headless when CI=true
```

Reference: [Playwright Test Configuration](https://playwright.dev/docs/test-configuration#testing-options)

### 7.5 Use Sharding for Large Test Suites

**Impact: MEDIUM (50-80% faster CI with distributed execution)**

For large test suites, split tests across multiple CI machines using sharding. Each shard runs a portion of tests in parallel.

**Incorrect (single machine runs all tests):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright test
      # All 500 tests run on one machine - takes 30 minutes
```

**Correct (sharded across machines):**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      fail-fast: false
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright install --with-deps
      - run: npx playwright test --shard=${{ matrix.shard }}/4
      # Each machine runs ~125 tests - total time ~8 minutes
```

**Merge test reports from shards:**

```yaml
# .github/workflows/test.yml
jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - run: npx playwright test --shard=${{ matrix.shard }}/4
      - uses: actions/upload-artifact@v4
        if: always()
        with:
          name: blob-report-${{ matrix.shard }}
          path: blob-report
          retention-days: 1

  merge-reports:
    needs: test
    runs-on: ubuntu-latest
    if: always()
    steps:
      - uses: actions/checkout@v4
      - run: npm ci
      - uses: actions/download-artifact@v4
        with:
          pattern: blob-report-*
          merge-multiple: true
          path: all-blob-reports
      - run: npx playwright merge-reports --reporter html ./all-blob-reports
      - uses: actions/upload-artifact@v4
        with:
          name: html-report
          path: playwright-report
```

**Configure blob reporter for sharding:**

```typescript
// playwright.config.ts
export default defineConfig({
  reporter: process.env.CI
    ? [['blob'], ['github']] // Blob for merging, GitHub for annotations
    : [['html', { open: 'never' }]],
});
```

**Optimal shard count:**

| Test Count | Recommended Shards |
|------------|-------------------|
| < 50 | 1 (no sharding) |
| 50-200 | 2-4 |
| 200-500 | 4-8 |
| 500+ | 8-16 |

Reference: [Playwright Sharding](https://playwright.dev/docs/test-sharding)

---

## 8. Debugging & CI

**Impact: LOW-MEDIUM**

Tracing, screenshots, and CI integration provide visibility into failures and enable efficient debugging workflows.

### 8.1 Capture Screenshots and Videos on Failure

**Impact: LOW-MEDIUM (50% faster failure investigation)**

Visual artifacts provide immediate insight into what the page looked like when a test failed. Configure automatic capture for efficient debugging.

**Incorrect (no artifact capture):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // No screenshot or video configuration
    // When tests fail, you only get error messages
  },
});

// Test failure output:
// Error: expect(locator).toBeVisible()
// Locator: getByText('Welcome')
// - No visual of actual page state
// - No recording of what led to failure
```

**Correct (capture on failure):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Screenshots on failure
    screenshot: 'only-on-failure',

    // Video on failure
    video: 'retain-on-failure',
  },
});

// Test failure now includes:
// - Screenshot of final page state
// - Video of entire test execution
```

**Video configuration options:**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    video: {
      mode: 'retain-on-failure',
      size: { width: 1280, height: 720 }, // Video resolution
    },
  },
});
```

**CI artifact upload:**

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: npx playwright test

- name: Upload screenshots and videos
  uses: actions/upload-artifact@v4
  if: failure()
  with:
    name: test-artifacts
    path: |
      test-results/**/*.png
      test-results/**/*.webm
    retention-days: 7
```

**Storage considerations:**

| Artifact | Typical Size | Recommendation |
|----------|--------------|----------------|
| Screenshot | 100-500KB | Always capture on failure |
| Video (30s) | 2-5MB | Retain on failure only |
| Trace | 5-20MB | On first retry |

Reference: [Playwright Screenshots](https://playwright.dev/docs/screenshots)

### 8.2 Configure Reporters for CI Integration

**Impact: LOW-MEDIUM (2× faster CI failure triage)**

Choose reporters that integrate with your CI system. GitHub Actions annotations, JUnit XML, and HTML reports each serve different purposes.

**Incorrect (default reporter only):**

```typescript
// playwright.config.ts
export default defineConfig({
  // Default reporter only shows console output
  // No CI integration, no artifacts
});

// CI output:
// FAILED tests/login.spec.ts:15
// Error: expect(locator).toBeVisible()
// - No GitHub annotations
// - No browsable report
// - Hard to find in CI logs
```

**Correct (multi-reporter for CI):**

```typescript
// playwright.config.ts
export default defineConfig({
  reporter: process.env.CI
    ? [
        ['github'], // GitHub Actions annotations
        ['junit', { outputFile: 'test-results/junit.xml' }], // CI systems
        ['html', { open: 'never' }], // Detailed HTML report
      ]
    : [
        ['list'], // Console output
        ['html', { open: 'on-failure' }], // Open HTML on failure
      ],
});

// CI output now includes:
// - Inline annotations on PR files
// - JUnit for CI dashboards
// - HTML report artifact
```

**JUnit for CI dashboards:**

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: npx playwright test

- name: Publish Test Results
  uses: dorny/test-reporter@v1
  if: always()
  with:
    name: Playwright Tests
    path: test-results/junit.xml
    reporter: java-junit
```

**HTML report hosting:**

```yaml
# .github/workflows/test.yml
- name: Upload HTML Report
  uses: actions/upload-artifact@v4
  if: always()
  with:
    name: playwright-report
    path: playwright-report/
    retention-days: 14
```

Reference: [Playwright Reporters](https://playwright.dev/docs/test-reporters)

### 8.3 Use Playwright Inspector for Interactive Debugging

**Impact: LOW-MEDIUM (5× faster test development and debugging)**

Playwright Inspector lets you step through tests interactively, inspect selectors, and generate code. Use it for developing new tests and debugging failures.

**Incorrect (blind debugging):**

```typescript
// tests/checkout.spec.ts
test('complete checkout', async ({ page }) => {
  await page.goto('/checkout');

  // Something fails here but you don't know why
  await page.getByRole('button', { name: 'Pay' }).click();
  // Error: locator.click: Target closed

  // Without inspector, you're guessing:
  // - Is the button there?
  // - Is it visible?
  // - Is there an overlay blocking it?
});

// Run: npx playwright test
// Output: Error with no visual context
```

**Correct (interactive debugging):**

```typescript
// tests/checkout.spec.ts
test('complete checkout', async ({ page }) => {
  await page.goto('/checkout');

  // Add breakpoint to pause and inspect
  await page.pause();

  // Now you can:
  // - See the actual page state
  // - Test different selectors
  // - Step through one action at a time
  await page.getByRole('button', { name: 'Pay' }).click();
});

// Run: npx playwright test --debug
// Inspector opens with full visibility
```

**Launch inspector methods:**

```bash
# Run all tests with inspector
npx playwright test --debug

# Run specific test with inspector
npx playwright test tests/login.spec.ts --debug

# Debug specific test by name
npx playwright test -g "login flow" --debug
```

**VS Code integration:**

```json
// .vscode/launch.json
{
  "version": "0.2.0",
  "configurations": [
    {
      "type": "node",
      "request": "launch",
      "name": "Debug Playwright Tests",
      "runtimeExecutable": "npx",
      "runtimeArgs": ["playwright", "test", "--debug"],
      "console": "integratedTerminal"
    }
  ]
}
```

Reference: [Playwright Inspector](https://playwright.dev/docs/debug#playwright-inspector)

### 8.4 Use Trace Viewer for Failed Tests

**Impact: LOW-MEDIUM (10× faster debugging with step-by-step replay)**

Playwright's Trace Viewer shows a step-by-step replay of test execution including screenshots, DOM snapshots, network requests, and console logs. Essential for debugging CI failures.

**Incorrect (no trace capture configured):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // No trace configuration
    // When tests fail in CI, you have no visibility into what happened
  },
});

// Test fails in CI - you only see error message
// No way to see page state, network requests, or console logs
```

**Correct (trace on failure):**

```typescript
// playwright.config.ts
export default defineConfig({
  use: {
    // Capture trace only when test fails or retries
    trace: 'on-first-retry',

    // Alternative options:
    // trace: 'on' - Always capture (large files)
    // trace: 'retain-on-failure' - Keep only for failures
    // trace: 'off' - Never capture
  },
});
```

**View traces locally:**

```bash
# After test failure, open trace
npx playwright show-trace test-results/test-name/trace.zip

# Or view in browser
npx playwright show-trace --browser

# Opens interactive viewer with:
# - Timeline of actions
# - Screenshots at each step
# - Network requests
# - Console logs
# - DOM snapshots
```

**Download traces from CI:**

```yaml
# .github/workflows/test.yml
- name: Run tests
  run: npx playwright test

- name: Upload trace artifacts
  uses: actions/upload-artifact@v4
  if: failure() # Only upload on failure
  with:
    name: playwright-traces
    path: test-results/
    retention-days: 7
```

Reference: [Playwright Trace Viewer](https://playwright.dev/docs/trace-viewer)

---

## References

1. [https://playwright.dev](https://playwright.dev)
2. [https://playwright.dev/docs/best-practices](https://playwright.dev/docs/best-practices)
3. [https://nextjs.org/docs/pages/guides/testing/playwright](https://nextjs.org/docs/pages/guides/testing/playwright)
4. [https://www.browserstack.com/guide/playwright-best-practices](https://www.browserstack.com/guide/playwright-best-practices)
5. [https://betterstack.com/community/guides/testing/avoid-flaky-playwright-tests/](https://betterstack.com/community/guides/testing/avoid-flaky-playwright-tests/)

---

## Source Files

This document was compiled from individual reference files. For detailed editing or extension:

| File | Description |
|------|-------------|
| [references/_sections.md](references/_sections.md) | Category definitions and impact ordering |
| [assets/templates/_template.md](assets/templates/_template.md) | Template for creating new rules |
| [SKILL.md](SKILL.md) | Quick reference entry point |
| [metadata.json](metadata.json) | Version and reference URLs |