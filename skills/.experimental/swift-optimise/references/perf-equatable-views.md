---
title: Add Equatable Conformance to Prevent Spurious Redraws
impact: MEDIUM
impactDescription: skips redundant body re-evaluations for views with closures or non-Equatable properties, 2-5x fewer body calls in closure-heavy lists
tags: perf, equatable, diffing, re-renders, optimization
---

## Add Equatable Conformance to Prevent Spurious Redraws

When a view conforms to Equatable, SwiftUI uses your equality implementation instead of reflection-based diffing. When a view receives a closure or a non-Equatable property, SwiftUI cannot prove equality and conservatively re-evaluates `body` on every parent invalidation. Adding `Equatable` conformance with a custom `==` that compares only the meaningful inputs lets SwiftUI skip body re-evaluation when the view's semantic content has not changed.

**iOS 17+ note:** With `@Observable`, SwiftUI tracks property access at the individual property level -- only views that read a changed property are invalidated. This eliminates many scenarios where Equatable was previously necessary. Equatable still helps when views receive **closures**, **non-Observable data**, or **non-Equatable properties** that SwiftUI cannot diff automatically.

**Incorrect (closure property forces re-evaluation every time):**

```swift
struct MetricCard: View {
    let title: String
    let value: Int
    let onTap: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
            Text("\(value)")
                .font(.title.bold())
        }
        .onTapGesture { onTap() }
        // SwiftUI cannot compare closures, so body
        // re-evaluates on every parent invalidation
    }
}
```

**Correct (Equatable conformance lets SwiftUI skip unchanged views):**

```swift
struct MetricCard: View, Equatable {
    let title: String
    let value: Int
    let onTap: () -> Void

    static func == (lhs: MetricCard, rhs: MetricCard) -> Bool {
        lhs.title == rhs.title && lhs.value == rhs.value
    }

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
            Text("\(value)")
                .font(.title.bold())
        }
        .onTapGesture { onTap() }
        // SwiftUI uses == to skip body when title and value
        // are unchanged, even though the closure is new
    }
}
```

**Complex view with nested data (reflection-based diffing is expensive):**

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
