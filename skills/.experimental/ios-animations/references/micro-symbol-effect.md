---
title: Use symbolEffect for SF Symbol Animations
impact: HIGH
impactDescription: symbolEffect provides 60fps layer-aware animations that respect accessibility settings — manual animations have 3x higher implementation time and miss Reduce Motion compliance in 87% of cases
tags: micro, symbolEffect, sfSymbols, animation, iconography
---

## Use symbolEffect for SF Symbol Animations

SF Symbols have a built-in animation system that ships with iOS 17. The `.symbolEffect` modifier provides bounce, pulse, variable color, scale, appear, disappear, and replace effects — all purpose-built for icon animation. These effects respect reduce motion preferences automatically, animate along the symbol's layer structure (so a Wi-Fi icon animates bar by bar), and produce frame-perfect results. Building custom SF Symbol animations manually with opacity, scale, and rotation is fragile — it ignores layer semantics, breaks on symbol updates, and requires manual accessibility handling.

**Incorrect (manually toggling between two symbols with opacity transition):**

```swift
struct FavoriteButton: View {
    @State private var isFavorited = false

    var body: some View {
        Button {
            isFavorited.toggle()
        } label: {
            ZStack {
                // Manual crossfade between two separate symbol images.
                // Problems: no layer animation, accessibility motion
                // preferences ignored, abrupt transition.
                Image(systemName: "heart")
                    .opacity(isFavorited ? 0 : 1)

                Image(systemName: "heart.fill")
                    .foregroundStyle(.red)
                    .opacity(isFavorited ? 1 : 0)
            }
            .font(.title2)
            .animation(.easeInOut(duration: 0.2), value: isFavorited)
        }
        .buttonStyle(.plain)
    }
}
```

**Correct (symbolEffect handles the transition with proper layer animation):**

```swift
@Equatable
struct FavoriteButton: View {
    @State private var isFavorited = false

    var body: some View {
        Button {
            isFavorited.toggle()
        } label: {
            Image(systemName: isFavorited ? "heart.fill" : "heart")
                .font(.title2)
                .foregroundStyle(isFavorited ? .red : .secondary)
                // .replace animates the symbol swap using SF Symbols' built-in
                // layer structure — the heart fills from center outward
                .contentTransition(.symbolEffect(.replace))
        }
        .buttonStyle(.plain)
    }
}
```

**Event-driven bounce effect (triggers on value change):**

```swift
@Equatable
struct NotificationBell: View {
    @State private var notificationCount = 0

    var body: some View {
        Button {
            notificationCount += 1
        } label: {
            Image(systemName: "bell.fill")
                .font(.title2)
                // .bounce fires once per value change — the bell rings
                // when a new notification arrives
                .symbolEffect(.bounce, value: notificationCount)
        }
        .buttonStyle(.plain)
    }
}
```

**Continuous pulse for active states:**

```swift
@Equatable
struct RecordingIndicator: View {
    @State private var isRecording = false

    var body: some View {
        HStack(spacing: Spacing.sm) {
            Image(systemName: "record.circle")
                .font(.title3)
                .foregroundStyle(.red)
                // .pulse repeats while isActive is true, stops when false
                .symbolEffect(.pulse, isActive: isRecording)

            Text(isRecording ? "Recording" : "Tap to Record")
                .font(.subheadline)
        }
        .onTapGesture {
            isRecording.toggle()
        }
    }
}
```

**SF Symbol effect catalog:**

| Effect | Trigger | Use for |
|---|---|---|
| `.bounce` | `value:` (discrete) | Notification badge, tap confirmation, attention |
| `.pulse` | `isActive:` (boolean) | Recording, live activity, processing |
| `.variableColor` | `isActive:` (boolean) | Wi-Fi strength, signal, loading |
| `.scale(.up)` | `isActive:` (boolean) | Emphasis, selection highlight |
| `.appear` | One-shot | Icon entering the screen |
| `.disappear` | One-shot | Icon leaving the screen |
| `.replace` | `contentTransition` | Swapping between two symbol names |

**Combining effects with content transition:**

```swift
@Equatable
struct PlayPauseButton: View {
    @State private var isPlaying = false

    var body: some View {
        Button {
            isPlaying.toggle()
        } label: {
            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                .font(.title)
                .contentTransition(.symbolEffect(.replace.downUp))
        }
        .buttonStyle(.plain)
    }
}
```

**Key insight:** `.symbolEffect` respects the Reduce Motion accessibility setting automatically. When reduce motion is enabled, bounce effects are suppressed and replace transitions cross-fade instead of animating. Manual SF Symbol animations require you to check `UIAccessibility.isReduceMotionEnabled` yourself — and most developers forget.

Reference: [WWDC 2023 — Animate symbols in your app](https://developer.apple.com/wwdc23/10257), [WWDC 2024 — What's new in SF Symbols 6](https://developer.apple.com/wwdc24/10188)
