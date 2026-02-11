---
title: Use .bouncy Spring for Playful and Celebratory Moments
impact: HIGH
impactDescription: adds perceived delight without increasing animation duration
tags: spring, bouncy, celebration, delight, overshoot
---

## Use .bouncy Spring for Playful and Celebratory Moments

`.bouncy` has a `dampingFraction` of 0.7, which means visible overshoot — the element goes past its target and settles back. This creates a "pop" effect that adds delight to moments of success, achievement, or fun. However, overshoot on navigation, layout shifts, or frequent interactions feels chaotic and disorienting. Reserve `.bouncy` for moments where the user expects something celebratory or playful.

**Incorrect (.bouncy on a navigation push feels chaotic):**

```swift
struct ProductListView: View {
    let products: [Product]
    @State private var selectedProduct: Product?
    @State private var showDetail = false

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 16) {
                ForEach(products) { product in
                    ProductRow(product: product)
                        .onTapGesture {
                            selectedProduct = product
                            // .bouncy on navigation feels unstable — the detail view
                            // overshoots its position and bounces back, making users
                            // feel like the UI is broken
                            withAnimation(.bouncy) {
                                showDetail = true
                            }
                        }
                }
            }
        }
        .overlay {
            if showDetail, let product = selectedProduct {
                ProductDetailView(product: product)
                    .transition(.move(edge: .trailing))
            }
        }
    }
}
```

**Correct (.bouncy on a success checkmark feels celebratory):**

```swift
struct TaskCompletionView: View {
    @State private var isComplete = false

    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(.green.opacity(0.15))
                    .frame(width: 80, height: 80)
                    .scaleEffect(isComplete ? 1 : 0)

                Image(systemName: "checkmark")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundStyle(.green)
                    .scaleEffect(isComplete ? 1 : 0)
            }
            // .bouncy: the checkmark pops past full size and settles back,
            // creating a satisfying "done!" moment
            .animation(.bouncy, value: isComplete)

            Text(isComplete ? "Task Complete!" : "Working...")
                .font(.title2.bold())
                .contentTransition(.numericText())

            Button("Mark Complete") {
                isComplete = true
            }
            .buttonStyle(.borderedProminent)
            .disabled(isComplete)
        }
    }
}
```

**When NOT to use `.bouncy`:**

| Scenario | Why not | Use instead |
|----------|---------|-------------|
| Navigation transitions | Overshoot makes destination feel unstable | `.smooth` |
| Sidebar / sheet reveal | Bouncing layout shift is disorienting | `.smooth` |
| Toggle state changes | Frequent use makes bounce annoying | `.snappy` |
| Text or number changes | Content bouncing is hard to read | `.smooth` |
| Form field validation | Error indicators shouldn't "play" | `.snappy` |

**When `.bouncy` IS the right choice:**

```swift
struct AchievementBadge: View {
    let achievement: Achievement
    @State private var hasAppeared = false

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.iconName)
                .font(.system(size: 44))
                .foregroundStyle(.yellow)
                .scaleEffect(hasAppeared ? 1 : 0.3)
                .opacity(hasAppeared ? 1 : 0)
                // Achievement unlock — this is a celebratory moment
                .animation(.bouncy, value: hasAppeared)

            Text(achievement.title)
                .font(.headline)
                .opacity(hasAppeared ? 1 : 0)
                .animation(.smooth.delay(0.15), value: hasAppeared)

            Text(achievement.description)
                .font(.caption)
                .foregroundStyle(.secondary)
                .opacity(hasAppeared ? 1 : 0)
                .animation(.smooth.delay(0.25), value: hasAppeared)
        }
        .onAppear {
            hasAppeared = true
        }
    }
}
```

**Tuning the bounce amount:**

```swift
// Default .bouncy: dampingFraction 0.7 — visible but not wild
.animation(.bouncy, value: trigger)

// Extra bounce for very playful UI (games, celebrations):
.animation(.bouncy(extraBounce: 0.15), value: trigger)

// Subtle bounce for understated delight:
.animation(.bouncy(extraBounce: -0.1), value: trigger)

// The extraBounce parameter adjusts dampingFraction:
// .bouncy                    → dampingFraction ~0.7
// .bouncy(extraBounce: 0.15) → dampingFraction ~0.55 (more bounce)
```

**Rule of thumb:** if the animation accompanies a moment the user would smile about, `.bouncy` is appropriate. If it accompanies a structural change (navigation, layout), use `.smooth`.

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
