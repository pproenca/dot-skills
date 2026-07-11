---
title: Use case-less enums for namespaces instead of structs or classes
tags: api, namespaces, enums, code-organization
---

## Use case-less enums for namespaces instead of structs or classes

The wrong default is grouping constants or utility functions in a `struct Constants { static let ... }` or a class used purely as a namespace. A struct or class can still be pointlessly instantiated — `Constants()` compiles and means nothing. Since enums without cases cannot be instantiated at all, a case-less enum expresses namespace intent exactly and gets the compiler to enforce it.

**Evidence of violation:** a `struct` or `class` containing only static members — no instance properties, no instance methods, and no initializer usage anywhere in the reviewed code — serving purely as a namespace. PASS when the container is a case-less `enum` with static members. N/A when the type is instantiated anywhere in the reviewed code, has instance members, or needs a protocol conformance that requires instances.

**Incorrect (the namespace can be instantiated, which means nothing):**

```swift
struct MathConstants {
    static let pi = 3.14159
    static let e = 2.71828
}

// Compiles, and is meaningless:
let instance = MathConstants()
```

**Correct (a case-less enum cannot be instantiated — intent is compiler-enforced):**

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

Reference: *Swift Gems* (Natalia Panferova, Nil Coalescing, updated Nov 2025), “Organize related functionalities using enums as namespaces”
