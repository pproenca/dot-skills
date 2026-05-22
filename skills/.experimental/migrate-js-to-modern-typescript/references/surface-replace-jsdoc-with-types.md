---
title: Replace JSDoc Type Tags with Real Annotations
impact: MEDIUM-HIGH
impactDescription: eliminates type drift between JSDoc and code
tags: surface, jsdoc, annotations, cleanup
---

## Replace JSDoc Type Tags with Real Annotations

Once a file is `.ts`, JSDoc type tags like `@param {string}` duplicate the real signature and `tsc` ignores them entirely — so they drift the moment the signature changes, leaving two contradicting sources of truth. Move the type into the annotation and keep JSDoc for prose only: descriptions, `@example`, `@deprecated`.

**Incorrect (JSDoc types in a .ts file — silently drift from the code):**

```typescript
/**
 * @param {string} sku
 * @param {number} qty
 * @returns {number}
 */
function lineTotal(sku: string, qty: number): number {
  // tsc ignores the JSDoc types; if qty later becomes a string the JSDoc
  // still claims number and no one notices.
  return priceOf(sku) * qty
}
```

**Correct (annotations are the single source of truth):**

```typescript
/** Total cost in cents for a quantity of one SKU. */
function lineTotal(sku: string, qty: number): number {
  return priceOf(sku) * qty
}
```

Reference: [Migrating from JavaScript](https://www.typescriptlang.org/docs/handbook/migrating-from-javascript.html)
