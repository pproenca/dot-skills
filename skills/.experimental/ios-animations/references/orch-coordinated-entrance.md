---
title: Coordinate Multi-Element Entrances with Shared Trigger
impact: MEDIUM
impactDescription: independently triggered elements race and jitter — a shared trigger synchronizes the choreography
tags: orch, coordinated, entrance, trigger, synchronized
---

## Coordinate Multi-Element Entrances with Shared Trigger

When a screen appears with multiple animated elements — a header image, title text, action cards, and a floating action button — each element needs to animate in as part of a cohesive sequence. The temptation is to give each element its own `.onAppear` trigger, but this creates timing races: SwiftUI does not guarantee the order in which nested `.onAppear` closures fire. The header might animate before its parent lays out, causing it to fly in from the wrong position. The FAB might jitter because its anchor point is not yet resolved.

The solution is a single shared state variable — `@State var isVisible = false` — that drives all entrance animations. Each element reads this one boolean but applies different delays and animation curves. This guarantees every animation starts from the same moment and the choreography is deterministic.

**Incorrect (each element triggers independently — timing races):**

```swift
struct ProfileScreen: View {
    @State private var showHeader = false
    @State private var showCards = false
    @State private var showFAB = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    // Header triggers on its own onAppear
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                        .scaleEffect(showHeader ? 1 : 0.5)
                        .opacity(showHeader ? 1 : 0)
                        .onAppear {
                            withAnimation(.spring(duration: 0.4, bounce: 0.2)) {
                                showHeader = true
                            }
                        }

                    Text("Sarah Chen")
                        .font(.title.bold())

                    // Cards trigger on their own onAppear — might fire
                    // before or after header, causing jittery reveals
                    VStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.opacity(0.1))
                                .frame(height: 80)
                                .opacity(showCards ? 1 : 0)
                                .onAppear {
                                    withAnimation(.smooth.delay(Double(index) * 0.1)) {
                                        showCards = true
                                    }
                                }
                        }
                    }
                }
                .padding()
            }

            // FAB triggers independently — might appear before cards
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.blue, in: Circle())
            }
            .padding(24)
            .scaleEffect(showFAB ? 1 : 0)
            .onAppear {
                withAnimation(.spring(duration: 0.3, bounce: 0.3).delay(0.4)) {
                    showFAB = true
                }
            }
        }
    }
}
```

**Correct (single shared trigger drives all elements with coordinated delays):**

```swift
struct ProfileScreen: View {
    // One trigger to rule them all
    @State private var isVisible = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            ScrollView {
                VStack(spacing: 20) {
                    // Header: appears first, spring with slight bounce
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(.blue)
                        .scaleEffect(isVisible ? 1 : 0.5)
                        .opacity(isVisible ? 1 : 0)
                        .animation(
                            .spring(duration: 0.4, bounce: 0.2),
                            value: isVisible
                        )

                    // Title: appears 50ms after header
                    Text("Sarah Chen")
                        .font(.title.bold())
                        .opacity(isVisible ? 1 : 0)
                        .offset(y: isVisible ? 0 : 8)
                        .animation(
                            .smooth(duration: 0.35).delay(0.05),
                            value: isVisible
                        )

                    // Cards: staggered cascade starting 100ms after trigger
                    VStack(spacing: 12) {
                        ForEach(0..<3, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 12)
                                .fill(.blue.opacity(0.1))
                                .frame(height: 80)
                                .overlay {
                                    Text("Activity \(index + 1)")
                                        .font(.subheadline)
                                }
                                .opacity(isVisible ? 1 : 0)
                                .offset(y: isVisible ? 0 : 12)
                                .animation(
                                    .smooth(duration: 0.35)
                                        .delay(0.1 + Double(index) * 0.04),
                                    value: isVisible
                                )
                        }
                    }
                }
                .padding()
            }

            // FAB: appears last, with a playful bounce
            Button(action: {}) {
                Image(systemName: "plus")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                    .frame(width: 56, height: 56)
                    .background(.blue, in: Circle())
                    .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
            }
            .padding(24)
            .scaleEffect(isVisible ? 1 : 0)
            .animation(
                .spring(duration: 0.4, bounce: 0.3).delay(0.25),
                value: isVisible
            )
        }
        // Single trigger fires after layout resolves.
        // The 50ms sleep ensures the view tree is fully laid out before animating,
        // preventing "fly in from origin" artifacts.
        .task {
            try? await Task.sleep(for: .milliseconds(50))
            isVisible = true
        }
    }
}
```

**Why `.task` with a short sleep instead of `.onAppear`:**

```swift
// .onAppear fires before layout is complete. Animations that depend on
// final position (offset, matchedGeometry) can start from wrong origins.

// BAD: .onAppear — layout may not be resolved
.onAppear { isVisible = true }

// GOOD: .task with minimal sleep — layout resolves during the sleep
.task {
    try? await Task.sleep(for: .milliseconds(50))
    isVisible = true
}

// ALSO GOOD: .task with zero sleep (still yields to layout)
.task {
    await Task.yield()
    isVisible = true
}
```

**Coordinated entrance timing template:**

| Element | Delay from trigger | Animation | Notes |
|---------|-------------------|-----------|-------|
| Hero/header | 0ms | `.spring(duration: 0.4, bounce: 0.2)` | First thing the eye sees |
| Title/subtitle | 50ms | `.smooth(duration: 0.35)` | Follows hero naturally |
| Content cards | 100ms + stagger | `.smooth(duration: 0.35)` | Cascade at 40ms per item |
| Secondary actions | 200ms | `.smooth(duration: 0.3)` | After primary content settles |
| FAB / CTA | 250ms | `.spring(duration: 0.4, bounce: 0.3)` | Last, with a bounce for emphasis |

**Key principle:** the total entrance choreography should complete within 400ms. Anything longer and the user feels like they are watching a slideshow instead of using an app.
