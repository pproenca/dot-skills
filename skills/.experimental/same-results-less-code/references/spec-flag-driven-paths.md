---
title: Split a Function That a Boolean Flag Has Made Into Two
impact: MEDIUM
impactDescription: eliminates flag-driven branching that hides two distinct functions inside one
tags: spec, flags, parameters, refactor
---

## Split a Function That a Boolean Flag Has Made Into Two

When a function takes a boolean and the body is mostly `if (flag) { … } else { … }`, you have *two* functions wearing one name. Callers must know which mode they want and pass the right bool; readers must mentally track which half of the body is alive at each call. The "savings" of one shared signature evaporate the moment the two halves diverge — which they always do. Split into two functions with names that say what they actually do.

**Incorrect (a flag that toggles two unrelated behaviours):**

```typescript
async function fetchUsers(activeOnly: boolean): Promise<User[]> {
  if (activeOnly) {
    const rows = await db.query(`SELECT * FROM users WHERE status = 'active' AND deleted_at IS NULL`);
    return rows.map(toUser);
  } else {
    const rows = await db.query(`SELECT * FROM users WHERE deleted_at IS NULL`);
    return rows.map(toUser);
  }
}

// Call sites:
const all = await fetchUsers(false);
const active = await fetchUsers(true);
// What does `fetchUsers(true)` mean? Reader must look at the signature to recall.
```

**Correct (two functions; the names are the documentation):**

```typescript
async function fetchActiveUsers(): Promise<User[]> {
  const rows = await db.query(`SELECT * FROM users WHERE status = 'active' AND deleted_at IS NULL`);
  return rows.map(toUser);
}

async function fetchAllUsers(): Promise<User[]> {
  const rows = await db.query(`SELECT * FROM users WHERE deleted_at IS NULL`);
  return rows.map(toUser);
}

// Call sites:
const all    = await fetchAllUsers();
const active = await fetchActiveUsers();
// Each call site reads itself. The shared `.map(toUser)` is one line — not enough duplication
// to justify keeping them entangled.
```

**When the flag selects between cases that share *real* implementation, lift the shared part — using a structured filter, never a raw SQL string:**

```typescript
type UserFilter = { activeOnly: boolean };

async function fetchActiveUsers() { return fetchUsers({ activeOnly: true }); }
async function fetchAllUsers()    { return fetchUsers({ activeOnly: false }); }

async function fetchUsers(filter: UserFilter): Promise<User[]> {
  const conditions = ['deleted_at IS NULL'];
  if (filter.activeOnly) conditions.push(`status = 'active'`);
  const rows = await db.query(`SELECT * FROM users WHERE ${conditions.join(' AND ')}`);
  return rows.map(toUser);
}
// Two public functions with clear names; one private helper for the shared part.
// The helper takes a *structured* filter — no raw SQL fragments at the call boundary,
// which would be a SQL-injection footgun. The helper's body is the only place that
// translates intent into SQL.
```

**Symptoms of a function pretending to be one:**

- A boolean parameter that splits the body into two halves with little overlap.
- Documentation that describes "two behaviours" of the same function.
- Tests in two groups, one per value of the flag, asserting different things.
- Callers always pass a literal `true` or `false`, never a variable.
- A name with "Or" in it (`getUserOrCreate`, `loadDataOrCache`) — usually two operations.

**When NOT to use this pattern:**

- The "two halves" share 90% of code and differ only at one inflection point — keep one function with the flag, but consider whether the flag is a *better-named* parameter (`mode: 'strict' | 'lenient'` reads more than `strict: boolean`).
- The choice between halves is genuinely runtime-determined (the caller computes which one to ask for) — split or not, but make sure the name explains what each does.

Reference: [Refactoring — Remove Flag Argument](https://refactoring.com/catalog/removeFlagArgument.html) (Martin Fowler)
