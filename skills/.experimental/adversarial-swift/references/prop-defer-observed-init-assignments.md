---
title: Route init assignments through defer when observers must fire
tags: prop, property-observers, initialization, didset
---

## Route init assignments through defer when observers must fire

Property observers deliberately do not run for assignments made directly inside `init`, and the wrong default is assigning an observed property there while relying on its `willSet`/`didSet` to perform the associated maintenance — updating a dependent property, registering with a notification system. The object then leaves `init` with the observer-maintained invariant never established, and nothing diagnoses it. Wrapping the assignment in `defer` moves it past the initialization phase, so the observers fire exactly as they do for every later write.

**Evidence of violation:** a class whose `didSet`/`willSet` visibly maintains other state (assigns another property, calls a registration or notification routine), and whose `init` assigns that property directly with none of the three exculpatory shapes — (a) the same maintenance performed inline in `init`, (b) the assignment wrapped in `defer { property = value }`, or (c) a post-init setup method performing the assignment. PASS: every init-time write to a state-maintaining observed property goes through one of those three shapes. N/A: the target's observers only log, or no observed property is assigned in any `init`.

The canonical pair below demonstrates the mechanism with observers that print; in a review target, the rule fires when the observers maintain state (the print statements stand in for that maintenance).

**Incorrect (observers never fire during init — the maintenance they perform silently skips):**

```swift
class MyClass {
    var myProperty: String {
        willSet {
            print("Will set myProperty to \(newValue)")
        }
        didSet {
            print("""
            Did set myProperty to \(myProperty), \
            previously \(oldValue)
            """)
        }
    }

    init(value: String) {
        myProperty = value
    }
}

let myObject = MyClass(value: "New value")
```

**Correct (defer runs after initialization completes, so the observers fire):**

```swift
class MyClass {
    var myProperty: String {
        willSet {
            print("Will set myProperty to \(newValue)")
        }
        didSet {
            print("""
            Did set myProperty to \(myProperty), \
            previously \(oldValue)
            """)
        }
    }

    init(value: String) {
        defer { myProperty = value }
        myProperty = "Initial value"
    }
}

let myObject = MyClass(value: "New value")
```
