---
title: Use dictionary subscript defaults instead of check-then-set upserts
tags: flow, dictionaries, subscripts, force-unwrap
---

## Use dictionary subscript defaults instead of check-then-set upserts

The wrong default for "update or insert" on a dictionary is the check-then-set dance — `if dict[key] == nil { dict[key] = [] }` followed by `dict[key]!.append(item)`, or `dict[key] = (dict[key] ?? 0) + 1`. The pattern needs a force-unwrap or a redundant lookup, and the seeding step drifts from the update step as code evolves. Swift's `subscript(_:default:)` expresses the whole operation in one mutating access with no unwrap and no double lookup.

**Evidence of violation:** a nil-check-then-insert sequence, a `?? seed`-then-reassign expression, or a force-unwrap-after-seeding on a dictionary value, where `dict[key, default:]` expresses the same read-modify-write. PASS: `dict[key, default: 0] += 1`, `dict[key, default: []].append(item)`, and equivalents. N/A: the missing-key case takes a genuinely different branch — different logic, not just seeding a default before the same update.

**Incorrect (seed-then-force-unwrap, two lookups and a trap waiting for a refactor):**

```swift
struct Order { let customerID: String }
let importedOrders: [Order] = []

var ordersByCustomer: [String: [Order]] = [:]

for order in importedOrders {
    if ordersByCustomer[order.customerID] == nil {
        ordersByCustomer[order.customerID] = []
    }
    ordersByCustomer[order.customerID]!.append(order)
}
```

**Correct (one mutating access, no unwrap, seed and update cannot drift):**

```swift
struct Order { let customerID: String }
let importedOrders: [Order] = []

var ordersByCustomer: [String: [Order]] = [:]

for order in importedOrders {
    ordersByCustomer[order.customerID, default: []].append(order)
}
```

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Specify default values in dictionary subscripts”.
