---
title: Use `satisfies` for Inferred-But-Checked Values
impact: HIGH
impactDescription: preserves literal-type precision while still verifying shape against a contract
tags: doc, types, satisfies, inference
---

## Use `satisfies` for Inferred-But-Checked Values

`as Type` is an assertion ("trust me, compiler"); `: Type` widens the value to the annotation and discards the precise inferred literals; `satisfies Type` (TS 4.9+) keeps the narrow inferred type AND checks it conforms to the contract. For configuration objects, route maps, and constant lookups, `satisfies` is almost always what you want.

**Incorrect (widening loses literals; assertion bypasses the check):**

```ts
// Option A: type annotation — ROUTES.checkout is widened to `string`,
// so we can't use it as a discriminant later.
const ROUTES: Record<string, string> = {
  home: '/',
  checkout: '/checkout',
  orders: '/orders',
};

// Option B: as-assertion — typo isn't caught because we asserted blindly.
const STATUSES = {
  pending: 'pending',
  shippped: 'shippped', // typo compiles fine
} as Record<string, string>;
```

**Correct (narrow inferred types AND shape verified):**

```ts
const ROUTES = {
  home: '/',
  checkout: '/checkout',
  orders: '/orders',
} satisfies Record<string, `/${string}`>;
// ROUTES.checkout has type '/checkout' (not string) — usable as a literal.

const STATUSES = {
  pending: 'pending',
  shippped: 'shippped', // compile error: not a valid OrderStatus
} satisfies Record<string, 'pending' | 'shipped' | 'delivered'>;
```

**When NOT to apply this pattern:**
- When you genuinely want widening — e.g., a public API constant typed as `string` because consumers legitimately compare against arbitrary strings.
- Generic constraints where `extends` is the right tool (`function get<K extends keyof T>(...)` — `satisfies` doesn't apply).
- Mutable values: `satisfies` does not make a value `readonly`; pair with `as const` if immutability is the actual goal.

**Why this matters:** Precision in types pays off at every downstream use site — autocomplete, discriminants, exhaustive switches — without sacrificing the safety check the annotation gave you.

Reference: [TypeScript 4.9 release notes: `satisfies`](https://devblogs.microsoft.com/typescript/announcing-typescript-4-9/), [Matt Pocock on `satisfies`](https://www.totaltypescript.com/)
