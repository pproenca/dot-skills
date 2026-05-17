---
title: Cache Repeated Property Lookups in Hot Loops
impact: MEDIUM
impactDescription: 2-20× speedup when property access traverses multiple objects or proxies
tags: compute, property-lookup, dom, hoisting, micro-optimization
---

## Cache Repeated Property Lookups in Hot Loops

Property lookups look free but aren't: each `obj.a.b.c` traverses three properties, and on objects with prototype chains, getters, or Proxy interceptors, every dereference can run code. The DOM is the worst offender — `element.offsetWidth` triggers layout, `element.style.color` triggers style resolution. Inside a tight loop, repeated identical accesses pile up. Cache the deep reference in a local once, then index off it. Modern JS engines (V8 inline caches) handle simple paths well, but Proxy / getter / DOM properties bypass these optimizations.

**Incorrect (DOM property thrash — layout per iteration):**

```javascript
for (let i = 0; i < items.length; i++) {           // .length read each iter
  const w = container.offsetWidth;                 // FORCES layout each iter
  items[i].style.width = (w / items.length) + 'px';
}
// 1,000 items → ~1,000 forced layouts (typically 100+ ms total)
```

**Correct (hoist + cache):**

```javascript
const n = items.length;
const w = container.offsetWidth;                   // one layout
const cellW = (w / n) + 'px';
for (let i = 0; i < n; i++) {
  items[i].style.width = cellW;
}
```

**Alternative (deeply nested object access):**

```javascript
// Avoid: repeated chain access — even with V8 inline caching, four lookups per iter
for (const row of rows) {
  if (row.user.profile.preferences.locale === 'en-US') { ... }
}

// Better: destructure once, reference the local
const target = 'en-US';
for (const row of rows) {
  const { locale } = row.user.profile.preferences;
  if (locale === target) { ... }
}
```

**When NOT to use this pattern:**
- When the property may change between iterations (loop body mutates it) — caching introduces a stale-read bug.
- For trivial scalar properties on plain objects in non-hot code — V8/JSC inline caches handle these for free.

Reference: [Google web.dev — avoiding forced synchronous layouts (FSL)](https://web.dev/articles/avoid-large-complex-layouts-and-layout-thrashing)
