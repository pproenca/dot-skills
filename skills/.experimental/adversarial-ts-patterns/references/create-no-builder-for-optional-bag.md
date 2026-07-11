---
title: No mutable Builder classes for objects with only optional fields
tags: create, builder, partial, gof
---

## No mutable Builder classes for objects with only optional fields

The wrong default is a `withX()`/`setX()`/`build()` Builder class for a configuration object whose fields are independent and optional. The GoF Builder earns its ceremony when construction has ordering constraints or cross-field invariants; when the product is an option bag, TypeScript already has the construction syntax — an object literal checked against the type, with defaults supplied by spread. The class version adds a mutable intermediate, a second type to maintain, and no compile-time guarantee the literal does not give.

**Evidence of violation:** a class whose methods are chainable setters returning `this` plus a `build()`/`create()` terminal, where the produced type has no cross-field invariant that `build()` enforces (nothing throws, no field is required-if-another-is-set) — i.e. deleting the builder and writing the literal loses nothing. The carve-out is a type-state builder whose generic parameters accumulate proof that required steps happened (the compiler rejects `build()` until they have) — that is a capability literals lack.

**Incorrect (chainable setters over an option bag):**

```ts
class RetryPolicyBuilder {
  private attempts = 3
  private backoffMs = 200
  withAttempts(n: number) { this.attempts = n; return this }
  withBackoff(ms: number) { this.backoffMs = ms; return this }
  build(): RetryPolicy { return { attempts: this.attempts, backoffMs: this.backoffMs } }
}
const policy = new RetryPolicyBuilder().withAttempts(5).build()
```

**Correct (literal plus defaults — same guarantees, no machinery):**

```ts
const defaultRetryPolicy: RetryPolicy = { attempts: 3, backoffMs: 200 }

function makeRetryPolicy(overrides: Partial<RetryPolicy> = {}): RetryPolicy {
  return { ...defaultRetryPolicy, ...overrides }
}
const policy = makeRetryPolicy({ attempts: 5 })
```

Reference: [TypeScript Handbook — Utility Types (Partial)](https://www.typescriptlang.org/docs/handbook/utility-types.html#partialtype)
