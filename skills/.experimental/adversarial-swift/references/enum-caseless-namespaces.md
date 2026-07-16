---
title: Use caseless enums for namespaces instead of instantiable structs
tags: enum, namespaces, static-members, api-surface
---

## Use caseless enums for namespaces instead of instantiable structs

The wrong default when grouping constants or utility functions is `struct MathConstants { static let … }` — a type whose only role is namespacing, yet `MathConstants()` compiles and produces a meaningless empty value. A caseless enum has no values by construction, so the compiler itself enforces the namespace-only intent and readers see the type's role at the declaration.

**Evidence of violation:** a `struct` or `class` in the reviewed code containing only static members — no instance stored properties, no instance methods, no protocol conformances requiring instantiation — with no `private init()`, used purely as a member container. PASS: the container is a caseless `enum`, or the type has instance members that justify instantiation. N/A: the type conforms to any protocol, has any instance member, or declares a `private init` that already blocks instantiation — the enforcement goal is then met even though the enum form states it more directly.

**Incorrect (the namespace can be instantiated, and the instance means nothing):**

```swift
struct MathConstants {
    static let pi = 3.14159
    static let e = 2.71828
}

struct UtilityFunctions {
    static func computeArea(radius: Double) -> Double {
        return MathConstants.pi * radius * radius
    }
}

// Compiles cleanly — a value with no purpose
let bogus = MathConstants()

let area = UtilityFunctions.computeArea(radius: 5)
```

**Correct (a caseless enum cannot be instantiated, so the compiler enforces the intent):**

```swift
enum MathConstants {
    static let pi = 3.14159
    static let e = 2.71828
}

enum UtilityFunctions {
    static func computeArea(radius: Double) -> Double {
        return MathConstants.pi * radius * radius
    }
}

let area = UtilityFunctions.computeArea(radius: 5)
```
