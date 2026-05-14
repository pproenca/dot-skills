---
title: Use Early Returns to Flatten Error Paths
impact: HIGH
impactDescription: keeps the happy path at one indent level so readers can find it
tags: err, control-flow, guard-clauses, readability
---

## Use Early Returns to Flatten Error Paths

Nesting `if/else` to handle each error condition pushes the actual work deeper into the function and forces the reader to track every brace. Guard clauses — return or throw at the top for each invalid input — leave the body at a single indent level for the happy path, which is what readers are usually looking for.

**Incorrect (happy path buried 4 indents deep):**

```ts
function processPayment(order: Order | null): PaymentReceipt {
  if (order) {
    if (order.isValid) {
      if (order.amount > 0) {
        if (order.currency === 'USD') {
          // The actual work, four indents in.
          const receipt = chargeCard(order);
          return receipt;
        } else {
          throw new Error('unsupported currency');
        }
      } else {
        throw new Error('amount must be positive');
      }
    } else {
      throw new ValidationError('order invalid');
    }
  } else {
    throw new Error('order required');
  }
}
```

**Correct (guards first, happy path at one indent):**

```ts
function processPayment(order: Order | null): PaymentReceipt {
  if (!order) throw new Error('order required');
  if (!order.isValid) throw new ValidationError('order invalid');
  if (order.amount <= 0) throw new Error('amount must be positive');
  if (order.currency !== 'USD') throw new Error('unsupported currency');

  // Happy path at one indent — reader finds it immediately.
  const receipt = chargeCard(order);
  return receipt;
}
```

**When NOT to apply this pattern:**
- When cleanup must run for every branch — a `try { ... } finally { release() }` is cleaner than scattered early returns that each duplicate the cleanup.
- Very short functions (3-4 lines total) where nesting is already legible — flattening adds little.
- Functional pipelines that treat errors as values (`Result`, `Either`) — error handling is in the type, not control flow, so guard clauses don't apply.

**Why this matters:** The shape of indentation is the shape of the function's logic. Keep the happy path flat.

Reference: [Clean Code, Chapter 7: Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Martin Fowler on Guard Clauses](https://refactoring.com/catalog/replaceNestedConditionalWithGuardClauses.html)
