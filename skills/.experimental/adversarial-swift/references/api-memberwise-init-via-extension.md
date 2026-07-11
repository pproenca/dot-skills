---
title: Declare custom struct initializers in an extension to keep the memberwise init
tags: api, structs, initializers, memberwise
---

## Declare custom struct initializers in an extension to keep the memberwise init

Adding a custom initializer inside a struct's main definition suppresses the free memberwise initializer, and the wrong default is then hand-writing a memberwise-equivalent init to get it back. That re-implementation is pure ceremony that silently goes stale when a property is added — the compiler-provided one updates itself. Declaring the custom initializer in an extension preserves both: extensions add initializers without suppressing the default provision.

**Evidence of violation:** a struct whose main body contains BOTH a custom initializer AND a hand-written initializer that merely assigns each stored property from same-named parameters (a re-implementation of the memberwise init). PASS when the custom initializer lives in an extension and the memberwise init is used untouched. N/A when the struct intentionally exposes only the custom initializer — no memberwise re-implementation present in the main body.

**Incorrect (the hand-written memberwise init is ceremony that goes stale):**

```swift
struct Person {
    var name: String
    var age: Int

    init(name: String, age: Int) {
        self.name = name
        self.age = age
    }

    init(name: String, birthYear: Int) {
        let currentYear = Calendar.current
            .component(.year, from: Date())
        self.init(name: name, age: currentYear - birthYear)
    }
}
```

**Correct (both initializers work, the memberwise one stays compiler-maintained):**

```swift
struct Person {
    var name: String
    var age: Int
}

extension Person {
    init(name: String, birthYear: Int) {
        let currentYear = Calendar.current
            .component(.year, from: Date())
        self.init(name: name, age: currentYear - birthYear)
    }
}
```

Reference: expert Swift reference (2025), “Preserve memberwise initializer when adding custom inits to structs”
