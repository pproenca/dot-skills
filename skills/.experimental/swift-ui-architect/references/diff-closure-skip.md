---
title: Use @SkipEquatable for Closure and Handler Properties
impact: CRITICAL
impactDescription: prevents entire view from becoming non-diffable
tags: diff, closures, skip-equatable, handlers, actions
---

## Use @SkipEquatable for Closure and Handler Properties

Closures cannot be compared for equality. A single closure property makes the entire view non-diffable. Mark closures and action handlers with `@SkipEquatable` to exclude them from the generated `Equatable` conformance while keeping the rest of the view diffable.

**Incorrect (@Equatable with closure — build error or non-diffable):**

```swift
@Equatable
struct ActionRow: View {
    let title: String
    let subtitle: String
    let onTap: () -> Void        // closure — NOT Equatable
    let onLongPress: () -> Void  // closure — NOT Equatable

    // Build error: type 'ActionRow' does not conform to 'Equatable'
    // because () -> Void is not Equatable

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .onTapGesture(perform: onTap)
        .onLongPressGesture(perform: onLongPress)
    }
}
```

**Correct (@SkipEquatable on closures — view remains diffable for data properties):**

```swift
@Equatable
struct ActionRow: View {
    let title: String
    let subtitle: String
    @SkipEquatable let onTap: () -> Void
    @SkipEquatable let onLongPress: () -> Void

    // Equatable generated for title + subtitle only
    // Body re-evaluates only when title or subtitle changes

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(title)
                Text(subtitle).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .onTapGesture(perform: onTap)
        .onLongPressGesture(perform: onLongPress)
    }
}
```

**Alternative:** If the closure captures data that determines equivalence, wrap it in an Equatable action type:

```swift
enum CardAction: Equatable {
    case addToCart(productID: String)
    case removeFromCart(productID: String)
}

@Equatable
struct ActionCard: View {
    let title: String
    let action: CardAction  // Equatable — no @SkipEquatable needed
    @SkipEquatable let perform: (CardAction) -> Void

    var body: some View { /* ... */ }
}
```

Reference: [Airbnb Engineering — @Equatable macro](https://medium.com/airbnb-engineering/understanding-and-improving-swiftui-performance-b95d990b4ef1)
