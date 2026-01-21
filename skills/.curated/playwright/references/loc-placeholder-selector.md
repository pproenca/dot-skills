---
title: Use getByPlaceholder Sparingly
impact: MEDIUM
impactDescription: fallback when labels unavailable
tags: loc, getByPlaceholder, forms, accessibility, inputs
---

## Use getByPlaceholder Sparingly

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
