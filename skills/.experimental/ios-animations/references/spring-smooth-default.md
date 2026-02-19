---
title: Default to .smooth Spring for All UI Transitions
impact: CRITICAL
impactDescription: eliminates 100% of velocity discontinuities when users interrupt animations mid-flight
tags: spring, smooth, default, interruptible
---

## Default to .smooth Spring for All UI Transitions

Springs became the SwiftUI default animation in iOS 26. Among the three presets — `.smooth`, `.snappy`, and `.bouncy` — `.smooth` is the right choice for roughly 80% of UI transitions. It produces zero bounce and a natural, physics-based deceleration that feels like sliding a real object to a stop. Most importantly, springs retarget smoothly: if a user taps mid-animation, the spring redirects to the new target while preserving the current velocity. Easing curves cannot do this — they restart from zero velocity, causing a visible stutter.

**Incorrect (easing curve stutters when tapped mid-flight):**

```swift
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Order #1042")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }

            if isExpanded {
                Text("2x Espresso, 1x Croissant")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Pickup at 10:30 AM")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.background, in: RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        // easeInOut: rapid taps cause visible stuttering because each
        // new animation restarts from zero velocity
        .animation(.easeInOut(duration: 0.3), value: isExpanded)
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}
```

**Correct (.smooth spring retargets smoothly on interruption):**

```swift
@Equatable
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: Spacing.sm) {
            HStack {
                Text("Order #1042")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.down")
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }

            if isExpanded {
                Text("2x Espresso, 1x Croissant")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text("Pickup at 10:30 AM")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(Spacing.md)
        .background(.background, in: RoundedRectangle(cornerRadius: Radius.md))
        .shadow(color: .black.opacity(0.08), radius: 4, y: 2)
        // .smooth: no bounce, natural deceleration, handles rapid taps gracefully
        // (equivalent to Motion.standard)
        .animation(.smooth, value: isExpanded)
        .onTapGesture {
            isExpanded.toggle()
        }
    }
}
```

**Key insight — bare `withAnimation` already uses springs on iOS 26 / Swift 6.2:**

```swift
// These two are equivalent on iOS 26 / Swift 6.2:
withAnimation {
    isExpanded.toggle()
}

withAnimation(.smooth) {
    isExpanded.toggle()
}

// So removing an explicit easing curve is often the entire fix:
// Before:
withAnimation(.easeInOut(duration: 0.3)) { isExpanded.toggle() }
// After:
withAnimation { isExpanded.toggle() }
```

**When to reach for something other than `.smooth`:**

| Preset | Use when |
|--------|----------|
| `.smooth` | General UI transitions — expand/collapse, show/hide, layout changes |
| `.snappy` | High-frequency interactive controls — toggles, tabs, checkboxes |
| `.bouncy` | Celebratory or playful moments — success states, achievements |

**Benefits:**
- Rapid taps no longer stutter — each tap smoothly redirects the in-flight animation
- Gesture releases feel natural because the spring preserves finger velocity
- No arbitrary duration values to tune — the spring settles based on physics

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
