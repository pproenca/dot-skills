---
title: Use Page Object Model for Complex Pages
impact: CRITICAL
impactDescription: reduces selector maintenance by 70%
tags: arch, pom, page-object, abstraction, maintenance
---

## Use Page Object Model for Complex Pages

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
