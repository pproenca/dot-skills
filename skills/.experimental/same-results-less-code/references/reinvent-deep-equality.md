---
title: Use a Real Deep-Equality or Hash Instead of Hand-Recursing Objects
impact: CRITICAL
impactDescription: 30-100 lines of recursive comparison reduced to a single library call
tags: reinvent, equality, comparison, stdlib
---

## Use a Real Deep-Equality or Hash Instead of Hand-Recursing Objects

Hand-written deep-equality functions almost always miss at least one of: `NaN !== NaN`, sparse arrays, `Map`/`Set`/`Date`/`RegExp`, cyclic references, or property order in maps. The result is a long, recursive function whose subtle wrongness only shows up under specific input shapes. Reach for `dequal`, `lodash.isEqual`, `fast-deep-equal`, `Object.is`, or a structural hash.

**Incorrect (handcrafted deep-equal with a half-correct algorithm):**

```typescript
function deepEqual(a: unknown, b: unknown): boolean {
  if (a === b) return true;
  if (typeof a !== 'object' || typeof b !== 'object') return false;
  if (a === null || b === null) return false;
  const ka = Object.keys(a as object);
  const kb = Object.keys(b as object);
  if (ka.length !== kb.length) return false;
  for (const k of ka) {
    if (!deepEqual((a as any)[k], (b as any)[k])) return false;
  }
  return true;
  // Misses NaN, Dates (compared by ref), Maps, Sets, RegExp, cycles.
  // Every project that has this function has a bug ticket about one of those.
}
```

**Correct (lean on a library that has handled the edge cases for years):**

```typescript
import { dequal } from 'dequal';

const same = dequal(a, b);
// Handles Date, Map, Set, RegExp, NaN, typed arrays, cycles.
```

**Variants worth recognising:**

- Comparing by stable key set → `pick(obj, keys)` then `dequal`, not a custom shape-aware comparator.
- Comparing for cache invalidation → a structural hash (`object-hash`, `fast-json-stable-stringify`) beats deep comparison if you cache the hash.
- Comparing for React/Vue memoization → use the framework's `memo`/`shallowEqual`, not a custom one.

**When NOT to use this pattern:**

- You have a domain `Equatable` contract (a `Money` class with custom equality) — that's domain modelling, not reinvention. Implement `equals()` on the type and let callers use it.
- You're comparing one specific shape with one field that matters — write the explicit `a.id === b.id`. That's clarity, not reinvention.

Reference: [lodash.isEqual docs](https://lodash.com/docs#isEqual)
