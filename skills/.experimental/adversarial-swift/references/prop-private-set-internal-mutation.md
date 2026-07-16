---
title: Guard internally mutated state with private(set)
tags: prop, access-control, encapsulation, invariants
---

## Guard internally mutated state with private(set)

The wrong default is exposing a stored `var` as fully read-write even though the type only ever mutates it through methods that enforce preconditions. Any external caller is then free to assign past the validation — a balance changed without a deposit check, a counter reset behind the state machine's back — and the compiler says nothing. `private(set)` keeps the public read surface while turning every unauthorized write into a compile error.

**Evidence of violation:** a non-private stored `var` whose every mutation in the artifact occurs inside its own type's methods, where those methods enforce visible preconditions (guards, range checks, conditional mutation), yet the declaration lacks `private(set)` (or `fileprivate(set)`/`internal(set)` at wider scopes). Reviewers verify by enumerating the property's write sites. PASS: internally guarded properties carry a setter access modifier stricter than their getter. N/A: the type is a memberwise-initialized plain-data struct with no invariant-enforcing methods, or the property is settable API by design (no method of the type guards the invariant an external write could break). An external write that bypasses checks the type's own methods enforce is the violation made manifest, not evidence of settable-API intent — fail closed.

**Incorrect (balance is publicly writable — deposit and withdraw checks are bypassable):**

```swift
class Account {
    var balance: Double = 0.0

    func deposit(amount: Double) {
        if amount > 0 {
            balance += amount
        }
    }

    func withdraw(amount: Double) -> Bool {
        if amount <= balance {
            balance -= amount
            return true
        }
        return false
    }
}

let account = Account()
account.deposit(amount: 100)

// Compiles — the validation in deposit/withdraw never ran
account.balance = -50
```

**Correct (reads stay public, writes go through the guarded methods):**

```swift
class Account {
    private(set) var balance: Double = 0.0

    func deposit(amount: Double) {
        if amount > 0 {
            balance += amount
        }
    }

    func withdraw(amount: Double) -> Bool {
        if amount <= balance {
            balance -= amount
            return true
        }
        return false
    }
}

let account = Account()
account.deposit(amount: 100)

// Prints `100.0`
print(account.balance)

// account.balance = 50
// ❌ Cannot assign to property: 'balance' setter is inaccessible
```
