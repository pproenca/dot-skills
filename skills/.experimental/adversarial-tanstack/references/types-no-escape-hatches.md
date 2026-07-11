---
title: Justify or remove type-system escape hatches
tags: types, any, ts-ignore, suppression
---

## Justify or remove type-system escape hatches

The wrong default under time pressure is silencing the compiler exactly where it flagged real risk: `as any` to force an assignment, `// @ts-ignore` above a stubborn line, an eslint-disable for a type-safety rule, or an `as unknown as X` double-cast when a single cast refuses. Each removes checking from the one place the checker objected. `@ts-ignore` is doubly bad because it keeps suppressing after the underlying error is fixed; `@ts-expect-error` self-invalidates, which is why it must carry a reason.

**Evidence of violation:** any occurrence of `as any`, `@ts-ignore`, `@ts-nocheck`, a bare `@ts-expect-error` with no description, `as unknown as` with no adjacent justifying comment, or an `eslint-disable` directive naming a type-safety rule (`no-explicit-any`, `no-unsafe-*`, `no-floating-promises`, `ban-ts-comment`) without a justifying comment.

**Incorrect (permanent, reasonless suppression):**

```ts
// @ts-ignore
const total = cart.items.reduce((sum, item) => sum + item.price, 0)
```

**Correct (self-invalidating, with the reason on record):**

```ts
// @ts-expect-error cart.items is CartItem[] upstream but the generated client types it as unknown[] until openapi regen (TICKET-482)
const total = cart.items.reduce((sum, item) => sum + item.price, 0)
```

Reference: [typescript-eslint — ban-ts-comment](https://typescript-eslint.io/rules/ban-ts-comment/), [typescript-eslint — Avoiding anys](https://typescript-eslint.io/blog/avoiding-anys/)
