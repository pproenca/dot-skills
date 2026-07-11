---
title: Restrict setters with private(set) on internally mutated properties
tags: api, encapsulation, private-set, invariants
---

## Restrict setters with private(set) on internally mutated properties

The wrong default is exposing a stored `var` with a fully accessible setter even though every mutation in the codebase goes through the type's own invariant-preserving methods — a balance changed only by `deposit()` and `withdraw()`, a counter changed only by `record()`. The open setter lets any caller bypass those invariants with a plain assignment; `private(set)` keeps the property readable while guaranteeing it only changes in the controlled, predictable ways the type defines.

**Evidence of violation:** an `internal` or `public` stored `var` that (a) is assigned or mutated only from within its declaring type in the reviewed code, and (b) sits alongside invariant-enforcing mutator methods on that type — the tell is a method that reads the property or another property before writing it (a guard, a bounds check, a computation), not a bare assignment — yet lacks `private(set)` or a stricter access level. PASS when the setter is restricted (`private(set)`, `fileprivate(set)`, fully `private`) or the property is a `let`. N/A when the property is intentionally mutated from outside the type in the reviewed code, or when the type is a plain data-transfer struct with no invariant-enforcing methods.

**Incorrect (any caller can bypass the deposit and withdraw invariants):**

```swift
class Account {
    var balance: Double = 0.0

    func deposit(amount: Double) {
        if amount > 0 { balance += amount }
    }

    func withdraw(amount: Double) -> Bool {
        guard amount <= balance else { return false }
        balance -= amount
        return true
    }
}
```

**Correct (balance stays readable but only changes through the mutators):**

```swift
class Account {
    private(set) var balance: Double = 0.0

    func deposit(amount: Double) {
        if amount > 0 { balance += amount }
    }

    func withdraw(amount: Double) -> Bool {
        guard amount <= balance else { return false }
        balance -= amount
        return true
    }
}
```

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Prevent unauthorized modifications of properties with private(set)”
