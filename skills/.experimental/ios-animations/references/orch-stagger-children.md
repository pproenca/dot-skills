---
title: Stagger Child Elements for Orchestrated Reveals
impact: MEDIUM
impactDescription: staggered cascade feels choreographed; simultaneous reveal feels like a flash
tags: orch, stagger, children, reveal, cascade
---

## Stagger Child Elements for Orchestrated Reveals

When a group of items appears at once — list items after a fetch, grid cells on a tab switch, toolbar buttons on a screen load — animating them all simultaneously creates a flat, uninteresting "flash" of content. Staggering the animations by a small per-item delay (30–50ms) transforms the reveal into a choreographed cascade that feels intentional and premium. The eye naturally follows the cascade, guiding attention through the content in order.

The core pattern is simple: apply a delay of `Double(index) * 0.04` to each item's animation. The critical constraint is capping the total stagger duration. If you have 20 items at 40ms each, the last item appears 800ms after the first — far too slow. Cap the total cascade at ~300ms regardless of item count by dynamically reducing the per-item delay.

**Incorrect (all items appear simultaneously — a flash of content):**

```swift
struct ActivityFeed: View {
    @State private var isVisible = false

    let activities = [
        "Morning run — 5.2 km",
        "Lunch with Sarah",
        "Code review submitted",
        "Yoga class at 6pm",
        "Read 30 pages"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(activities.enumerated()), id: \.offset) { index, activity in
                HStack(spacing: 12) {
                    Circle()
                        .fill(.blue.opacity(0.2))
                        .frame(width: 8, height: 8)
                    Text(activity)
                        .font(.subheadline)
                }
                // All items animate at the same time — looks like a single
                // block popping in, not a curated list of activities
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 10)
            }
        }
        .animation(.smooth, value: isVisible)
        .task {
            try? await Task.sleep(for: .milliseconds(50))
            isVisible = true
        }
    }
}
```

**Correct (staggered cascade — each item enters in sequence):**

```swift
struct ActivityFeed: View {
    @State private var isVisible = false

    let activities = [
        "Morning run — 5.2 km",
        "Lunch with Sarah",
        "Code review submitted",
        "Yoga class at 6pm",
        "Read 30 pages"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(Array(activities.enumerated()), id: \.offset) { index, activity in
                HStack(spacing: 12) {
                    Circle()
                        .fill(.blue.opacity(0.2))
                        .frame(width: 8, height: 8)
                    Text(activity)
                        .font(.subheadline)
                }
                .opacity(isVisible ? 1 : 0)
                .offset(y: isVisible ? 0 : 12)
                // Each item is delayed by 40ms more than the previous.
                // 5 items * 40ms = 200ms total cascade — well under 300ms cap.
                .animation(
                    .smooth(duration: 0.35).delay(Double(index) * 0.04),
                    value: isVisible
                )
            }
        }
        .task {
            try? await Task.sleep(for: .milliseconds(50))
            isVisible = true
        }
    }
}
```

**Capping total stagger for large lists:**

```swift
struct StaggeredGrid: View {
    @State private var isVisible = false

    let items = Array(0..<24)
    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    /// Maximum total cascade duration — prevents long lists from feeling slow
    private let maxCascadeDuration: Double = 0.3
    /// Base per-item delay
    private let baseDelay: Double = 0.04

    private func staggerDelay(for index: Int) -> Double {
        // Dynamic delay: shrinks when item count would exceed max cascade
        let uncappedTotal = Double(items.count) * baseDelay
        let effectiveDelay = uncappedTotal > maxCascadeDuration
            ? maxCascadeDuration / Double(items.count)
            : baseDelay
        return Double(index) * effectiveDelay
    }

    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.blue.gradient)
                        .frame(height: 100)
                        .overlay {
                            Text("\(item)")
                                .font(.headline)
                                .foregroundStyle(.white)
                        }
                        .opacity(isVisible ? 1 : 0)
                        .scaleEffect(isVisible ? 1 : 0.85)
                        .animation(
                            .smooth(duration: 0.35).delay(staggerDelay(for: index)),
                            value: isVisible
                        )
                }
            }
            .padding()
        }
        .task {
            try? await Task.sleep(for: .milliseconds(50))
            isVisible = true
        }
    }
}
```

**Reusable stagger modifier:**

```swift
struct StaggerModifier: ViewModifier {
    let index: Int
    let isVisible: Bool
    let perItemDelay: Double
    let maxTotalDuration: Double
    let itemCount: Int

    private var effectiveDelay: Double {
        let total = Double(itemCount) * perItemDelay
        let capped = total > maxTotalDuration
            ? maxTotalDuration / Double(itemCount)
            : perItemDelay
        return Double(index) * capped
    }

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : 12)
            .animation(
                .smooth(duration: 0.35).delay(effectiveDelay),
                value: isVisible
            )
    }
}

extension View {
    func staggered(
        index: Int,
        isVisible: Bool,
        perItemDelay: Double = 0.04,
        maxTotalDuration: Double = 0.3,
        itemCount: Int
    ) -> some View {
        modifier(StaggerModifier(
            index: index,
            isVisible: isVisible,
            perItemDelay: perItemDelay,
            maxTotalDuration: maxTotalDuration,
            itemCount: itemCount
        ))
    }
}
```

**Stagger timing guidelines:**

| Item count | Per-item delay | Total cascade | Notes |
|-----------|---------------|---------------|-------|
| 3–5 items | 40ms | 120–200ms | Full delay, feels snappy |
| 6–10 items | 30ms | 180–300ms | Slightly compressed |
| 11–20 items | 15–20ms | 165–300ms | Auto-cap kicks in |
| 20+ items | Auto-calculated | 300ms max | Total duration stays fixed |

**Warning:** never stagger items beyond 300ms total. Long cascades make the interface feel slow — the user is waiting for the last item to finish before they can interact. If you have 50 items, the cascade should still complete in 300ms; each item just enters 6ms after the previous.

Reference: Material Design stagger guidelines and Apple's own App Store "Today" card reveals.
