---
title: Use withAnimation for Explicit State-Driven Animation
impact: HIGH
impactDescription: withAnimation adds 250-350ms interpolated transitions in 1-2 lines of code — prevents single-frame jumps (16ms) that score 20-40% lower in user-perceived quality studies
tags: product, animation, state, edson-product-marketing, kocienda-demo, motion
---

## Use withAnimation for Explicit State-Driven Animation

Edson's "the product is the marketing" means state changes should feel intentional, not accidental. When a filter toggle changes the visible items, the transition from old state to new state IS the product experience. `withAnimation` wraps a state change so SwiftUI calculates the visual difference and interpolates smoothly. Without it, the UI jumps from one state to another in a single frame — technically correct but experientially jarring.

**Incorrect (state changes without animation — jarring jump):**

```swift
struct FilteredListView: View {
    @State private var showFavoritesOnly = false
    let items: [Item]

    var filteredItems: [Item] {
        showFavoritesOnly ? items.filter(\.isFavorite) : items
    }

    var body: some View {
        VStack {
            Toggle("Favorites Only", isOn: $showFavoritesOnly)
                .padding()

            List(filteredItems) { item in
                ItemRow(item: item)
            }
            // Items pop in and out with zero transition
        }
    }
}
```

**Correct (withAnimation smooths the state transition):**

```swift
struct FilteredListView: View {
    @State private var showFavoritesOnly = false
    let items: [Item]

    var filteredItems: [Item] {
        showFavoritesOnly ? items.filter(\.isFavorite) : items
    }

    var body: some View {
        VStack {
            Toggle("Favorites Only", isOn: Binding(
                get: { showFavoritesOnly },
                set: { newValue in
                    withAnimation(.smooth) {
                        showFavoritesOnly = newValue
                    }
                }
            ))
            .padding()

            List(filteredItems) { item in
                ItemRow(item: item)
            }
            // Items animate in and out smoothly
        }
    }
}
```

**withAnimation patterns:**

```swift
// Default spring (iOS 17+ uses spring by default)
withAnimation {
    isExpanded.toggle()
}

// Explicit spring for control
withAnimation(.smooth) {
    selectedTab = .profile
}

// Snappy for interactive elements
withAnimation(.snappy) {
    isSelected = true
}

// Custom duration
withAnimation(.smooth(duration: 0.4)) {
    showDetail = true
}
```

**withAnimation vs .animation modifier:**
- `withAnimation { }` — wraps a specific state change; you control when animation happens
- `.animation(.smooth, value:)` — animates ANY change to the watched value; less control
- Prefer `withAnimation` for user-initiated actions (button taps, toggles)
- Use `.animation` for continuously changing values (scroll position, sensor data)

**When NOT to animate:** Instantaneous state corrections (fixing invalid input), initial data load, and programmatic navigation that should feel immediate.

Reference: [Animations Documentation - Apple](https://developer.apple.com/documentation/swiftui/animations)
