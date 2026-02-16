---
title: Use @EquatableIgnored for Closure and Handler Properties
impact: HIGH
impactDescription: prevents closures from breaking view diffing — body skipped when data unchanged
tags: diff, closure, equatable, skip, handler
---

## Use @EquatableIgnored for Closure and Handler Properties

Closures cannot conform to `Equatable` — their reference identity changes on every parent render. Without `@EquatableIgnored`, the `@Equatable` macro cannot generate valid conformance, and the build fails. Mark all closure/handler properties with `@EquatableIgnored` so they are excluded from the equality check. The view's body only re-evaluates when its Equatable properties actually change.

**Incorrect (closure property breaks Equatable — view is non-diffable):**

```swift
struct ActionButton: View {
    let title: String
    let icon: String
    let onTap: () -> Void
    // No Equatable conformance — body re-evaluates on every parent update
    // Even if title and icon haven't changed

    var body: some View {
        Button {
            onTap()
        } label: {
            Label(title, systemImage: icon)
        }
        .buttonStyle(.borderedProminent)
    }
}
```

**Correct (@EquatableIgnored on closure — view diffs on title and icon only):**

```swift
@Equatable
struct ActionButton: View {
    let title: String
    let icon: String
    @EquatableIgnored
    let onTap: () -> Void
    // title and icon compared for equality
    // onTap excluded — body only re-evaluates when title or icon change

    var body: some View {
        Button {
            onTap()
        } label: {
            Label(title, systemImage: icon)
        }
        .buttonStyle(.borderedProminent)
    }
}
```

**Multiple handlers:**

```swift
@Equatable
struct SwipeableRow: View {
    let item: ListItem
    @EquatableIgnored let onDelete: () -> Void
    @EquatableIgnored let onArchive: () -> Void
    @EquatableIgnored let onFlag: () -> Void
    // Only item is compared — all handlers are excluded

    var body: some View {
        Text(item.title)
            .swipeActions(edge: .trailing) {
                Button("Delete", role: .destructive, action: onDelete)
                Button("Archive", action: onArchive)
            }
            .swipeActions(edge: .leading) {
                Button("Flag", action: onFlag)
            }
    }
}
```

Reference: [Airbnb Engineering — Understanding and Improving SwiftUI Performance](https://airbnb.tech/uncategorized/understanding-and-improving-swiftui-performance/)
