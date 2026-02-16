---
title: Use Views for Containers, Modifiers for Styling
impact: HIGH
impactDescription: reduces view hierarchy depth by 1-2 levels per styling abstraction — using the correct abstraction (View vs Modifier vs Style) preserves SwiftUI's composition model
tags: style, view, modifier, composition, decision
---

## Use Views for Containers, Modifiers for Styling

Apple's own APIs follow a clear division: containers that arrange children are Views (`HStack`, `VStack`, `List`, `NavigationStack`), and visual treatments applied to existing content are modifiers (`.padding()`, `.background()`, `.clipShape()`). Violating this — creating a View that just applies styling to a single child, or a modifier that tries to arrange multiple children — creates confusing, non-composable code.

**Incorrect (View used for what should be a modifier):**

```swift
// StyledCard just applies visual treatment — this should be a modifier
struct StyledCard<Content: View>: View {
    let content: Content

    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    var body: some View {
        content
            .padding(.cardContent)
            .background(.backgroundSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

// Usage — wrapping feels heavy:
StyledCard {
    VStack(alignment: .leading) {
        Text(item.title)
        Text(item.subtitle)
    }
}

// What if you want card styling on a NavigationLink?
// Now you have to wrap it:
StyledCard {
    NavigationLink(destination: DetailView(item: item)) {
        Text(item.title) // Awkward nesting
    }
}
```

**Correct (modifier for styling, View for containers):**

```swift
// MODIFIER — applies visual treatment to any view
struct CardModifier: ViewModifier {
    var elevation: CardElevation = .low

    func body(content: Content) -> some View {
        content
            .padding(.cardContent)
            .background(.backgroundSurface)
            .clipShape(RoundedRectangle(cornerRadius: Radius.md))
            .shadow(color: .black.opacity(elevation.shadowOpacity),
                    radius: elevation.shadowRadius, y: elevation.shadowY)
    }
}

enum CardElevation {
    case none, low, medium
    var shadowOpacity: Double { [0, 0.06, 0.12][[CardElevation.none, .low, .medium].firstIndex(of: self)!] }
    var shadowRadius: CGFloat { self == .medium ? 16 : (self == .low ? 8 : 0) }
    var shadowY: CGFloat { self == .medium ? 4 : (self == .low ? 2 : 0) }
}

extension View {
    func cardStyle(elevation: CardElevation = .low) -> some View {
        modifier(CardModifier(elevation: elevation))
    }
}
```

```swift
// Usage — chains naturally with any view:
VStack(alignment: .leading) {
    Text(item.title)
    Text(item.subtitle)
}
.cardStyle()

NavigationLink(destination: DetailView(item: item)) {
    Text(item.title)
}
.cardStyle(elevation: .medium)
```

**VIEW — use when the component arranges multiple children with structure:**

```swift
// This IS a container — it defines the layout of its children
struct MetricCard<Content: View>: View {
    let title: String
    let value: String
    @ViewBuilder let detail: () -> Content

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            Text(title)
                .font(AppTypography.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(AppTypography.displayMedium)
            detail()
        }
        .cardStyle() // Uses the modifier for styling
    }
}

// Usage:
MetricCard(title: "Revenue", value: "$12,450") {
    Label("+12% this week", systemImage: "arrow.up.right")
        .font(AppTypography.caption)
        .foregroundStyle(.green)
}
```

**Decision guide:**

```text
Does the component define a LAYOUT of multiple children?
├── YES → Make it a View (struct conforming to View protocol)
│         Examples: MetricCard, UserProfile, SearchBar
│
└── NO → Does it apply VISUAL TREATMENT to a single view?
    ├── YES → Make it a ViewModifier
    │         Examples: cardStyle, shimmerEffect, badgeOverlay
    │
    └── Is it a CONTROL APPEARANCE change?
        ├── YES → Make it a Style (ButtonStyle, ToggleStyle, etc.)
        │         Examples: PrimaryButtonStyle, CheckboxToggleStyle
        │
        └── Use chained modifiers directly — don't abstract until you repeat in 3+ places.
```

The key test: if your "component" has only one `content` child and just applies modifiers to it, it should be a ViewModifier, not a View.
