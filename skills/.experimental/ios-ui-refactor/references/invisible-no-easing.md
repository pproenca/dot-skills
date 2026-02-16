---
title: Prefer Springs Over Linear and EaseInOut for UI Elements
impact: HIGH
impactDescription: removes mechanical, robotic feel from all animated transitions and eliminates visible jank when animations are interrupted mid-flight
tags: invisible, motion, easing, rams-5, edson-product, anti-pattern
---

## Prefer Springs Over Linear and EaseInOut for UI Elements

Rams insisted on unobtrusiveness — nothing in nature moves at constant speed (linear) or stops abruptly (easeInOut). These artificial curves make the mechanism visible, violating both Rams' neutrality and Edson's principle that the product should market itself through quality, not through conspicuous effects.

**Incorrect (linear and easeInOut on interactive UI):**

```swift
struct NotificationBadge: View {
    @State private var count = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(.red)
                .frame(width: 24, height: 24)
                // Linear: constant speed looks unnatural
                .scaleEffect(count > 0 ? 1 : 0)
                .animation(.linear(duration: 0.3), value: count)

            Text("\(count)")
                .font(.caption2.bold())
                .foregroundStyle(.white)
        }
    }
}

struct SidebarView: View {
    @State private var isSidebarOpen = false

    var body: some View {
        HStack(spacing: 0) {
            if isSidebarOpen {
                SidebarContent()
                    .frame(width: 280)
                    .transition(.move(edge: .leading))
            }
            MainContent()
        }
        // easeInOut: stutters when toggled rapidly
        .animation(.easeInOut(duration: 0.5), value: isSidebarOpen)
    }
}
```

**Correct (spring presets for natural motion):**

```swift
struct NotificationBadge: View {
    @State private var count = 0

    var body: some View {
        ZStack {
            Circle()
                .fill(.red)
                .frame(width: 24, height: 24)
                // .snappy: quick + slight bounce for interactive feedback
                .scaleEffect(count > 0 ? 1 : 0)
                .animation(.snappy, value: count)

            Text("\(count)")
                .font(.caption2.bold())
                .foregroundStyle(.white)
        }
    }
}

struct SidebarView: View {
    @State private var isSidebarOpen = false

    var body: some View {
        HStack(spacing: 0) {
            if isSidebarOpen {
                SidebarContent()
                    .frame(width: 280)
                    .transition(.move(edge: .leading))
            }
            MainContent()
        }
        // .smooth: calm, no bounce, handles rapid toggles gracefully
        .animation(.smooth, value: isSidebarOpen)
    }
}
```

**When linear or easeInOut IS acceptable:** Progress bars, loading indicators, and continuous rotations (e.g., a spinning refresh icon) where constant speed is the correct visual metaphor. EaseInOut is also fine for timed opacity fades on non-interruptible sequences (toast notifications, auto-dismiss banners). These are not interactive UI transitions.

**Reference:** WWDC 2023 "Animate with springs" — Apple explicitly recommends replacing all easing-curve animations with springs for UI transitions because springs are the only animation model that maintains velocity continuity across interruptions.
