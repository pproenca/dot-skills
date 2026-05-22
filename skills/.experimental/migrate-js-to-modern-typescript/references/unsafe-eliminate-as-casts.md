---
title: Replace as Casts with Narrowing or Validation
impact: HIGH
impactDescription: eliminates unverified type assertions
tags: unsafe, type-assertions, narrowing
---

## Replace as Casts with Narrowing or Validation

An `as` cast is an unchecked promise to the compiler with zero runtime verification — precisely the tool a JavaScript migration over-uses to silence errors fast. The error goes away but the wrong shape still arrives at runtime and crashes later, far from the cast. Narrowing or schema validation confirms the claim, so the type you assert is actually true.

**Incorrect (cast silences the error but verifies nothing):**

```typescript
function handle(req: Request): void {
  const body = req.body as CheckoutPayload // unverified; wrong shape crashes later
  charge(body.cardToken, body.amountCents)
}
```

**Correct (validate, so the type is real at runtime):**

```typescript
function handle(req: Request): void {
  const body = CheckoutPayloadSchema.parse(req.body) // throws on a bad shape
  charge(body.cardToken, body.amountCents)
}
```

Reference: [Google TypeScript Style Guide: Type Assertions](https://google.github.io/styleguide/tsguide.html#type-assertions)
