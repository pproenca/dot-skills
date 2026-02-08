---
title: Use for-in Loops for Collections
impact: HIGH
impactDescription: idiomatic Swift, safer than index-based loops, works with any Sequence
tags: swift, loops, for-in, iteration, collections
---

## Use for-in Loops for Collections

Swift's `for-in` loop iterates over sequences directly. Prefer it over C-style index loops - it's safer, more readable, and works with any type that conforms to `Sequence`.

**Incorrect (index-based iteration):**

```swift
let pals = ["Elisha", "Andre", "Jasmine"]

// C-style loop is verbose and error-prone
for var i = 0; i < pals.count; i += 1 {
    print(pals[i])
}

// While loop for iteration
var index = 0
while index < pals.count {
    print(pals[index])
    index += 1
}
```

**Correct (for-in iteration):**

```swift
let pals = ["Elisha", "Andre", "Jasmine"]

// Iterate directly over elements
for pal in pals {
    print("Pal: \(pal)")
}

// With index when needed
for (index, pal) in pals.enumerated() {
    print("\(index): \(pal)")
}

// Iterate over ranges
for number in 1...5 {
    print(number)  // 1, 2, 3, 4, 5
}

// Iterate over dictionary
let scores = ["Alice": 95, "Bob": 87]
for (name, score) in scores {
    print("\(name): \(score)")
}
```

**for-in advantages:**
- No off-by-one errors
- Works with any Sequence (arrays, sets, ranges, strings)
- Clearer intent than index manipulation
- SwiftUI uses ForEach which follows the same pattern

Reference: [Develop in Swift Tutorials - Swift Fundamentals](https://developer.apple.com/tutorials/develop-in-swift/swift-fundamentals)
