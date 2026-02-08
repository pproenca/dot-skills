---
title: Use ViewThatFits for Adaptive Layouts
impact: MEDIUM
impactDescription: automatically selects the first child view that fits available space
tags: acc, view-that-fits, adaptive-layout, dynamic-type, responsive
---

## Use ViewThatFits for Adaptive Layouts

When users increase their text size or rotate to a narrow orientation, fixed horizontal layouts overflow and clip content. `ViewThatFits` evaluates each child view in order and renders the first one that fits within the available space, letting you provide graceful fallbacks without manual size calculations.

**Incorrect (fixed horizontal layout overflows with large text):**

```swift
struct EventActions: View {
    let event: CalendarEvent

    var body: some View {
        HStack(spacing: 12) {
            Button("Accept") { acceptEvent(event) }
                .buttonStyle(.borderedProminent)
            Button("Decline") { declineEvent(event) }
                .buttonStyle(.bordered)
            Button("Maybe") { tentativeEvent(event) }
                .buttonStyle(.bordered)
        }
    }
}
```

**Correct (ViewThatFits switches to vertical layout when needed):**

```swift
struct EventActions: View {
    let event: CalendarEvent

    var body: some View {
        ViewThatFits { // picks the first layout that fits
            HStack(spacing: 12) {
                Button("Accept") { acceptEvent(event) }
                    .buttonStyle(.borderedProminent)
                Button("Decline") { declineEvent(event) }
                    .buttonStyle(.bordered)
                Button("Maybe") { tentativeEvent(event) }
                    .buttonStyle(.bordered)
            }
            VStack(spacing: 8) {
                Button("Accept") { acceptEvent(event) }
                    .buttonStyle(.borderedProminent)
                Button("Decline") { declineEvent(event) }
                    .buttonStyle(.bordered)
                Button("Maybe") { tentativeEvent(event) }
                    .buttonStyle(.bordered)
            }
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
