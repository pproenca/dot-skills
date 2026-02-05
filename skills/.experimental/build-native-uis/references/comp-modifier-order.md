---
title: Apply Modifiers in Correct Order
impact: CRITICAL
impactDescription: modifier order changes visual output, each modifier wraps the previous view
tags: comp, swiftui, modifiers, layout, styling
---

## Apply Modifiers in Correct Order

Each SwiftUI modifier wraps the view that precedes it, producing a new view. This means `.background()` before `.padding()` paints behind the content only, while `.padding()` before `.background()` paints behind the content plus its padding. Getting this wrong produces layouts that look subtly broken and are hard to debug.

**Incorrect (background applied before padding, shadow before clip):**

```swift
struct NotificationBadge: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .background(Color.red) // background hugs text, padding added outside
            .padding(12)
            .shadow(radius: 8) // shadow renders on square corners
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .foregroundStyle(.white)
    }
}
```

**Correct (padding then background, clip then shadow):**

```swift
struct NotificationBadge: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.subheadline)
            .foregroundStyle(.white)
            .padding(12) // content sizing first
            .background(Color.red) // fills padded area
            .clipShape(RoundedRectangle(cornerRadius: 12)) // clip before shadow
            .shadow(radius: 8) // shadow follows clipped shape
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
