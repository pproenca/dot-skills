---
title: Add Inclusive Features for Broader Reach
impact: LOW
impactDescription: localization, color contrast, and reduced motion support expand your audience
tags: acc, localization, reduced-motion, inclusive, accessibility
---

## Add Inclusive Features for Broader Reach

Hardcoding English strings, ignoring reduced motion preferences, and relying solely on color to convey meaning excludes large segments of your potential audience. Supporting localization, respecting accessibility settings, and using multiple visual cues makes your app usable by more people worldwide.

**Incorrect (English-only text and motion-heavy UI with no fallback):**

```swift
struct GreetingHeader: View {
    let userName: String

    var body: some View {
        VStack(spacing: 12) {
            Text("Good morning, \(userName)!")
                .font(.title)
            Circle()
                .fill(.green)
                .frame(width: 12, height: 12)
                .scaleEffect(pulseScale)
                .animation(.easeInOut(duration: 1).repeatForever(), value: pulseScale)
        }
    }

    @State private var pulseScale: CGFloat = 1.2
}
```

**Correct (localized strings and reduced motion check):**

```swift
struct GreetingHeader: View {
    let userName: String
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(spacing: 12) {
            Text("greeting.morning \(userName)") // uses Localizable.xcstrings key
                .font(.title)
            HStack(spacing: 6) {
                Circle()
                    .fill(.green)
                    .frame(width: 12, height: 12)
                    .scaleEffect(reduceMotion ? 1.0 : pulseScale) // respects user preference
                    .animation(
                        reduceMotion ? nil : .easeInOut(duration: 1).repeatForever(),
                        value: pulseScale
                    )
                Text("status.online") // label supplements the color indicator
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @State private var pulseScale: CGFloat = 1.2
}
```

Reference: [Develop in Swift Tutorials](https://developer.apple.com/tutorials/develop-in-swift/)
