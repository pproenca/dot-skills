---
title: Always Specify Template Parameters
impact: HIGH
impactDescription: improves type inference and prevents any-type degradation
tags: type, jsdoc, generics, templates
---

## Always Specify Template Parameters

Always provide explicit template parameters for generic types. Omitting them degrades to `unknown` or `any`, losing type safety benefits.

**Incorrect (missing template parameters):**

```javascript
/**
 * @param {Array} items - What type of items?
 * @param {Map} cache - Map of what to what?
 * @param {Promise} result - Promise of what?
 */
export function processItems(items, cache, result) {
  items.forEach(item => {
    cache.set(item.id, item);  // No type checking on item
  });
  return result;
}
```

**Correct (explicit template parameters):**

```javascript
/**
 * Processes product items and caches them by ID.
 * @param {!Array<!Product>} items The products to process.
 * @param {!Map<string, !Product>} cache The product cache keyed by ID.
 * @param {!Promise<!ProcessingResult>} result The async processing result.
 * @return {!Promise<!ProcessingResult>} The completed result.
 */
export function processItems(items, cache, result) {
  items.forEach(item => {
    cache.set(item.id, item);  // Type-safe: item is Product
  });
  return result;
}
```

**Common generic types requiring parameters:**
- `Array<T>` or `!Array<!T>`
- `Map<K, V>` or `!Map<string, !Value>`
- `Set<T>` or `!Set<!Item>`
- `Promise<T>` or `!Promise<!Result>`
- `Object<K, V>` for dict-style objects

Reference: [Google JavaScript Style Guide - Template parameter types](https://google.github.io/styleguide/jsguide.html#jsdoc-type-annotations)
