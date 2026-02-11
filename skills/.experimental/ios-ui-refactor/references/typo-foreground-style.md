---
title: Use foregroundStyle Over foregroundColor
impact: CRITICAL
impactDescription: foregroundColor is effectively deprecated since iOS 17 — foregroundStyle supports ShapeStyle (gradients, hierarchical colors, materials), enabling richer text rendering without workarounds
tags: typo, api-modernization, foreground-style, color
---

## Use foregroundStyle Over foregroundColor

`foregroundColor` accepts only a `Color` value. `foregroundStyle` accepts any `ShapeStyle`, which includes `Color`, `HierarchicalShapeStyle` (`.secondary`, `.tertiary`, `.quaternary`), gradients, and materials. Since iOS 15, `foregroundStyle` has been the preferred API, and in iOS 17+ codebases there is no reason to reach for `foregroundColor` at all. Beyond the wider type support, `foregroundStyle` integrates with SwiftUI's hierarchical rendering system — when a parent view sets `.foregroundStyle(.blue)`, child views can use `.secondary` to automatically get a lighter variant without hard-coding opacity values.

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
