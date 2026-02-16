---
title: Use TimelineView for Continuous Repeating Animations
impact: LOW-MEDIUM
impactDescription: TimelineView syncs to display refresh (60/120Hz) with zero Timer overhead — prevents animation queue buildup and dropped frames from misaligned 30fps Timer.publish calls
tags: orch, timelineView, continuous, repeating, displayLink
---

## Use TimelineView for Continuous Repeating Animations

Some animations need to run indefinitely at the display refresh rate: audio visualizers, live activity indicators, particle effects, gradient shifts, or clock displays. The imperative approach — `Timer.publish(every:)` combined with `.onReceive` — creates a new `Timer` that fires independently of the display refresh rate, pushes updates through Combine, and triggers a full view re-evaluation each tick. This misses frames when the timer interval does not align with vsync, leaks if not properly cancelled, and queues up animation transactions that SwiftUI must resolve.

`TimelineView` (iOS 15+) is purpose-built for this. It refreshes its content in sync with the display link, provides the current `Date` for phase calculations, and pauses automatically when the view is not visible. The `.animation` schedule runs at the display refresh rate (~60Hz or ~120Hz on ProMotion). For lower-frequency updates, `.periodic(from:by:)` lets you specify an interval.

**Incorrect (Timer.publish + @State — misses frames, leaks, queues animations):**

```swift
struct AudioVisualizer: View {
    @State private var levels: [CGFloat] = Array(repeating: 0.3, count: 8)

    let timer = Timer.publish(every: 1.0 / 30.0, on: .main, in: .common).autoconnect()

    var body: some View {
        HStack(alignment: .bottom, spacing: Spacing.xs) {
            ForEach(0..<8, id: \.self) { index in
                RoundedRectangle(cornerRadius: 2)
                    .fill(.blue.gradient)
                    .frame(width: 6, height: 40 * levels[index])
                    // Each timer tick queues a new animation transaction.
                    // At 30fps that is 30 animations/sec stacking up —
                    // SwiftUI's animation system was not designed for this.
                    .animation(.linear(duration: 0.05), value: levels[index])
            }
        }
        .frame(height: 40)
        .onReceive(timer) { _ in
            for i in 0..<levels.count {
                levels[i] = CGFloat.random(in: 0.15...1.0)
            }
        }
        // Timer continues firing even when view is off-screen.
        // Must manually handle cancellation on disappear.
    }
}
```

**Correct (TimelineView — synced to display, auto-pauses when off-screen):**

```swift
@Equatable
struct AudioVisualizer: View {
    var body: some View {
        // .animation schedule: refreshes at the display refresh rate,
        // pauses automatically when the view is not visible
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            HStack(alignment: .bottom, spacing: Spacing.xs) {
                ForEach(0..<8, id: \.self) { index in
                    let phase = time * 3 + Double(index) * 0.4
                    let height = 0.3 + 0.7 * abs(sin(phase))

                    RoundedRectangle(cornerRadius: 2)
                        .fill(.blue.gradient)
                        .frame(width: 6, height: 40 * height)
                }
            }
            .frame(height: 40)
        }
    }
}
```

**Pulsing ring indicator (live activity style):**

```swift
@Equatable
struct LiveIndicator: View {
    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate
            let pulse = sin(time * 2) * 0.5 + 0.5 // 0...1 oscillation

            ZStack {
                Circle()
                    .fill(.red.opacity(0.2))
                    .frame(width: 24 + pulse * 8, height: 24 + pulse * 8)

                Circle()
                    .fill(.red)
                    .frame(width: 10, height: 10)
            }
        }
    }
}
```

**Gradient shift animation (background ambiance):**

```swift
@Equatable
struct AnimatedGradientBackground: View {
    var body: some View {
        TimelineView(.animation) { context in
            let time = context.date.timeIntervalSinceReferenceDate

            MeshGradient(
                width: 3, height: 3,
                points: [
                    [0, 0], [0.5, 0], [1, 0],
                    [0, 0.5],
                    [
                        Float(0.5 + 0.2 * sin(time * 0.8)),
                        Float(0.5 + 0.2 * cos(time * 0.6))
                    ],
                    [1, 0.5],
                    [0, 1], [0.5, 1], [1, 1]
                ],
                colors: [
                    .blue, .purple, .indigo,
                    .cyan, .mint, .purple,
                    .blue, .indigo, .cyan
                ]
            )
            .ignoresSafeArea()
        }
    }
}
```

**Lower-frequency updates with `.periodic`:**

```swift
@Equatable
struct ClockView: View {
    var body: some View {
        // Update once per second — no need for 60fps for a clock
        TimelineView(.periodic(from: .now, by: 1.0)) { context in
            Text(context.date, style: .time)
                .font(.system(size: 48, weight: .light, design: .rounded))
                .monospacedDigit()
                .contentTransition(.numericText())
        }
    }
}
```

**TimelineView schedules:**

| Schedule | Refresh rate | Use for |
|----------|-------------|---------|
| `.animation` | Display refresh (60/120Hz) | Smooth visual effects, particles |
| `.periodic(from:by:)` | Custom interval | Clocks, countdowns, data polling |
| `.everyMinute` | Once per minute | Dashboard timestamps |

**Warning:** do not use `TimelineView(.animation)` for one-shot animations. It runs continuously and consumes GPU cycles every frame. For animations that have a defined start and end, use `.animation()`, `PhaseAnimator`, or `KeyframeAnimator` — these complete and stop consuming resources.

**Performance note:** inside a `TimelineView(.animation)` closure, avoid expensive calculations. The closure runs every frame. Pre-compute lookup tables for `sin`/`cos` if you have many elements, and keep the view hierarchy inside the closure as shallow as possible.

Reference: [WWDC 2021 — Discover concurrency in SwiftUI](https://developer.apple.com/wwdc21/10019) and [WWDC 2023 — Explore SwiftUI animation](https://developer.apple.com/wwdc23/10156)
