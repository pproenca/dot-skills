---
title: Replace non-null assertions with narrowing, or justify them in place
tags: types, non-null-assertion, narrowing, undefined
---

## Replace non-null assertions with narrowing, or justify them in place

The wrong default after enabling `noUncheckedIndexedAccess` is sprinkling postfix `!` to make the new errors go away — `users[0]!.name`, `map.get(key)!` — which reinstates exactly the undefined-crash the flag exists to catch. Narrow with `if`, `?.`, or `??` instead. A `!` is legitimate where an invariant genuinely guarantees presence (a `Map` get straight after set); that invariant goes in an adjacent comment so a reviewer can check it rather than trust it.

**Evidence of violation:** a postfix `!` applied to any expression typed `T | undefined` — an index access, a property access on an index-signature type (`process.env.X!` counts), `Map.get`, a `find` result, or optional-chain output — with no adjacent comment stating the invariant that guarantees the value exists.

**Incorrect (asserts away the exact case the code will hit on an empty list):**

```ts
const newestOrder = orders.sort(byDateDesc)[0]!
notify(newestOrder.customerEmail)
```

**Correct (the empty case is handled, not asserted away):**

```ts
const newestOrder = orders.sort(byDateDesc)[0]
if (!newestOrder) return
notify(newestOrder.customerEmail)
```

Reference: [typescript-eslint — no-non-null-assertion](https://typescript-eslint.io/rules/no-non-null-assertion/)
