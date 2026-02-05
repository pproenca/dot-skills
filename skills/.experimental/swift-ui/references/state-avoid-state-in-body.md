---
title: Avoid Creating State Inside View Body
impact: CRITICAL
impactDescription: prevents re-initialization on every render
tags: state, body, initialization, performance
---

## Avoid Creating State Inside View Body

Creating objects or heavy computations inside the view body causes them to run on every re-render. State and expensive work must be outside the body.

**Incorrect (DateFormatter created every render):**

```swift
struct EventDateView: View {
    let event: Event

    var body: some View {
        let formatter = DateFormatter()  // Created EVERY render
        formatter.dateStyle = .medium
        formatter.timeStyle = .short

        return Text(formatter.string(from: event.date))
    }
}
```

**Correct (formatter cached outside body):**

```swift
struct EventDateView: View {
    let event: Event

    private static let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    var body: some View {
        Text(Self.formatter.string(from: event.date))
    }
}
```

**Alternative (computed property):**

```swift
struct EventDateView: View {
    let event: Event

    private var formattedDate: String {
        event.date.formatted(date: .abbreviated, time: .shortened)
    }

    var body: some View {
        Text(formattedDate)  // Uses modern formatting API
    }
}
```

**Note:** For truly expensive computations that depend on props, consider moving them to the model layer or using a task modifier.

Reference: [The Secret to Buttery Smooth SwiftUI](https://www.swiftdifferently.com/blog/swiftui/swiftui-performance-article)
