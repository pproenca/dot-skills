---
title: Prefer Composition Over Inheritance for Views
impact: CRITICAL
impactDescription: SwiftUI views are structs, composition is the only extensibility pattern
tags: view, swiftui, composition, architecture, structs
---

## Prefer Composition Over Inheritance for Views

SwiftUI views are value-type structs, not classes, so subclassing is not available. Attempting class-based inheritance patterns leads to compiler errors or fragile workarounds that fight the framework. The idiomatic approach is to compose smaller views together and use `ViewModifier` to share cross-cutting styling.

**Incorrect (class-based thinking, trying to inherit from a base view):**

```swift
class BaseCard: View { // structs cannot be subclassed
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

class EventCard: BaseCard { // cannot inherit from a struct
    let date: Date

    override var body: some View {
        VStack(alignment: .leading) {
            super.body
            Text(date, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

**Correct (compose structs and use ViewModifier for shared styling):**

```swift
struct CardStyle: ViewModifier { // shared styling extracted once
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

struct BaseCard: View {
    let title: String

    var body: some View {
        VStack(alignment: .leading) {
            Text(title).font(.headline)
        }
        .modifier(CardStyle())
    }
}

struct EventCard: View {
    let title: String
    let date: Date

    var body: some View { // compose BaseCard, don't inherit
        VStack(alignment: .leading) {
            BaseCard(title: title)
            Text(date, style: .date)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
