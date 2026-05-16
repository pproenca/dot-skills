---
title: Mark Data Readonly Until Mutation Is Actually Needed
impact: LOW-MEDIUM
impactDescription: eliminates defensive copies and prevents accidental mutation bugs
tags: types, readonly, immutability, mutation
---

## Mark Data Readonly Until Mutation Is Actually Needed

When function parameters and class fields are mutable by default, callers can't be sure their inputs survive the call unchanged. The compensation is defensive copying — `[...items]`, `{...obj}`, `cloneDeep` — at every call site, "just in case." Marking the input `readonly` lets the type system carry the guarantee: the function promises not to mutate, callers don't copy, code shrinks. Mutability is opt-in, not the default.

**Incorrect (mutable types invite defensive copies):**

```typescript
function sortByPrice(items: CartItem[]): CartItem[] {
  return items.sort((a, b) => a.price - b.price);
  // .sort() mutates. The caller's array is silently reordered.
}

// At every call site, the defensive copy:
const sorted = sortByPrice([...cart.items]);
// Or worse — the caller doesn't know and the bug appears when items render in odd order.
```

**Correct (readonly says "I won't change this"; the function makes a copy if it needs to):**

```typescript
function sortByPrice(items: readonly CartItem[]): CartItem[] {
  return [...items].sort((a, b) => a.price - b.price);
  // The function takes the cost of the copy *if it needs one*.
  // The signature documents the no-mutate guarantee.
}

// Call site:
const sorted = sortByPrice(cart.items);
// No defensive copy. The contract is enforced by the type.
```

**Same idea for records and class fields:**

```typescript
// Incorrect:
type Config = { apiUrl: string; retries: number };
function makeClient(config: Config): Client {
  config.retries = config.retries ?? 3;                    // mutates caller's object!
  // ... use config
}

// Correct:
type Config = Readonly<{ apiUrl: string; retries: number }>;
function makeClient(config: Config): Client {
  const retries = config.retries ?? 3;                     // local; doesn't mutate
  // ... use retries
}
```

**Use the right tool:**

- `readonly T[]` / `ReadonlyArray<T>` — read-only array type. Compile-time only; doesn't prevent mutation through `T[]` aliases.
- `Readonly<T>` — read-only object (shallow). Use `DeepReadonly<T>` from utility-types for deep.
- `as const` — for literal data tables, freezes the entire structure into a deeply-readonly literal.
- `Object.freeze` — runtime enforcement, useful for shared configuration.
- Immutable libraries (`immer`, `immutable-js`) — for cases where the discipline needs runtime help.

**Common opportunities:**

- Function parameters that the function should not need to mutate — almost all of them.
- Configuration objects loaded once at startup.
- Snapshots of state passed to renderers, formatters, validators.
- Constants and lookup tables — `as const` documents intent and improves type narrowing.

**Symptoms:**

- Defensive `[...arr]` or `{...obj}` at function call sites.
- Bug pattern: "after calling X, the input changed." A function should not surprise its caller.
- `Object.freeze` calls sprinkled around as runtime workarounds for an immutability story the types don't carry.

**When NOT to use this pattern:**

- Performance-critical code where the copy cost is measurable — keep mutation, but document it heavily and contain it.
- A function whose explicit job is to mutate the input (a normaliser, an in-place sorter) — name it so (`sortInPlace`, `normaliseMut`) and don't mark the parameter readonly.
- A reducer or builder pattern where in-place mutation is the contract (`immer`'s `draft` parameter, an in-place query builder).

Reference: [TypeScript Handbook — readonly](https://www.typescriptlang.org/docs/handbook/2/objects.html#readonly-properties); [Effective TypeScript — Prefer Readonly](https://effectivetypescript.com/)
