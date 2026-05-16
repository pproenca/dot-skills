---
title: Brand a Validated Value So You Don't Validate It Twice
impact: LOW-MEDIUM
impactDescription: eliminates re-validation of values that have already been checked
tags: types, branding, validation, nominal
---

## Brand a Validated Value So You Don't Validate It Twice

A normalised email, a checked-out money amount, a user id pulled from a session — once you've validated them, the value is *not just a string*. But the type still says `string`, so every function downstream defensively re-validates. Branded (nominal) types let the type system carry the "this has been validated" guarantee: `Email`, `Money`, `UserId` are all `string` at runtime but distinct types at compile time. The validation happens once, in the function that produces the brand.

**Incorrect (every layer re-validates because the type doesn't remember):**

```typescript
function normaliseEmail(email: string): string {
  if (!email.includes('@')) throw new Error('bad email');
  return email.trim().toLowerCase();
}

function sendWelcome(email: string): void {
  if (!email.includes('@')) throw new Error('bad email');   // we already normalised — why again?
  // ...
}

function recordSignup(email: string): void {
  if (!email.includes('@')) throw new Error('bad email');   // and again
  // ...
}
// The type `string` lost the information that this is a *validated* email.
// Every callee defends. The actual invariant — "this string is a valid email" — isn't expressed.
```

**Correct (brand the validated value; downstream functions ask for the brand):**

```typescript
type Email = string & { readonly __brand: 'Email' };

function parseEmail(raw: string): Email {
  if (!raw.includes('@')) throw new Error('bad email');
  return raw.trim().toLowerCase() as Email;
  // The cast happens once, inside the parser. The function's NAME and RETURN TYPE say "validated."
}

function sendWelcome(email: Email): void {                 // can't be called with a raw string
  // ... no re-check needed; the type carries the proof
}

function recordSignup(email: Email): void {                 // same
  // ...
}

// At call sites:
const email = parseEmail(req.body.email);                   // validation: once
sendWelcome(email);                                          // type-checked
recordSignup(email);                                         // type-checked
```

**Other useful brands:**

- `UserId`, `OrderId`, `ProductId` — prevent passing a UserId where an OrderId is expected (a real bug, not theoretical — these have caused outages at every company that has both).
- `Money` and `Currency` — distinguish "100 (USD)" from "100 (cents)" from "100 (EUR)". Brand the amount with its unit.
- `EncryptedString` vs `PlaintextString` — prevent logging plaintext or writing encrypted data to a CSV.
- `NonEmptyArray<T>`, `PositiveNumber` — invariants that don't fit literal types.

**Pattern with `parseFoo` over `validateFoo`:**

`validateFoo(x: string): boolean` doesn't change the type — callers still hold a `string`. `parseFoo(x: string): Foo` returns the brand and *makes the validation visible in the type*. Strongly prefer the latter.

**Symptoms that branding would help:**

- Multiple functions in the same module all assert the same precondition on the same parameter.
- A bug pattern of "we passed the wrong id" (UserId where OrderId expected) — type-level branding would have caught it.
- Comments like `// caller must ensure email is normalized` — that's a contract the type should enforce.
- A `Validator` class with many `isX` predicates whose return values aren't used in narrowing.

**When NOT to use this pattern:**

- The value's "validatedness" is short-lived (within a single function) — local discipline is enough; don't introduce a new type.
- The branding adds friction without a corresponding bug class — e.g. branding every internal string would be ceremony. Brand the values that confuse most often.
- The codebase doesn't have a structural-type story for the brand (Go, Java without value types) — use the language's idiomatic alternative (newtype wrapper, value class).

Reference: [Effective TypeScript — Branded types](https://effectivetypescript.com/); [Egghead — Branded types](https://egghead.io/blog/using-branded-types-in-typescript)
