---
title: Define Custom Style Protocols for Complex Design System Components
impact: CRITICAL
impactDescription: Airbnb's DLS uses style protocols as the primary component API — enables O(1) new variants with zero accessibility regressions vs O(n) wrapper views per variant
tags: style, protocol, dls, airbnb, composition
---

## Define Custom Style Protocols for Complex Design System Components

SwiftUI provides built-in style protocols for standard controls (ButtonStyle, ToggleStyle), but design system components that go beyond standard controls need their own style protocols. Airbnb's Design Language System (DLS) uses this pattern extensively — each DLS component defines a style protocol, and product engineers create new visual variants by conforming to the protocol rather than subclassing or wrapping. This ensures every variant inherits accessibility, animation, and interaction behavior from the base component.

**Incorrect (wrapper views per variant — duplicated behavior):**

```swift
// Each variant is a separate View with duplicated interaction logic
struct FilledRatingControl: View {
    @Binding var rating: Int
    let maxRating: Int

    var body: some View {
        HStack(spacing: Spacing.xs) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: index <= rating ? "star.fill" : "star")
                    .foregroundStyle(index <= rating ? .statusWarning : .tertiary)
                    .onTapGesture { rating = index }
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) of \(maxRating)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: rating = min(rating + 1, maxRating)
            case .decrement: rating = max(rating - 1, 1)
            @unknown default: break
            }
        }
    }
}

// Compact variant — duplicates ALL interaction + accessibility logic
struct CompactRatingControl: View {
    @Binding var rating: Int
    let maxRating: Int

    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Circle()
                    .fill(index <= rating ? .accentPrimary : .fill.tertiary)
                    .frame(width: 8, height: 8)
                    .onTapGesture { rating = index }
            }
        }
        // Forgot accessibility — compact variant is inaccessible
    }
}
```

**Correct (style protocol — one component, many visual variants):**

```swift
// MARK: - Style Protocol + Configuration
protocol RatingControlStyle {
    associatedtype Body: View
    @ViewBuilder func makeBody(configuration: RatingControlConfiguration) -> Body
}

struct RatingControlConfiguration {
    let rating: Int
    let maxRating: Int
    let setRating: (Int) -> Void
}

// MARK: - Base Component (owns interaction + accessibility)
struct RatingControl<Style: RatingControlStyle>: View {
    @Binding var rating: Int
    let maxRating: Int
    let style: Style

    var body: some View {
        style.makeBody(configuration: RatingControlConfiguration(
            rating: rating, maxRating: maxRating, setRating: { rating = $0 }
        ))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Rating")
        .accessibilityValue("\(rating) of \(maxRating)")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: rating = min(rating + 1, maxRating)
            case .decrement: rating = max(rating - 1, 1)
            @unknown default: break
            }
        }
    }
}
```

```swift
// MARK: - Style Variants (create new looks with zero duplication)
struct StarRatingStyle: RatingControlStyle {
    func makeBody(configuration: RatingControlConfiguration) -> some View {
        HStack(spacing: Spacing.xs) {
            ForEach(1...configuration.maxRating, id: \.self) { index in
                Image(systemName: index <= configuration.rating ? "star.fill" : "star")
                    .foregroundStyle(index <= configuration.rating ? .statusWarning : .tertiary)
                    .onTapGesture { configuration.setRating(index) }
            }
        }
    }
}

struct CompactDotRatingStyle: RatingControlStyle {
    func makeBody(configuration: RatingControlConfiguration) -> some View {
        HStack(spacing: Spacing.xxs) {
            ForEach(1...configuration.maxRating, id: \.self) { index in
                Circle()
                    .fill(index <= configuration.rating ? .accentPrimary : .fill.tertiary)
                    .frame(width: 8, height: 8)
                    .onTapGesture { configuration.setRating(index) }
            }
        }
    }
}
```

**When to define a custom style protocol:**

| Scenario | Style protocol? |
|----------|----------------|
| Standard control (Button, Toggle) | No — use built-in ButtonStyle, ToggleStyle |
| DLS component with 2+ visual variants | Yes |
| Component with complex accessibility | Yes — centralizes accessibility in base component |
| One-off component with no variants | No — a simple View is sufficient |

**Benefits:**
- New visual variants require zero duplication of accessibility or interaction logic
- Accessibility is tested once in the base component, inherited by all variants
- Product engineers can create feature-specific styles without touching the component
- Consistent with Airbnb's DLS architecture pattern

Reference: [Unlocking SwiftUI at Airbnb](https://medium.com/airbnb-engineering/unlocking-swiftui-at-airbnb-ea58f50cde49), [Styling Components in SwiftUI](https://movingparts.io/styling-components-in-swiftui)
