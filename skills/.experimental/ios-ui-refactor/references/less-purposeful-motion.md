---
title: Every Animation Must Communicate State Change or Provide Feedback
impact: HIGH
impactDescription: removes gratuitous motion that adds cognitive load without purpose, reduces distraction, and focuses user attention on meaningful state transitions
tags: less, motion, rams-10, segall-minimal, design-intent
---

## Every Animation Must Communicate State Change or Provide Feedback

Gratuitous motion is the visual equivalent of background music you did not choose — it fills the space without serving the listener. A logo that bounces on every app launch, cards that slide in from the sides, a parallax background that drifts as you scroll — these animations train the user's brain to ignore motion entirely. And once motion has been devalued, the *important* animations — the badge that appears to say "you have a message," the item that slides away to confirm deletion — get lost in the noise. Animation is communication: every moving element should answer one of three questions — "What changed?" (state transition), "Where should I look?" (attention direction), or "Did my action work?" (feedback confirmation). If an animation cannot answer any of these, it is not adding polish — it is adding clutter, and the user's subconscious registers the difference.

**Incorrect (decorative animations that serve no functional purpose):**

```swift
struct HomeView: View {
    @State private var appeared = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Gratuitous: logo bounces on every app launch
                Image("app-logo")
                    .scaleEffect(appeared ? 1 : 0.3)
                    .animation(.bouncy.delay(0.1), value: appeared)

                // Gratuitous: each card slides in from the side on load
                ForEach(items.indices, id: \.self) { index in
                    CardView(item: items[index])
                        .offset(x: appeared ? 0 : 300)
                        .animation(
                            .smooth.delay(Double(index) * 0.1),
                            value: appeared
                        )
                }

                // Gratuitous: decorative parallax on scroll
                GeometryReader { geo in
                    Image("hero-background")
                        .offset(y: geo.frame(in: .global).minY * 0.5)
                }
            }
        }
        .onAppear { appeared = true }
    }
}
```

**Correct (animation reserved for meaningful state changes and feedback):**

```swift
struct HomeView: View {
    @State private var deletedItemID: UUID?
    @State private var savedConfirmation = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // No entrance animation: content is immediately available
                Image("app-logo")

                // Items appear instantly; animation only on state change (deletion)
                ForEach(items) { item in
                    CardView(item: item)
                        .transition(.asymmetric(
                            insertion: .identity,
                            removal: .slide.combined(with: .opacity)
                        ))
                }
                .animation(.smooth, value: items)
            }
        }
        .overlay(alignment: .top) {
            // Feedback: confirms a save action completed
            if savedConfirmation {
                Label("Saved", systemImage: "checkmark.circle.fill")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(.thinMaterial, in: Capsule())
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation(.smooth) {
                                savedConfirmation = false
                            }
                        }
                    }
            }
        }
    }
}
```

**The three valid reasons to animate:**

| Purpose | Example | Preset |
|---------|---------|--------|
| **Communicate** state change | Item added/removed from list, tab switch | `.smooth` |
| **Direct** attention | New badge appears, error field highlights | `.snappy` |
| **Confirm** user action | Save completed, message sent, item favorited | `.bouncy` |

If an animation does not fit one of these three categories, remove it.

**When NOT to apply:** Games, creative tools, and media apps where ambient motion (particle effects, subtle background animation) is part of the experience design and contributes to immersion rather than UI communication.

**Reference:** WWDC 2023 "Animate with springs" — Apple frames animation as a tool for communication, recommending developers ask "what is this animation telling the user?" before adding any motion to the interface.
