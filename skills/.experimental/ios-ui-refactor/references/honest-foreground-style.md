---
title: Use foregroundStyle Over foregroundColor
impact: CRITICAL
impactDescription: eliminates 100% of foregroundColor deprecation warnings — foregroundStyle supports ShapeStyle (gradients, hierarchical colors, materials) in a single modifier
tags: honest, api, foreground-style, rams-6, segall-brutal
---

## Use foregroundStyle Over foregroundColor

Rams' honesty extends to the API itself — `foregroundColor` claims to accept styling but only handles `Color`. It is a lie of omission: the name promises general-purpose foreground styling but delivers a narrow type constraint that silently rejects gradients, materials, and hierarchical styles. `foregroundStyle` is honest about its capabilities: it accepts any `ShapeStyle` — `Color`, `HierarchicalShapeStyle`, `LinearGradient`, `Material` — and integrates with SwiftUI's hierarchical rendering system. Segall's Think Brutal: use the API that does what it says, not the one with a familiar name. Since iOS 15, `foregroundStyle` has been the preferred API; in iOS 17+ codebases there is no reason to reach for the deprecated, limited alternative.

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
