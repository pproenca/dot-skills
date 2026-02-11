---
title: Never Use linear or easeInOut for Interactive UI
impact: CRITICAL
impactDescription: linear/easeInOut cause abrupt stops that feel mechanical — springs decelerate naturally
tags: spring, linear, easeInOut, anti-pattern
---

## Never Use linear or easeInOut for Interactive UI

`.linear` moves at constant speed and stops dead — nothing in the physical world does this. `.easeInOut` is better but decelerates to a hard stop with a sudden change in acceleration, and critically, it cannot handle interruption (the next animation restarts from zero velocity). Springs decelerate asymptotically like real objects, and they preserve velocity when interrupted. For any UI element the user can interact with, linear and easeInOut are anti-patterns.

**Incorrect (.linear on an interactive sidebar feels robotic):**

```swift
struct AppShell: View {
    @State private var isSidebarOpen = false

    var body: some View {
        ZStack(alignment: .leading) {
            // Main content
            VStack {
                HStack {
                    Button {
                        // .linear: constant speed + dead stop makes the sidebar
                        // feel like it's on a motorized rail, not a physical object
                        withAnimation(.linear(duration: 0.3)) {
                            isSidebarOpen.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                    }
                    Spacer()
                    Text("Inbox")
                        .font(.headline)
                    Spacer()
                }
                .padding()

                Spacer()
            }
            .offset(x: isSidebarOpen ? 280 : 0)

            // Sidebar
            if isSidebarOpen {
                VStack(alignment: .leading, spacing: 24) {
                    Label("Inbox", systemImage: "tray")
                    Label("Starred", systemImage: "star")
                    Label("Sent", systemImage: "paperplane")
                    Label("Drafts", systemImage: "doc")
                    Label("Trash", systemImage: "trash")
                }
                .font(.body)
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .frame(width: 280, alignment: .leading)
                .background(.ultraThinMaterial)
                .transition(.move(edge: .leading))
            }
        }
    }
}
```

**Correct (.smooth on the sidebar feels physical and interruptible):**

```swift
struct AppShell: View {
    @State private var isSidebarOpen = false

    var body: some View {
        ZStack(alignment: .leading) {
            VStack {
                HStack {
                    Button {
                        // .smooth: decelerates naturally, handles rapid toggles
                        // gracefully — each tap smoothly redirects the sidebar
                        withAnimation(.smooth) {
                            isSidebarOpen.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal")
                            .font(.title2)
                    }
                    Spacer()
                    Text("Inbox")
                        .font(.headline)
                    Spacer()
                }
                .padding()

                Spacer()
            }
            .offset(x: isSidebarOpen ? 280 : 0)

            if isSidebarOpen {
                VStack(alignment: .leading, spacing: 24) {
                    Label("Inbox", systemImage: "tray")
                    Label("Starred", systemImage: "star")
                    Label("Sent", systemImage: "paperplane")
                    Label("Drafts", systemImage: "doc")
                    Label("Trash", systemImage: "trash")
                }
                .font(.body)
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .frame(width: 280, alignment: .leading)
                .background(.ultraThinMaterial)
                .transition(.move(edge: .leading))
            }
        }
    }
}
```

**Why `.linear` and `.easeInOut` fail — the deceleration profile:**

```text
.linear:
  Speed: ████████████████████████████  ← constant
  Stops: ████████████████████████████| ← dead stop (velocity → 0 instantly)
  Feels: robotic, mechanical

.easeInOut:
  Speed: ▁▃▅▇████████████████████▇▅▃▁ ← smooth curve
  Stops: ▁▃▅▇████████████████████▇▅▃▁| ← abrupt deceleration change at end
  Feels: acceptable alone, breaks on interruption

.smooth (spring):
  Speed: ▇▇▆▅▅▄▄▃▃▃▂▂▂▂▁▁▁▁▁▁▁▁▁▁▁▁ ← exponential decay
  Stops: never truly stops, asymptotically approaches target
  Feels: natural, physical, handles interruption
```

**The exception — when `.linear` IS acceptable:**

```swift
struct LoadingSpinner: View {
    @State private var rotation: Double = 0

    var body: some View {
        Image(systemName: "arrow.trianglehead.2.counterclockwise")
            .font(.title)
            .rotationEffect(.degrees(rotation))
            .onAppear {
                // Continuous looping animation: .linear is correct here
                // because constant speed IS the desired behavior for a spinner.
                // There is no start/stop interaction to interrupt.
                withAnimation(
                    .linear(duration: 1.0)
                    .repeatForever(autoreverses: false)
                ) {
                    rotation = 360
                }
            }
    }
}

struct DownloadProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            RoundedRectangle(cornerRadius: 4)
                .fill(.blue)
                .frame(width: geometry.size.width * progress)
        }
        .frame(height: 8)
        .background(.blue.opacity(0.15), in: RoundedRectangle(cornerRadius: 4))
        // Progress bars track a continuously changing value —
        // .linear matches the data-driven metaphor
        .animation(.linear(duration: 0.2), value: progress)
    }
}
```

**Quick decision guide:**

| Question | Yes → | No → |
|----------|-------|------|
| Can the user interrupt this animation? | Spring | Maybe linear |
| Does the animation loop continuously? | Linear is OK | Spring |
| Is this a progress/loading indicator? | Linear is OK | Spring |
| Does the animation have a start and end triggered by user action? | Spring | Evaluate case |

**Benefits of eliminating linear/easeInOut from interactive UI:**
- Every animation handles interruption correctly — no velocity jank
- Consistent motion language across the app — everything moves like a physical object
- No arbitrary duration values to tune and maintain
- Matches Apple's own apps, which use springs exclusively for interactive elements

Reference: [WWDC 2023 — Animate with springs](https://developer.apple.com/wwdc23/10158)
