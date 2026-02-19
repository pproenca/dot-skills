---
title: Apply @Equatable Macro to Prevent Spurious Redraws
impact: CRITICAL
impactDescription: 15% scroll hitch reduction measured at Airbnb — compile-time guarantee prevents entire view from becoming non-diffable when closures or non-Equatable properties are added
tags: perf, equatable, diffing, re-renders, optimization, macro
---

## Apply @Equatable Macro to Prevent Spurious Redraws

When a view contains ANY non-Equatable property (closures, reference types), SwiftUI's reflection-based diffing fails silently and conservatively re-evaluates `body` on every parent invalidation. The `@Equatable` macro generates `Equatable` conformance for all stored properties, excluding those marked `@SkipEquatable`. Build fails if a non-Equatable property is added without `@SkipEquatable` — acting as a compile-time performance linter.

**iOS 26 / Swift 6.2 note:** With `@Observable`, SwiftUI tracks property access at the individual property level — only views that read a changed property are invalidated. `@Equatable` still prevents unnecessary body re-evaluations when views receive **closures**, **non-Observable data**, or **non-Equatable properties** that SwiftUI cannot diff automatically.

**Incorrect (no @Equatable — closure makes entire view non-diffable):**

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

**Correct (@Equatable macro — compile-time diffability guarantee):**

```swift
@Equatable
struct MetricCard: View {
    let title: String
    let value: Int
    @SkipEquatable let onTap: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.caption)
            Text("\(value)")
                .font(.title.bold())
        }
        .onTapGesture { onTap() }
        // Body only re-evaluates when title or value changes
        // Closure excluded from comparison via @SkipEquatable
    }
}
```

**Complex list row with multiple closures:**

```swift
@Equatable
struct MessageRow: View {
    let message: Message
    let isSelected: Bool
    @SkipEquatable let onTap: () -> Void
    @SkipEquatable let onSwipeDelete: () -> Void

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
```

**Prerequisite:** The `@Equatable` macro requires the [`ordo-one/equatable`](https://github.com/ordo-one/equatable) SPM package (or equivalent). This is NOT built into SwiftUI. Add it via `Package.swift` or Xcode's package manager. The open-source package uses `@EquatableIgnored` instead of `@SkipEquatable` (which is Airbnb's internal name).

**Alternative (built-in SwiftUI, no third-party dependency):**

```swift
struct MetricCard: View, Equatable {
    let title: String
    let value: Int
    let onTap: () -> Void

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.title == rhs.title && lhs.value == rhs.value
    }

    var body: some View {
        VStack {
            Text(title).font(.caption)
            Text("\(value)").font(.title.bold())
        }
        .onTapGesture { onTap() }
    }
}
// Use with .equatable() modifier
```

**When to use @Equatable:**
- Every view that receives closures (callbacks, actions)
- Views with complex nested data
- List/grid rows that update frequently
- Views where you want compile-time diffability enforcement

**When manual Equatable is acceptable:**
- Projects that cannot add the ordo-one/equatable dependency
- Simple views with no closures where SwiftUI's automatic diffing suffices

**See also:** [`diff-equatable-views`](../../swift-ui-architect/references/diff-equatable-views.md), [`diff-closure-skip`](../../swift-ui-architect/references/diff-closure-skip.md) in swift-ui-architect for the full diffing strategy.

Reference: [Airbnb Engineering — Understanding and Improving SwiftUI Performance](https://airbnb.tech/uncategorized/understanding-and-improving-swiftui-performance/)
