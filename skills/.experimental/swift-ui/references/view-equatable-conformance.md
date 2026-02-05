---
title: Conform Views to Equatable for Diffing
impact: HIGH
impactDescription: replaces reflection-based diffing with fast equality check
tags: view, equatable, diffing, performance, optimization
---

## Conform Views to Equatable for Diffing

When a view conforms to Equatable, SwiftUI uses your equality implementation instead of reflection-based diffing. This is faster for complex views.

**Incorrect (reflection-based diffing):**

```swift
struct MessageRow: View {
    let message: Message
    let isSelected: Bool
    let onTap: () -> Void  // Closure prevents automatic Equatable

    var body: some View {
        HStack {
            Avatar(url: message.sender.avatarURL)
            VStack(alignment: .leading) {
                Text(message.sender.name)
                Text(message.preview)
            }
        }
        .background(isSelected ? Color.accentColor.opacity(0.1) : .clear)
        .onTapGesture(perform: onTap)
    }
}
// SwiftUI must reflect over all properties each time
```

**Correct (Equatable conformance):**

```swift
struct MessageRow: View, Equatable {
    let message: Message
    let isSelected: Bool
    let onTap: () -> Void

    static func == (lhs: MessageRow, rhs: MessageRow) -> Bool {
        lhs.message.id == rhs.message.id &&
        lhs.message.updatedAt == rhs.message.updatedAt &&
        lhs.isSelected == rhs.isSelected
        // Intentionally ignore onTap closure
    }

    var body: some View {
        HStack {
            Avatar(url: message.sender.avatarURL)
            VStack(alignment: .leading) {
                Text(message.sender.name)
                Text(message.preview)
            }
        }
        .background(isSelected ? Color.accentColor.opacity(0.1) : .clear)
        .onTapGesture(perform: onTap)
    }
}

// Usage with .equatable() modifier
List(messages) { message in
    MessageRow(
        message: message,
        isSelected: selectedID == message.id,
        onTap: { selectedID = message.id }
    )
    .equatable()  // Tells SwiftUI to use Equatable
}
```

**When to use Equatable:**
- Views with closures (callbacks, actions)
- Views with complex nested data
- List/grid rows that update frequently
- Views where you want to control what triggers updates

**Note:** For simple value-type-only views, SwiftUI's automatic diffing is usually sufficient.

Reference: [EquatableView Documentation](https://developer.apple.com/documentation/swiftui/equatableview)
