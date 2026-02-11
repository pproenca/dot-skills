---
title: Use .smooth for Routine, .snappy for Interactive, .bouncy for Delight
impact: HIGH
impactDescription: reduces motion inconsistency to 3 named presets — eliminates per-view custom spring tuning across 100% of animated transitions
tags: motion, animation, spring, design-system
---

## Use .smooth for Routine, .snappy for Interactive, .bouncy for Delight

iOS 17 provides three spring presets that map directly to interaction intent. Using the wrong preset (`.bouncy` everywhere, or custom `Spring()` parameters on every view) produces motion that feels random rather than intentional. A disciplined mapping creates a motion language users internalize without thinking about it.

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

**Reference:** WWDC 2023 "Animate with springs" — Apple introduced these three presets specifically to replace ad-hoc `Spring()` parameters with a shared motion vocabulary.
