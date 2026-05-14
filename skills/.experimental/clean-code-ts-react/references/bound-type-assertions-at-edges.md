---
title: Type Assertions Belong Only at Boundaries
impact: MEDIUM-HIGH
impactDescription: confines unchecked trust to one verified entry point
tags: bound, types, assertions, parsing
---

## Type Assertions Belong Only at Boundaries

`as T` tells the compiler "trust me" and disables the very check you wanted. Sprinkled through business logic, assertions silently propagate untyped values until they explode at runtime far from the source. Confined to a single boundary — where a runtime check verifies what the compiler can't — they acknowledge exactly where trust enters the system, and the downstream code stays honestly typed.

**Incorrect (assertions scattered through the codebase):**

```ts
// Each `as` is a lie the compiler accepts. One bad payload, runtime crash anywhere.
async function loadOrder(json: unknown): Promise<number> {
  const order = json as Order;
  const id    = order.userId as UserId;
  const total = order.total  as number;
  return total * 1.1;
}
```

**Correct (parse once at the edge; downstream stays honest):**

```ts
// Runtime check at the boundary; assertion happens inside the parser.
// Downstream code uses Order without any `as`.
import { z } from 'zod';

const OrderSchema = z.object({
  userId: z.string().regex(/^usr_/),
  total:  z.number().nonnegative(),
});

async function loadOrder(json: unknown): Promise<number> {
  const result = OrderSchema.safeParse(json);
  if (!result.success) throw new BoundaryError('invalid order payload');
  const order = result.data; // honestly typed Order
  return order.total * 1.1;
}
```

**When NOT to apply this pattern:**
- Types that can't be checked at runtime — DOM event types from listeners (`e.target as HTMLInputElement`) are sometimes the only available expression.
- Bridging a slightly-too-strict typed library to your domain type with a documented one-line assertion — better than refactoring the world.
- Test fixtures where producing a mock shape is the entire point — full parsing in tests is ceremony.

**Why this matters:** Assertions at boundaries (verified) plus honest types everywhere else is the same trust-once-then-rely shape as DTO/domain translation and branded-type factories.

Reference: [Clean Code, Chapter 8: Boundaries](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Parse, Don't Validate — Alexis King](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/)
