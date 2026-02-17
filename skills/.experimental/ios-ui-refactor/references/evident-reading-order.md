---
title: Align Visual Weight with Logical Reading Order
impact: CRITICAL
impactDescription: burying the primary action or key information below the fold causes a large share of users to miss it entirely — aligning weight with priority eliminates dead-end screens
tags: evident, reading-order, visual-weight, rams-4, segall-human, layout
---

## Align Visual Weight with Logical Reading Order

You open a restaurant page and the first thing you see is a pair of grey capsules — "Italian" and "$$" — followed by the opening hours. Somewhere below all that decorative metadata, the restaurant's actual name finally appears. The frustration is immediate: your eye went where the layout told it to go, but the layout lied about what was important. Good visual structure is honest. It places the heaviest weight on the thing users came to find, then walks them naturally through supporting detail — top-left to right, then down — so the eye never has to hunt. When position and priority agree, the screen reads like a story told in the right order.

**Incorrect (key action buried, secondary info dominates the top):**

```swift
struct RestaurantDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                // Decorative info dominates prime real estate
                HStack {
                    Text("Italian")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.gray.opacity(0.2))
                        .clipShape(Capsule())
                    Text("$$")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(.gray.opacity(0.2))
                        .clipShape(Capsule())
                }

                Text("Open until 10 PM")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                // Restaurant name — the primary identifier — is third
                Text("Osteria Francescana")
                    .font(.title2.bold())

                Text("4.8 ★ (2,340 reviews)")

                // Photo buried below text
                Image("restaurant-hero")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 200)
                    .clipped()

                // Primary action at the very bottom
                Text("Via Stella 22, Modena")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("Reserve a Table") { }
                    .buttonStyle(.borderedProminent)
            }
            .padding()
        }
    }
}
```

**Correct (visual weight matches information priority):**

```swift
struct RestaurantDetailView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                // POSITION 1: Hero image — instant recognition
                Image("restaurant-hero")
                    .resizable()
                    .scaledToFill()
                    .frame(height: 260)
                    .clipped()

                VStack(alignment: .leading, spacing: 20) {
                    // POSITION 2: Name + rating
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Osteria Francescana")
                            .font(.title2.weight(.bold))
                        HStack(spacing: 4) {
                            Text("4.8 ★").fontWeight(.medium)
                            Text("(2,340 reviews)").foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }

                    // POSITION 3: Key decision factors
                    HStack(spacing: 12) {
                        Label("Italian", systemImage: "fork.knife")
                        Label("$$", systemImage: "dollarsign.circle")
                        Label("Open until 10 PM", systemImage: "clock")
                    }
                    .font(.subheadline).foregroundStyle(.secondary)

                    // POSITION 4: Primary action
                    Button("Reserve a Table") { }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                        .frame(maxWidth: .infinity)

                    // POSITION 5: Supporting detail
                    Label("Via Stella 22, Modena", systemImage: "mappin")
                        .font(.subheadline).foregroundStyle(.secondary)
                }
                .padding()
            }
        }
    }
}
```

**Priority-to-position mapping:**

```swift
// Position 1 (top):     Hero visual or primary identifier
// Position 2:           Title + key metric (name, rating, price)
// Position 3:           Decision-support metadata (category, hours, distance)
// Position 4:           Primary call to action
// Position 5+ (scroll): Supporting details, secondary actions
//
// Rule: if users need information to make a decision,
// it must appear BEFORE the call to action.

// For sticky actions that must always be reachable:
.safeAreaInset(edge: .bottom) {
    Button("Reserve a Table") { }
        .buttonStyle(.borderedProminent)
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
}
```

**When NOT to apply:** Content-browsing screens (Photos, Instagram) where the content itself is the primary element and fills the viewport edge-to-edge with minimal chrome, and search-first screens (Maps, Spotlight) where the input field correctly dominates.

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout), [WWDC23 — Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10115/)
