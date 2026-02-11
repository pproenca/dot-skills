---
title: Align Visual Weight with Logical Reading Order
impact: CRITICAL
impactDescription: burying the primary action or key information below the fold causes 30-50% of users to miss it entirely — aligning weight with priority eliminates dead-end screens
tags: hier, reading-order, visual-weight, information-priority, layout, scanning
---

## Align Visual Weight with Logical Reading Order

Users scan iOS screens in an F-pattern: top-left to right, then down the left edge. When the most important element is buried in the middle or below the fold, users miss it — no amount of color or animation compensates for wrong placement. A principal designer maps information priority to vertical position and visual weight: the most critical content sits highest and heaviest, calls to action appear where the eye naturally arrives after scanning.

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
                    // POSITION 2: Name + rating — primary identity
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Osteria Francescana")
                            .font(.title2)
                            .fontWeight(.bold)

                        HStack(spacing: 4) {
                            Text("4.8 ★")
                                .fontWeight(.medium)
                            Text("(2,340 reviews)")
                                .foregroundStyle(.secondary)
                        }
                        .font(.subheadline)
                    }

                    // POSITION 3: Key decision factors
                    HStack(spacing: 12) {
                        Label("Italian", systemImage: "fork.knife")
                        Label("$$", systemImage: "dollarsign.circle")
                        Label("Open until 10 PM", systemImage: "clock")
                    }
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                    // POSITION 4: Primary action — where the eye arrives
                    Button {
                        // reserve action
                    } label: {
                        Text("Reserve a Table")
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)

                    // POSITION 5: Supporting detail (scrollable)
                    Label("Via Stella 22, Modena", systemImage: "mappin")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
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

**When NOT to use top-heavy layout:**
- Content-browsing screens (Photos, Instagram) where the content itself is the primary element — here, content fills the viewport edge-to-edge with minimal chrome
- Search-first screens (Maps, Spotlight) where the input field correctly dominates

Reference: [Layout - Human Interface Guidelines](https://developer.apple.com/design/human-interface-guidelines/layout), [WWDC23 — Design with SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10115/)
