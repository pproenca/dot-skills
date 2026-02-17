---
title: Use .smooth for Routine, .snappy for Interactive, .bouncy for Delight
impact: HIGH
impactDescription: reduces motion inconsistency to 3 named presets — eliminates per-view custom spring tuning across 100% of animated transitions
tags: invisible, motion, spring-presets, rams-5, edson-product, design-system
---

## Use .smooth for Routine, .snappy for Interactive, .bouncy for Delight

Open Apple Fitness after closing a ring and the checkmark bounces with a little flourish — it is celebrating with you. Now open Apple Health and tap between tabs: the transition is calm, almost invisible, because Health is a reference tool, not a coach. Both apps ship from the same company, yet their motion feels different because each draws from a small palette of exactly three springs. `.smooth` for routine movement, `.snappy` for things you tap, `.bouncy` for moments worth celebrating. Three presets are enough to build an entire motion language — one that becomes invisible through consistency the way a typeface disappears when every paragraph uses the same family. Rams called it unobtrusiveness: when every transition picks from the same short vocabulary, no single animation calls attention to itself, and the whole app feels crafted at once.

> **See also:** [invisible-spring-physics](./invisible-spring-physics.md) for why springs model real inertia, and [invisible-no-easing](./invisible-no-easing.md) for why linear and easeInOut curves should be replaced by these presets.

**Incorrect (bouncy spring applied to every transition):**

```swift
struct SettingsView: View {
    @State private var showDetail = false
    @State private var notificationsOn = false
    @State private var showSuccess = false

    var body: some View {
        VStack {
            // Bouncy on a sheet presentation feels juvenile
            Button("Account Details") { showDetail = true }
                .sheet(isPresented: $showDetail) {
                    AccountDetailView()
                        .transition(.move(edge: .bottom))
                        .animation(.bouncy, value: showDetail)
                }

            // Bouncy on a toggle feels sluggish
            Toggle("Notifications", isOn: $notificationsOn)
                .animation(.bouncy, value: notificationsOn)

            // Custom Spring parameters that don't match any system preset
            if showSuccess {
                Label("Saved", systemImage: "checkmark.circle.fill")
                    .transition(.scale)
                    .animation(
                        .spring(response: 0.4, dampingFraction: 0.6),
                        value: showSuccess
                    )
            }
        }
    }
}
```

**Correct (preset matched to interaction intent):**

```swift
struct SettingsView: View {
    @State private var showDetail = false
    @State private var notificationsOn = false
    @State private var showSuccess = false

    var body: some View {
        VStack {
            // .smooth — routine navigation, no bounce needed
            Button("Account Details") { showDetail = true }
                .sheet(isPresented: $showDetail) {
                    AccountDetailView()
                        .transition(.move(edge: .bottom))
                        .animation(.smooth, value: showDetail)
                }

            // .snappy — interactive control, fast + slight bounce for responsiveness
            Toggle("Notifications", isOn: $notificationsOn)
                .animation(.snappy, value: notificationsOn)

            // .bouncy — celebration/delight moment
            if showSuccess {
                Label("Saved", systemImage: "checkmark.circle.fill")
                    .transition(.scale)
                    .animation(.bouncy, value: showSuccess)
            }
        }
    }
}
```

**When to use each preset:**

| Preset | Character | Use for |
|--------|-----------|---------|
| `.smooth` | No bounce, calm | Tab switches, sheet presentations, layout changes, most UI |
| `.snappy` | Small bounce, responsive | Toggles, buttons, drag-and-drop, interactive controls |
| `.bouncy` | Larger bounce, playful | Success confirmations, celebrations, onboarding highlights |

**When NOT to apply:** Branded hero animations or game-like interactions where custom spring parameters (mass, stiffness, damping) are intentionally tuned to create a specific motion personality that the three presets cannot express.

**Reference:** WWDC 2023 "Animate with springs" — Apple introduced these three presets specifically to replace ad-hoc `Spring()` parameters with a shared motion vocabulary.
