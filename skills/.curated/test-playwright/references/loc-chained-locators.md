---
title: Chain Locators for Specificity
impact: HIGH
impactDescription: reduces ambiguity without brittle selectors
tags: loc, chaining, filter, specificity, locators
---

## Chain Locators for Specificity

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
