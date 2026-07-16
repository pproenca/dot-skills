---
title: Declare convenience struct initializers in an extension to keep the memberwise init
tags: api, structs, initializers, memberwise
---

## Declare convenience struct initializers in an extension to keep the memberwise init

The wrong default when a struct needs a derived initializer (build `age` from `birthYear`, parse from a raw payload) is declaring that `init` inside the struct's main body — which silently suppresses the compiler-synthesized memberwise initializer, breaking every existing `Person(name:age:)` call site and forcing the full init to be hand-written and hand-maintained as properties change. The identical `init` declared in an extension adds the convenience form while the compiler keeps synthesizing the memberwise one for free.

**Evidence of violation:** a `struct` whose main declaration body contains an `init` that does not simply assign every stored property from same-named parameters — a convenience or derived init — with no invariant-enforcing purpose visible in its body. PASS: convenience inits live in an `extension` and the struct body declares none, or the body's only init is the full memberwise shape restated for access-control reasons. N/A: the body init deliberately validates or normalizes (failable `init?`, `guard`/`precondition` clauses, clamping) — suppressing unchecked memberwise construction is then the point.

**Incorrect (the derived init in the struct body kills the memberwise initializer):**

```swift
import Foundation

struct Person {
    var name: String
    var age: Int

    init(name: String, birthYear: Int) {
        let currentYear = Calendar.current
            .component(.year, from: Date())
        self.name = name
        self.age = currentYear - birthYear
    }
}

let person2 = Person(name: "Bob", birthYear: 1990)
// Person(name: "Charlie", age: 25) no longer compiles —
// the memberwise initializer was suppressed
```

**Correct (the extension adds the convenience form and keeps the memberwise init):**

```swift
import Foundation

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

let person2 = Person(name: "Bob", birthYear: 1990)
let person3 = Person(name: "Charlie", age: 25)
```
