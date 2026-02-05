---
title: "Use @State for View-Local Value Types"
impact: HIGH
impactDescription: "enables reactive UI, SwiftUI manages storage outside the view struct"
tags: state, swiftui, property-wrapper, reactivity, value-type
---

## Use @State for View-Local Value Types

SwiftUI view structs are recreated frequently, so plain stored properties lose their values on every re-render. `@State` tells SwiftUI to persist and manage the storage outside the struct, triggering a view update whenever the value changes.

**Incorrect (plain var is reset on every re-render):**

```swift
struct CounterView: View {
    var tapCount = 0 // recreated as 0 on every view update

    var body: some View {
        VStack {
            Text("Taps: \(tapCount)")
            Button("Increment") {
                tapCount += 1 // compile error: cannot mutate immutable property
            }
        }
    }
}
```

**Correct (@State persists value across re-renders):**

```swift
struct CounterView: View {
    @State private var tapCount = 0 // SwiftUI manages storage outside the struct

    var body: some View {
        VStack {
            Text("Taps: \(tapCount)")
            Button("Increment") {
                tapCount += 1 // triggers a view update automatically
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
