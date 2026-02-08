---
title: Use Group or Conditional Modifiers Over Conditional Views
impact: HIGH
impactDescription: preserves view identity across state changes, prevents animation glitches
tags: view, conditional, identity, animation, group
---

## Use Group or Conditional Modifiers Over Conditional Views

SwiftUI assigns structural identity based on a view's position in the if/else branch. When an if/else returns completely different view types, SwiftUI treats them as two separate identities. On state change it destroys one and creates the other, resetting all internal state and breaking animations. Using the same view with conditional modifiers preserves identity so SwiftUI can animate the transition smoothly.

**Incorrect (if/else creates two identities, destroying state and animations):**

```swift
struct NotificationBanner: View {
    let message: String
    let isUrgent: Bool

    var body: some View {
        if isUrgent {
            HStack {
                Image(systemName: "exclamationmark.triangle.fill")
                Text(message).bold()
            }
            .padding()
            .background(.red)
            .foregroundStyle(.white)
            .cornerRadius(10)
            .transition(.move(edge: .top))
        } else {
            HStack {
                Image(systemName: "info.circle.fill")
                Text(message)
            }
            .padding()
            .background(.blue.opacity(0.15))
            .foregroundStyle(.primary)
            .cornerRadius(10)
            .transition(.move(edge: .top))
        }
    }
}
```

**Correct (single view with conditional modifiers preserves identity):**

```swift
struct NotificationBanner: View {
    let message: String
    let isUrgent: Bool

    var body: some View {
        HStack {
            Image(systemName: isUrgent
                  ? "exclamationmark.triangle.fill"
                  : "info.circle.fill")
            Text(message)
                .bold(isUrgent)
        }
        .padding()
        .background(isUrgent ? AnyShapeStyle(.red) : AnyShapeStyle(.blue.opacity(0.15)))
        .foregroundStyle(isUrgent ? AnyShapeStyle(.white) : AnyShapeStyle(.primary))
        .cornerRadius(10)
        .animation(.easeInOut, value: isUrgent)
    }
}
```

Reference: [Demystify SwiftUI - WWDC21](https://developer.apple.com/videos/play/wwdc2021/10022/)
