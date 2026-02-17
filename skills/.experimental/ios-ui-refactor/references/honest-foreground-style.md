---
title: Use foregroundStyle Over foregroundColor
impact: CRITICAL
impactDescription: eliminates 100% of foregroundColor deprecation warnings — foregroundStyle supports ShapeStyle (gradients, hierarchical colors, materials) in a single modifier
tags: honest, api, foreground-style, rams-6, segall-brutal
---

## Use foregroundStyle Over foregroundColor

Good craft shows in the names of things. `foregroundColor` says "I style your foreground" but only accepts a `Color` — try handing it a gradient and it refuses. The name overpromises and the type system under-delivers, a small dishonesty that compounds across every view in your codebase. `foregroundStyle` is the honest tool: it says what it does, and it accepts what it promises. Pass it a `Color`, a `LinearGradient`, a `Material`, a `HierarchicalShapeStyle` — it handles them all because its contract matches its capability. This is the craft distinction between an API you fight and one that fits your hand. Since iOS 15, `foregroundStyle` has been the preferred API; in iOS 17+ codebases there is no reason to reach for the deprecated, limited alternative.

**Incorrect (foregroundColor limiting style options):**

```swift
struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.icon)
                .foregroundColor(.blue)

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundColor(.primary)

                Text(notification.body)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                Text(notification.timestamp.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundColor(Color.gray.opacity(0.8))
            }
        }
    }
}
```

**Correct (foregroundStyle with hierarchical rendering):**

```swift
struct NotificationRow: View {
    let notification: AppNotification

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: notification.icon)
                .foregroundStyle(.tint)

            VStack(alignment: .leading, spacing: 2) {
                Text(notification.title)
                    .font(.headline)
                    .foregroundStyle(.primary)

                Text(notification.body)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                Text(notification.timestamp.formatted(.relative(presentation: .named)))
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
    }
}
```

**Benefits beyond the type system:**

```swift
// Gradient text — impossible with foregroundColor
Text("Premium")
    .font(.title)
    .fontWeight(.bold)
    .foregroundStyle(
        .linearGradient(
            colors: [.purple, .blue],
            startPoint: .leading,
            endPoint: .trailing
        )
    )

// Multi-level hierarchical style on a label
Label("Downloads", systemImage: "arrow.down.circle.fill")
    .foregroundStyle(.blue, .blue.opacity(0.3))
```

**When NOT to apply:**
- If your deployment target is below iOS 15, `foregroundColor` is the only option. However, for iOS 17+ codebases (which this skill targets), there is no such constraint.
- When interfacing with UIKit views through `UIViewRepresentable`, you may need to use `UIColor` directly rather than either SwiftUI modifier.

Reference: [Apple Developer — foregroundStyle(_:)](https://developer.apple.com/documentation/swiftui/view/foregroundstyle(_:))
