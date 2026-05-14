---
title: Choose Throw vs Result Deliberately
impact: HIGH
impactDescription: forces callers to handle predictable failures at the type level
tags: err, result-type, exceptions, discriminated-union
---

## Choose Throw vs Result Deliberately

Throwing is for truly exceptional conditions — the network died, the DB connection dropped, an invariant was violated. Predictable failures — "user not found", "coupon expired", "balance too low" — are part of the domain's happy path and should be returned as a `Result<T, E>` discriminated union so callers must handle them. TypeScript doesn't track which exceptions can be thrown; it does track union variants.

**Incorrect (predictable failure thrown; caller forgets to wrap):**

```ts
// Caller has no type-level signal that this can fail; an everyday "user
// logged out" turns into an uncaught exception in production.
async function findUserById(id: string): Promise<User> {
  const row = await db.users.where({ id }).first();
  if (!row) throw new Error(`user ${id} not found`);
  return row;
}

// Somewhere in a route handler:
const user = await findUserById(req.params.id); // crashes on logout flow
```

**Correct (failure is a value; the type forces handling):**

```ts
type Result<T, E> =
  | { ok: true; value: T }
  | { ok: false; error: E };

async function findUserById(
  id: string,
): Promise<Result<User, 'not_found' | 'db_error'>> {
  try {
    const row = await db.users.where({ id }).first();
    if (!row) return { ok: false, error: 'not_found' };
    return { ok: true, value: row };
  } catch {
    return { ok: false, error: 'db_error' };
  }
}

// Caller can't reach .value without handling the error variant:
const result = await findUserById(req.params.id);
if (!result.ok) return res.status(404).json({ error: result.error });
const user = result.value;
```

**When NOT to apply this pattern:**
- When the framework's idiom IS throwing — React Suspense for data fetching throws the promise; that's the contract, and wrapping it in `Result` breaks the integration.
- When callers genuinely don't care about the failure mode (analytics, telemetry, background logging) — let it throw to the nearest boundary that does care.
- Public library APIs where verbose `Result` types harm ergonomics enough to hurt adoption — a single well-named exception class can be acceptable.

**Why this matters:** Types are the only documentation the compiler enforces. Encode predictable failures there.

Reference: [Clean Code, Chapter 7: Error Handling](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Matt Pocock on Result types](https://www.totaltypescript.com/)
