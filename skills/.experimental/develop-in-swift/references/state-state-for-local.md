---
title: Use @State for View-Local Value Types
impact: CRITICAL
impactDescription: enables reactive UI, SwiftUI manages storage, triggers view updates automatically
tags: state, swiftui, state, reactive, data-flow, value-types
---

## Use @State for View-Local Value Types

`@State` creates mutable state that belongs to a single view. When state changes, SwiftUI automatically re-renders the view. Use `@State` for simple value types (Int, String, Bool) that only this view needs.

**Incorrect (trying to modify view properties):**

```swift
struct CounterView: View {
    var count = 0  // Not @State - can't be modified

    var body: some View {
        Button("Count: \(count)") {
            count += 1  // Error: Cannot assign to property
        }
    }
}
```

**Correct (@State for mutable view-local data):**

```swift
struct CounterView: View {
    @State private var count = 0

    var body: some View {
        Button("Count: \(count)") {
            count += 1  // Works! UI updates automatically
        }
    }
}

// Multiple state properties
struct DiceRollerView: View {
    @State private var diceValue = 1
    @State private var isRolling = false

    var body: some View {
        VStack {
            Text("🎲 \(diceValue)")
                .font(.largeTitle)

            Button("Roll") {
                isRolling = true
                diceValue = Int.random(in: 1...6)
                isRolling = false
            }
            .disabled(isRolling)
        }
    }
}
```

**@State rules:**
- Always mark as `private` - state belongs to the view
- Use for value types (Int, String, Bool, structs)
- SwiftUI manages storage outside the view struct
- Changes trigger body re-evaluation

Reference: [Develop in Swift Tutorials - Update the UI with state](https://developer.apple.com/tutorials/develop-in-swift/update-the-ui-with-state)
