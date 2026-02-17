---
title: Remove Controls That Do Not Serve the Core Task
impact: HIGH
impactDescription: every additional visible control is a question the user must answer before they can act — reducing control count from 12 to 5 transforms overwhelm into clarity
tags: less, controls, rams-10, segall-minimal, hicks-law
---

## Remove Controls That Do Not Serve the Core Task

Every button on a screen is a question the user must answer before they can act. A music player with 12 simultaneously visible controls — play, pause, skip, shuffle, repeat, speed, AirPlay, queue, lyrics, sleep timer, equalizer, share — feels like an exam, not an experience. The user came to press play, but first they must visually parse all 12 options, decide which ones are irrelevant, and locate the one they need. That friction is invisible to the developer who knows where everything is, but crushing to the user who just wants to hear a song. Jobs cut Apple's product line from 350 to 10 — the same ruthless reduction applies to controls on screen. If a control is used by fewer than 20% of users, it belongs behind a menu, not on the primary surface. The goal is not fewer features — it is fewer *visible* decisions.

**Incorrect (12 controls visible simultaneously — overwhelming):**

```swift
struct PlayerControls: View {
    var body: some View {
        VStack(spacing: 16) {
            // 12 controls visible simultaneously — overwhelming
            HStack {
                Button(action: {}) { Image(systemName: "shuffle") }
                Button(action: {}) { Image(systemName: "repeat") }
                Button(action: {}) { Image(systemName: "speedometer") }
                Button(action: {}) { Image(systemName: "airplayaudio") }
            }

            HStack(spacing: 32) {
                Button(action: {}) { Image(systemName: "backward.fill") }
                Button(action: {}) {
                    Image(systemName: "play.fill")
                        .font(.title)
                }
                Button(action: {}) { Image(systemName: "forward.fill") }
            }

            HStack {
                Button(action: {}) { Image(systemName: "quote.bubble") }
                Button(action: {}) { Image(systemName: "list.bullet") }
                Button(action: {}) { Image(systemName: "moon.fill") }
                Button(action: {}) { Image(systemName: "slider.horizontal.3") }
                Button(action: {}) { Image(systemName: "square.and.arrow.up") }
            }
        }
    }
}
```

**Correct (core transport visible, secondary controls one tap away):**

```swift
struct PlayerControls: View {
    @State private var showMore = false

    var body: some View {
        VStack(spacing: 24) {
            // Core transport: the only controls 95% of users need
            HStack(spacing: 40) {
                Button(action: {}) {
                    Image(systemName: "backward.fill")
                        .font(.title2)
                }

                Button(action: {}) {
                    Image(systemName: "play.fill")
                        .font(.largeTitle)
                }

                Button(action: {}) {
                    Image(systemName: "forward.fill")
                        .font(.title2)
                }
            }
            .foregroundStyle(.primary)

            // Secondary controls: one tap away, not zero taps
            HStack {
                Button(action: {}) {
                    Image(systemName: "quote.bubble")
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "airplayaudio")
                }
                Spacer()
                Button(action: {}) {
                    Image(systemName: "list.bullet")
                }
                Spacer()
                Menu {
                    Button("Sleep Timer", systemImage: "moon.fill") {}
                    Button("Equalizer", systemImage: "slider.horizontal.3") {}
                    Button("Speed", systemImage: "speedometer") {}
                    Button("Share", systemImage: "square.and.arrow.up") {}
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
            .font(.body)
            .foregroundStyle(.secondary)
        }
    }
}
```

**Decision framework for control visibility:**
- **Used by 80%+ of users** → always visible on screen
- **Used by 20-80% of users** → secondary row or long-press context menu
- **Used by less than 20% of users** → menu, sheet, or Settings

**When NOT to apply:**
Professional tools (audio editors, design apps, developer tools) where power users expect dense control surfaces. Even then, progressive disclosure through collapsible tool palettes or mode-specific panels is preferable to showing everything at once.

Reference: [Apple HIG — Controls](https://developer.apple.com/design/human-interface-guidelines/controls)
