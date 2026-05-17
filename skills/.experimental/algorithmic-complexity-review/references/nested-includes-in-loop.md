---
title: Avoid `.includes()` / `.indexOf()` Inside a Loop
impact: CRITICAL
impactDescription: O(n*m) to O(n+m) — typical 50-500× speedup
tags: nested, hidden-quadratic, set, includes, indexof
---

## Avoid `.includes()` / `.indexOf()` Inside a Loop

`Array.prototype.includes`, `indexOf`, `find`, and Python's `x in list` all scan linearly — O(n) per call. Calling any of them inside a loop over another collection produces O(n*m) complexity that reads like O(n). This is the single most common hidden-quadratic pattern in production code because the call site looks innocuous: one method call per iteration, no visible nesting. The fix is to pre-build a `Set` (or `Map`) once and convert each membership test from O(n) to O(1).

**Incorrect (looks linear, runs quadratic — O(n*m)):**

```javascript
// Filter sign-ups that aren't already users
const newSignups = recentSignups.filter(s =>
  !existingUsers.includes(s.email)  // O(existingUsers) per signup
);
// 1,000 signups × 50,000 existing users = 50,000,000 comparisons
```

**Correct (set membership — O(n+m)):**

```javascript
const known = new Set(existingUsers);                  // O(m) once
const newSignups = recentSignups.filter(s =>
  !known.has(s.email)                                  // O(1) per signup
);
// 1,000 + 50,000 = 51,000 operations total
```

**When NOT to use this pattern:**
- When `existingUsers` is genuinely small (≲ 50) and the inner code is hot enough that hashing the key costs more than scanning — measure first.
- When elements are not hashable (mutable objects without stable identity); use a `WeakSet` for object identity or extract a stable key.

Reference: [MDN — `Set.prototype.has` runs in average O(1)](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Set#description)
