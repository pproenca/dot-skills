---
title: Index Lookups Once Instead of `.find()` per Iteration
impact: CRITICAL
impactDescription: O(n*m) to O(n+m) — application-side join speedup of 50-1000×
tags: nested, lookup, map, join, pre-index
---

## Index Lookups Once Instead of `.find()` per Iteration

Joining two collections in application code — "for each order, find its user" — naturally invites `.find()` in a `.map()`. Each `.find()` is O(users), making the whole join O(orders × users). Building a `Map` keyed by the join field once is O(users); subsequent lookups are O(1). The complexity flips from quadratic to linear, and the diff is two lines.

**Incorrect (application-side join via `.find()` — O(orders × users)):**

```javascript
const enriched = orders.map(o => ({
  ...o,
  user: users.find(u => u.id === o.userId),  // scans users each call
}));
// 5,000 orders × 20,000 users = 100,000,000 comparisons
```

**Correct (build index once — O(orders + users)):**

```javascript
const userById = new Map(users.map(u => [u.id, u]));   // O(users)
const enriched = orders.map(o => ({
  ...o,
  user: userById.get(o.userId),                        // O(1)
}));
// 5,000 + 20,000 = 25,000 operations
```

**Alternative (database-side join):**

If both collections originate from the same data source, push the join down to SQL or to your ORM's eager-loading mechanism — see [`io-missing-eager-load`](io-missing-eager-load.md). Application-side joins are appropriate when the two sources are different (e.g., DB rows + external API responses).

Reference: [MDN — `Map.prototype.get` runs in sublinear average time](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Map)
