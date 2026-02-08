---
title: Use VStack, HStack, ZStack for Layout
impact: CRITICAL
impactDescription: fundamental layout containers, determines view arrangement, performance-optimized
tags: layout, vstack, hstack, zstack, composition
---

## Use VStack, HStack, ZStack for Layout

Stack views are the primary layout containers in SwiftUI. VStack arranges views vertically, HStack horizontally, and ZStack in layers (front to back). Combine them to create any layout.

**Incorrect (manual positioning):**

```swift
// Don't try to manually position views
Text("First")
    .position(x: 100, y: 50)
Text("Second")
    .position(x: 100, y: 100)

// Don't use offset for basic layout
Text("Hello").offset(y: -20)
Text("World").offset(y: 20)
```

**Correct (stack-based layout):**

```swift
// VStack - vertical arrangement
VStack {
    Text("Knock, knock!")
    Text("Who's there?")
}

// HStack - horizontal arrangement
HStack {
    Image(systemName: "star")
    Text("Favorites")
}

// ZStack - layered arrangement
ZStack {
    RoundedRectangle(cornerRadius: 10)
        .fill(Color.blue)
    Text("Overlay")
        .foregroundColor(.white)
}

// Nested stacks for complex layouts
VStack(alignment: .leading, spacing: 8) {
    HStack {
        Image(systemName: "person.fill")
        Text("Sophie Sun")
    }
    HStack {
        Image(systemName: "envelope")
        Text("sophie@example.com")
    }
}
```

**Stack parameters:**
- `alignment`: How children align (`.leading`, `.center`, `.trailing`)
- `spacing`: Space between children (use `nil` for default)
- Children are arranged in declaration order

Reference: [Develop in Swift Tutorials - Hello, SwiftUI](https://developer.apple.com/tutorials/develop-in-swift/hello-swiftui)
