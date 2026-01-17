---
title: Avoid XPath Selectors
impact: HIGH
impactDescription: XPath is 3-5× slower and more brittle
tags: loc, xpath, performance, selectors, anti-pattern
---

## Avoid XPath Selectors

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
