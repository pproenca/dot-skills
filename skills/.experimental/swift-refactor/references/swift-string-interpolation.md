---
title: Use String Interpolation for Dynamic Text
impact: HIGH
impactDescription: cleaner than concatenation, type-safe, supports complex expressions
tags: swift, strings, interpolation, formatting
---

## Use String Interpolation for Dynamic Text

Swift uses `\(expression)` inside string literals to embed values. This is cleaner and more readable than string concatenation with `+`.

**Incorrect (string concatenation):**

```swift
let name = "Jasmine"
let age = 25

// Verbose and error-prone
let greeting = "Hello, " + name + "! You are " + String(age) + " years old."

// Multiple lines of building
var message = "User: "
message = message + name
message = message + " (age: "
message = message + String(age)
message = message + ")"
```

**Correct (string interpolation):**

```swift
let name = "Jasmine"
let age = 25

// Clean and readable
let greeting = "Hello, \(name)! You are \(age) years old."

// Works with any expression
let pals = ["Elisha", "Andre", "Jasmine"]
for pal in pals {
    print("Pal: \(pal)")
}

// Complex expressions
let price = 19.99
let quantity = 3
let summary = "Total: $\(price * Double(quantity))"

// SwiftUI usage
Text("Welcome, \(userName)!")
```

**Interpolation capabilities:**
- Embed any value that conforms to `CustomStringConvertible`
- Include expressions: `\(items.count + 1)`
- Call methods: `\(name.uppercased())`
- Format with specifiers: `\(price, specifier: "%.2f")`

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)
