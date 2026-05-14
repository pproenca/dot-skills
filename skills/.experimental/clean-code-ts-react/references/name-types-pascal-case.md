---
title: Types and Interfaces Are PascalCase
impact: CRITICAL
impactDescription: prevents type-vs-value confusion at every read
tags: name, type, interface, pascal-case
---

## Types and Interfaces Are PascalCase

TypeScript has two namespaces — values and types — that share identifier syntax. PascalCase for types and camelCase for values makes the distinction visible even without an IDE: `User` is a concept, `user` is an instance of it. Mixing the conventions (`type user = ...`, `interface checkoutResult = ...`) collides with variable names and forces the reader to scan for context.

**Incorrect (type names in camelCase — collide with values, lose the "concept" signal):**

```ts
// `user` as both a type and a value name? Reader has to disambiguate per line.
type user = {
  id: string;
  email: string;
};

interface checkoutResult {
  orderId: string;
  total: number;
}

type status = 'idle' | 'loading' | 'success' | 'error';

function placeOrder(user: user): checkoutResult {
  return { orderId: crypto.randomUUID(), total: 0 };
}
```

**Correct (PascalCase types — instantly distinguishable from values):**

```ts
// Type names read as nouns/concepts; value names stay camelCase.
type User = {
  id: string;
  email: string;
};

interface CheckoutResult {
  orderId: string;
  total: number;
}

type Status = 'idle' | 'loading' | 'success' | 'error';

function placeOrder(user: User): CheckoutResult {
  return { orderId: crypto.randomUUID(), total: 0 };
}
```

**When NOT to apply this pattern:**
- Generic type parameters by convention are single uppercase letters (`T`, `K`, `V`, `E`) or short PascalCase names (`TUser`, `TOrder`) — this is a sub-convention *inside* PascalCase, not an exception to it.
- Library-mandated lowercase type names (extremely rare, but some legacy `.d.ts` files declare lowercase types like `string` or `number` as built-ins). Don't rename them.
- Branded primitive aliases sometimes use ALL_CAPS to signal "this is a marker type, not a structural type" — a stylistic variant teams may adopt for `type USER_ID = string & { __brand: 'UserId' }`, though most teams stick with PascalCase (`type UserId`).

**Why this matters:** Two namespaces, one syntax — casing is the only persistent signal a reader has, and consistency turns it into reliable information.

Reference: [TypeScript Handbook: Naming Conventions](https://www.typescriptlang.org/docs/handbook/declaration-files/do-s-and-don-ts.html), [Clean Code, Chapter 2: Meaningful Names](https://www.oreilly.com/library/view/clean-code-a/9780136083238/)
