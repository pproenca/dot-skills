---
title: Match Duration to Distance Traveled
impact: MEDIUM-HIGH
impactDescription: short-distance animations at long durations look slow-motion; long-distance at short durations look teleported
tags: feel, distance, duration, proportional
---

## Match Duration to Distance Traveled

A button scale effect (tiny distance) needs 150ms. A sheet sliding up the full screen needs 400ms. Duration should scale with distance traveled — this mirrors physical reality where heavier, farther-moving objects take longer to settle. When you apply the same 300ms to a 10pt button press scale and an 800pt full-screen sheet slide, the button feels sluggish and the sheet feels teleported. The brain expects proportionality.

**Incorrect (same 300ms for a button press and a full-screen slide):**

```swift
struct ProductView: View {
    @State private var isPressed = false
    @State private var showDetail = false

    var body: some View {
        VStack {
            // Button: 10pt of travel (scale 1.0 -> 0.95)
            Button {
                showDetail = true
            } label: {
                Text("View Details")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(.blue, in: Capsule())
                    .foregroundStyle(.white)
            }
            // 300ms for 10pt scale change — feels like slow motion
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.smooth(duration: 0.3), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
        }
        .fullScreenCover(isPresented: $showDetail) {
            DetailSheet()
                // 300ms for 800pt slide — feels like teleportation
                .transition(.move(edge: .bottom))
                .animation(.smooth(duration: 0.3), value: showDetail)
        }
    }
}
```

**Correct (duration proportional to travel distance):**

```swift
struct ProductView: View {
    @State private var isPressed = false
    @State private var showDetail = false

    var body: some View {
        VStack {
            Button {
                showDetail = true
            } label: {
                Text("View Details")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(.blue, in: Capsule())
                    .foregroundStyle(.white)
            }
            // 10pt scale: 150ms — snappy, proportional to tiny distance
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.snappy(duration: 0.15), value: isPressed)
            .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
                isPressed = pressing
            }, perform: {})
        }
        .fullScreenCover(isPresented: $showDetail) {
            DetailSheet()
                // 800pt slide: 400ms — gives the eye time to track the motion
                .transition(.move(edge: .bottom))
                .animation(.smooth(duration: 0.4), value: showDetail)
        }
    }
}
```

**Incorrect (expanding card with disproportionate timing):**

```swift
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.gradient)
                // Expands 180pt (120 -> 300) at same speed as
                // the chevron rotating 180 degrees (tiny visual distance)
                .frame(height: isExpanded ? 300 : 120)
                .animation(.spring(duration: 0.25), value: isExpanded)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        // Chevron rotation is tiny — same duration feels laggy
                        .animation(.spring(duration: 0.25), value: isExpanded)
                        .padding()
                }
                .onTapGesture { isExpanded.toggle() }
        }
        .padding()
    }
}
```

**Correct (proportional timing for different travel distances):**

```swift
struct ExpandableCard: View {
    @State private var isExpanded = false

    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 16)
                .fill(.blue.gradient)
                // 180pt height expansion: 300ms
                .frame(height: isExpanded ? 300 : 120)
                .animation(.spring(duration: 0.3, bounce: 0.1), value: isExpanded)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "chevron.down")
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        // Chevron flip is small: 150ms, snappy
                        .animation(.snappy(duration: 0.15), value: isExpanded)
                        .padding()
                }
                .onTapGesture { isExpanded.toggle() }
        }
        .padding()
    }
}
```

**Duration-to-distance heuristic (~1ms per point of travel):**

| Motion | Approximate Distance | Recommended Duration |
|---|---|---|
| Button scale (1.0 to 0.95) | ~5-10pt | 100-150ms |
| Icon rotation (180 degrees) | ~20pt visual arc | 150ms |
| Chevron flip | ~15pt | 150ms |
| Card expand (120pt to 300pt) | ~180pt | 250-300ms |
| Half-sheet slide | ~400pt | 300-350ms |
| Full-sheet slide | ~800pt | 400ms |
| Full-screen morph | ~900pt | 400-500ms |

**The ~1ms per point rule is a starting heuristic, not a formula.** It breaks down at extremes — a 2pt opacity fade should not take 2ms (imperceptible), and a 2000pt scroll animation should not take 2 seconds (painfully slow). Below 100ms, round up to 100ms. Above 500ms, cap at 500ms unless the animation is cinematic.

**Reference:** Material Design documents this principle as "duration is determined by the distance an element travels" with similar proportional scaling. Apple's native animations follow this pattern — NavigationStack push (~350pt) uses ~350ms, while sheet presentation (~800pt) uses ~400ms.
