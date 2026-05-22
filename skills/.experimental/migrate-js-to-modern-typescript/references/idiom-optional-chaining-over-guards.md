---
title: Replace Manual Existence Guards with Optional Chaining
impact: LOW-MEDIUM
impactDescription: reduces nullable-chain boilerplate
tags: idiom, optional-chaining, nullish-coalescing, narrowing
---

## Replace Manual Existence Guards with Optional Chaining

JavaScript defensive chains like `a && a.b && a.b.c` are verbose and widen the result type to include every falsy intermediate operand (`"" | 0 | undefined`), so the value you get back is messier than the one you wanted. Optional chaining (`?.`) short-circuits to `undefined` cleanly, and nullish coalescing (`??`) supplies a default only for `null`/`undefined`, expressing intent the compiler narrows precisely.

**Incorrect (boolean-and chain widens the result type):**

```typescript
// city's type includes "" and any falsy intermediate, not just string.
const city = user && user.address && user.address.city
```

**Correct (optional chaining narrows precisely):**

```typescript
const city = user?.address?.city ?? "Unknown" // string, no stray falsy values
```

Reference: [TypeScript 3.7: Optional Chaining](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-3-7.html#optional-chaining)
