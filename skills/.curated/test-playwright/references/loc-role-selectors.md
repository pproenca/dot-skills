---
title: Use Role-Based Selectors Over CSS
impact: CRITICAL
impactDescription: 80% reduction in selector-related flakiness
tags: loc, getByRole, accessibility, selectors, aria
---

## Use Role-Based Selectors Over CSS

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
