---
title: Pick null OR undefined Per Domain — Not Both
impact: HIGH
impactDescription: removes the mental tax of remembering which absence sentinel each function uses
tags: err, null, undefined, conventions
---

## Pick null OR undefined Per Domain — Not Both

TypeScript distinguishes `null` from `undefined`, but most codebases use them inconsistently and force callers to check for both. Pick one convention for your domain and stick to it — typically `undefined` for "absent / not requested" (matches optional fields, `?.` chains, default args), reserving `null` for explicit DB-style "intentionally cleared." Document the choice in the team conventions.

**Incorrect (mixed sentinels across the same module):**

```ts
// Caller has to remember which function uses which sentinel.
function findUserById(id: string): User | null {
  return db.users.findOne({ id }) ?? null;
}

function findEmailForUser(user: User): string | undefined {
  return user.contacts.find((c) => c.type === 'email')?.value;
}

// Result: caller writes inconsistent checks.
const user = findUserById(id);
if (user === null) return; // null check
const email = findEmailForUser(user);
if (email === undefined) return; // undefined check
// Refactoring either function risks getting the sentinel wrong.
```

**Correct (one convention — `undefined` for absence — applied everywhere):**

```ts
// Team convention: use `undefined` for "absent". `null` only when bridging
// to an external system that distinguishes (e.g., a JSON column).
function findUserById(id: string): User | undefined {
  return db.users.findOne({ id }) ?? undefined;
}

function findEmailForUser(user: User): string | undefined {
  return user.contacts.find((c) => c.type === 'email')?.value;
}

// Caller uses the same idiom everywhere — and `??` / `?.` work naturally.
const user = findUserById(id);
if (!user) return;
const email = findEmailForUser(user);
if (!email) return;
```

**When NOT to apply this pattern:**
- External-API boundaries that distinguish the two — JSON treats `null` as explicit absence and a missing field as `undefined`; preserving the distinction at the boundary matters.
- ORM / database layers where `null` is the SQL `NULL` semantic and round-trips through the schema — converting at the boundary is fine, but don't pretend they're the same inside the DB layer.
- Large legacy codebases — converge gradually as files are touched; a sweeping migration is rarely worth the diff.

**Why this matters:** Two sentinels for the same concept double the surface area for bugs. Pick one, codify it, and let `??` / `?.` do the rest.

Reference: [Clean Code, Chapter 7: Error Handling — Don't Return Null](https://www.oreilly.com/library/view/clean-code-a/9780136083238/), [Matt Pocock on null vs undefined](https://www.totaltypescript.com/)
