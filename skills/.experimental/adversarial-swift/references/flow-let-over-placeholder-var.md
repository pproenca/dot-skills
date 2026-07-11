---
title: Declare branch-assigned constants as let instead of var with a placeholder
tags: flow, immutability, control-flow, compiler-checks
---

## Declare branch-assigned constants as let instead of var with a placeholder

The wrong default when a value depends on a condition is `var message = ""` followed by reassignment in each branch. The dummy initial value silently covers any branch the author forgot — the compiler has nothing to check — and the `var` invites later mutation of a value that was meant to be fixed. Declaring `let message: String` and assigning it per branch turns missing-branch bugs into compile errors: Swift refuses to compile if any path leaves the constant unset.

**Evidence of violation:** a `var` declaration initialized with a placeholder (empty string, `0`, empty collection) where every execution path reassigns it before any read and it is never mutated afterward — all three legs must hold. PASS: `let x: T` declared without a value and assigned in every branch, or the `var` is genuinely mutated after its conditional initialization. N/A: the initial value is a real fallback that at least one path keeps.

**Incorrect (a forgotten branch silently keeps the dummy value):**

```swift
func shippingLabel(for weight: Measurement<UnitMass>) -> String {
    var tier = ""
    if weight.value > 20 {
        tier = "Freight"
    } else if weight.value > 2 {
        tier = "Parcel"
    }
    // the light-package branch was forgotten; tier is "" and it compiles
    return "Ship via \(tier)"
}
```

**Correct (the compiler proves every path assigns exactly once):**

```swift
func shippingLabel(for weight: Measurement<UnitMass>) -> String {
    let tier: String
    if weight.value > 20 {
        tier = "Freight"
    } else if weight.value > 2 {
        tier = "Parcel"
    } else {
        tier = "Letter"
    }
    return "Ship via \(tier)"
}
```

Reference: expert Swift reference (2025), “Set a constant based on conditions”.
