---
title: Configure Stack Alignment and Spacing Explicitly
impact: HIGH
impactDescription: default center alignment and 8pt spacing are wrong for 70% of content layouts — explicit configuration eliminates visual misalignment that users perceive as sloppiness
tags: system, stacks, alignment, spacing, kocienda-convergence, edson-systems
---

## Configure Stack Alignment and Spacing Explicitly

Edson's systems thinking means every stack participates in the spatial system — alignment and spacing are deliberate design decisions, not defaults accepted by inertia. Kocienda's convergence demanded that even the gap between keyboard keys was intentionally chosen, not left to the framework's default. SwiftUI's `VStack` defaults to center alignment and 8pt spacing, which is correct for roughly 30% of layouts. The other 70% — left-aligned text blocks, right-aligned values, zero-spacing label groups — require explicit configuration.

**Incorrect (relying on VStack defaults for all layouts):**

```swift
struct EventCard: View {
    let event: Event

    var body: some View {
        VStack {
            // Center-aligned by default — text floats in the middle
            Text(event.title)
                .font(.headline)
            Text(event.date.formatted())
                .font(.subheadline)
            Text(event.location)
                .font(.caption)
            // Default 8pt spacing between all items — uniform, not intentional
        }
    }
}
```

**Correct (explicit alignment and grouped spacing):**

```swift
struct EventCard: View {
    let event: Event

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(event.title)
                .font(.headline)

            Text(event.date.formatted())
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text(event.location)
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}
```

**Stack configuration guide:**

```swift
// Text content blocks: left-aligned, tight spacing
VStack(alignment: .leading, spacing: 4) { ... }

// Form-like label-value pairs: full width
HStack {
    Text("Label")
    Spacer()
    Text("Value")
        .foregroundStyle(.secondary)
}

// Centered hero content: centered, generous spacing
VStack(alignment: .center, spacing: 16) { ... }

// Icon + text: centered alignment, controlled gap
HStack(alignment: .center, spacing: 8) {
    Image(systemName: "star.fill")
    Text("Favorites")
}
```

**When NOT to configure:** `List` rows, `Form` sections, and `NavigationStack` content manage their own spacing and alignment. Don't override system container defaults.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout)
