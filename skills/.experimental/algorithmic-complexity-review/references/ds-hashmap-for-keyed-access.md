---
title: Store Records Keyed in a Hashmap, Not as Parallel Arrays
impact: HIGH
impactDescription: O(n) per lookup to O(1) — flips entire access patterns linear
tags: ds, hashmap, indexing, dictionary, lookup
---

## Store Records Keyed in a Hashmap, Not as Parallel Arrays

If callers will retrieve records by an ID, store them in a `Map`/`dict` keyed by that ID. The mistake is keeping the result of an API call or query as a flat array and reaching for `.find` every time you need one entry — each lookup is O(n), so any code that touches the collection more than once silently scales as O(n²). The fix is a one-time O(n) reshape after the data arrives. This is the same idea as [`nested-find-in-loop`](nested-find-in-loop.md), but framed as a data-modeling decision at the boundary where the collection enters the system, not a refactor at the loop.

**Incorrect (array storage, repeated find — O(n) per access):**

```typescript
const users: User[] = await api.getUsers();

function getName(id: string) {
  return users.find(u => u.id === id)?.name;   // O(n) every call
}

// 1,000 page renders × find on 50,000 users = 50,000,000 comparisons
```

**Correct (hashmap storage — O(1) per access):**

```typescript
const userArray = await api.getUsers();
const users = new Map(userArray.map(u => [u.id, u]));   // O(n) once

function getName(id: string) {
  return users.get(id)?.name;                  // O(1)
}
```

**Alternative (when iteration order matters):**

```typescript
// JS Map preserves insertion order — supports both random access and ordered iteration
const users = new Map(userArray.map(u => [u.id, u]));
for (const user of users.values()) { ... }    // ordered iteration
users.get(id);                                  // O(1) random access
```

**When NOT to use this pattern:**
- When the collection is iterated once and never looked up again — the hashmap conversion is wasted work.
- When IDs are not stable (e.g., transient queue messages) — a hashmap of moving keys still works but offers no real advantage.

Reference: [JavaScript `Map` — ECMAScript spec mandates sublinear average access (amortized O(1))](https://tc39.es/ecma262/#sec-map-objects)
