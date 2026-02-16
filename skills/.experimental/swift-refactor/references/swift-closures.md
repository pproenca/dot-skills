---
title: Use Closures for Inline Functions
impact: HIGH
impactDescription: reduces boilerplate by 40-60% vs named functions for callbacks and event handlers
tags: swift, closures, functions, callbacks, trailing-closure
---

## Use Closures for Inline Functions

Closures are self-contained blocks of code that capture values from their context. SwiftUI uses closures extensively for button actions, list item views, and async callbacks. Use trailing closure syntax for cleaner code and prefer shorthand argument names for simple transformations.

**Incorrect (named functions for simple one-off operations):**

```swift
struct CounterView: View {
    @State private var count = 0

    func incrementCount() {
        count += 1
    }

    func decrementCount() {
        count -= 1
    }

    var body: some View {
        HStack {
            Button("−", action: decrementCount)
            Text("\(count)")
            Button("+", action: incrementCount)
        }
    }
}

// Named function for trivial array operation
func doubleValue(_ value: Int) -> Int {
    return value * 2
}
let doubled = numbers.map(doubleValue)
```

**Correct (closures for inline operations, trailing syntax):**

```swift
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        HStack {
            Button("−") { count -= 1 }
            Text("\(count)")
            Button("+") { count += 1 }
        }
    }
}

// Closure with shorthand argument for simple transform
let doubled = numbers.map { $0 * 2 }

// Trailing closure for SwiftUI modifiers
Button {
    count += 1
} label: {
    Label("Increment", systemImage: "plus")
}

// Multi-line closures for complex operations
ForEach(friends) { friend in
    Text(friend.name)
}
```

**Closure patterns:**
- Use trailing closure syntax when last parameter is a closure
- `$0`, `$1` for shorthand argument names in simple transforms
- Closures capture variables from their context
- `@escaping` for closures stored for later execution

Reference: [Develop in Swift Tutorials - Update the UI with state](https://developer.apple.com/tutorials/develop-in-swift/update-the-ui-with-state)
