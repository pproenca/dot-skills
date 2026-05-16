---
title: Collapse Parallel Types That Share a Shape
impact: HIGH
impactDescription: eliminates three near-identical types and their mappers (~100 lines)
tags: dup, types, modelling, shape
---

## Collapse Parallel Types That Share a Shape

When `User`, `Customer`, and `Contact` all carry `{id, name, email, phone}` and the difference is only "where in the system they live," you have one shape with three labels, not three things. The duplication is invisible to linters because the *names* are different, but every consumer ends up writing the same logic three times and every change happens in triplicate. Either unify them, or — when they're genuinely distinct — make the distinction the *only* thing that differs.

**Incorrect (three types that pretend to be different):**

```typescript
type User     = { id: string; name: string; email: string; phone: string; createdAt: Date };
type Customer = { id: string; name: string; email: string; phone: string; createdAt: Date };
type Contact  = { id: string; name: string; email: string; phone: string; createdAt: Date };

function userToCustomer(u: User): Customer {
  return { id: u.id, name: u.name, email: u.email, phone: u.phone, createdAt: u.createdAt };
}
function customerToContact(c: Customer): Contact {
  return { id: c.id, name: c.name, email: c.email, phone: c.phone, createdAt: c.createdAt };
}
// Three identity functions. Three places to keep in sync. Zero meaningful distinctions.
```

**Correct (option A — one type, no distinction to preserve):**

```typescript
type Person = { id: string; name: string; email: string; phone: string; createdAt: Date };
// Used everywhere User/Customer/Contact used to be. Mappers gone.
```

**Correct (option B — the distinction is real; make it the only difference):**

```typescript
type PersonBase = { id: string; name: string; email: string; phone: string; createdAt: Date };

type User     = PersonBase & { kind: 'user';     lastLoginAt: Date };
type Customer = PersonBase & { kind: 'customer'; lifetimeValue: number };
type Contact  = PersonBase & { kind: 'contact';  source: string };
// Now the types document what's actually different.
// Logic that doesn't care about the difference can take `PersonBase`.
// Logic that does care discriminates on `kind`.
```

**Symptoms of parallel-types duplication:**

- Two or more types with identical fields and no behavioural difference at use sites.
- A folder of "mapper" or "DTO converter" functions that are essentially `x => x`.
- Tests that mostly verify the mappers preserve fields.
- The fields are renamed in some types (`emailAddress` vs `email`) but mean the same thing — that's the same problem one indirection deeper.

**When NOT to use this pattern:**

- The types come from distinct external systems with their own naming conventions you don't control (a DB schema, a SOAP API). Keep them separate at the boundary, but map to one internal type *once* — not at every consumer.
- The types share fields *today* but are expected to diverge along well-known axes. Premature unification can hurt; lock them in only when both directions are stable.

Reference: [Domain Modeling Made Functional — chap. 6](https://pragprog.com/titles/swdddf/domain-modeling-made-functional/) (Scott Wlaschin)
