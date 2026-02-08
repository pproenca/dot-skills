---
title: Use Closures for Inline Functions
impact: HIGH
impactDescription: enables callbacks, powers SwiftUI buttons, functional programming patterns
tags: swift, closures, functions, callbacks, trailing-closure
---

## Use Closures for Inline Functions

Closures are self-contained blocks of code that capture values from their context. SwiftUI uses closures extensively for button actions, list item views, and async callbacks. Use trailing closure syntax for cleaner code.

**Basic closure syntax:**

```swift
// Full closure syntax
let greet: (String) -> String = { (name: String) -> String in
    return "Hello, \(name)!"
}

// Simplified with type inference
let greet = { name in
    "Hello, \(name)!"
}

// Shorthand argument names
let numbers = [1, 2, 3]
let doubled = numbers.map { $0 * 2 }  // [2, 4, 6]
```

**Closures in SwiftUI:**

```swift
// Button action is a closure
Button("Tap Me") {
    // This closure runs when button is tapped
    count += 1
}

// Trailing closure syntax
Button {
    count += 1
} label: {
    Text("Increment")
}

// ForEach content is a closure
ForEach(friends) { friend in
    Text(friend.name)
}

// onAppear, onChange take closures
.onAppear {
    loadData()
}

.onChange(of: searchText) { oldValue, newValue in
    performSearch(newValue)
}

// Async closures
Task {
    await fetchData()
}
```

**Closure patterns:**
- Use trailing closure syntax when last parameter is a closure
- `$0`, `$1` for shorthand argument names
- Closures capture variables from their context
- `@escaping` for closures stored for later execution

Reference: [Develop in Swift Tutorials - Update the UI with state](https://developer.apple.com/tutorials/develop-in-swift/update-the-ui-with-state)
